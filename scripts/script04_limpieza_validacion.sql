/*
    Paso 4: limpieza y validación básica.
    Ejecutar después de script02_cargar_csv_raw.sql y script03_perfilamiento_datos.sql.

    El perfilamiento reportó cero faltantes, IDs repetidos y problemas generales de conversión.
    customer_age y account_age_years se conservan como atributos fuente de DimCustomer;
    num_prev_transactions y time_since_last_txn_hrs se conservan como atributos fuente de
    FactTransaction. No se corrigen ni se usarán para calcular KPI.
*/
USE [Aethel_Capital_Bank];
GO

IF OBJECT_ID(N'dbo.stg_bank_fraud_clean', N'U') IS NOT NULL
    DROP TABLE dbo.stg_bank_fraud_clean;
GO

-- Crea la tabla limpia convirtiendo los datos a tipos adecuados.
-- Los campos de fecha y hora y la etiqueta is_fraud ya fueron validados en el perfilamiento.
SELECT
    transaction_id,
    customer_id,
    CAST(transaction_date AS DATE) AS transaction_date,
    CAST(transaction_time AS TIME(0)) AS transaction_time,
    DATEPART(HOUR, CAST(transaction_time AS TIME(0))) AS hour_of_day,
    CAST(is_weekend AS BIT) AS is_weekend,
    CAST(
        CASE
            WHEN CAST(transaction_time AS TIME(0)) >= CONVERT(TIME, '22:00')
            OR CAST(transaction_time AS TIME(0)) < CONVERT(TIME, '06:00')
            THEN 1
            ELSE 0
        END AS BIT
    ) AS is_night_transaction,
    CASE
        WHEN UPPER(city) IN (N'DELHI', N'MUMBAI') THEN N'India'
        WHEN UPPER(city) IN (N'RIO', N'SÃO PAULO') THEN N'Brazil'
        WHEN UPPER(city) IN (N'SYDNEY', N'MELBOURNE') THEN N'Australia'
        WHEN UPPER(city) IN (N'LONDON', N'MANCHESTER') THEN N'UK'
        WHEN UPPER(city) IN (N'GUADALAJARA', N'MEXICO CITY') THEN N'Mexico'
        WHEN UPPER(city) IN (N'MUNICH', N'BERLIN') THEN N'Germany'
        WHEN UPPER(city) IN (N'LOS ANGELES', N'NEW YORK') THEN N'USA'
        WHEN UPPER(city) IN (N'PARIS', N'LYON') THEN N'France'
        WHEN UPPER(city) IN (N'TORONTO', N'VANCOUVER') THEN N'Canada'
        WHEN UPPER(city) IN (N'OSAKA', N'TOKYO') THEN N'Japan'
        ELSE country
    END AS country,
    city,
    merchant_category,
    payment_method,
    CASE
        WHEN payment_method = 'Bank Transfer' THEN 
            CASE 
                WHEN device_type = 'ATM' THEN 'Desktop' 
                WHEN device_type = 'POS Terminal' THEN 'Mobile' 
                ELSE device_type 
            END
        WHEN payment_method = 'Cheque' THEN NULL
        WHEN payment_method = 'Credit Card' THEN 
            CASE 
                WHEN device_type = 'ATM' THEN 'Desktop' 
                ELSE device_type 
            END
        WHEN payment_method = 'Crypto' THEN 
            CASE 
                WHEN device_type = 'ATM' THEN 'Desktop' 
                WHEN device_type = 'POS Terminal' THEN 'Mobile' 
                ELSE device_type 
            END
        WHEN payment_method = 'Debit Card' THEN device_type
        WHEN payment_method = 'Mobile Payment' THEN 'Mobile'
    END AS device_type,
    CAST(customer_age AS INT) AS customer_age,
    CAST(credit_score AS INT) AS credit_score,
    CAST(account_age_years AS DECIMAL(6,2)) AS account_age_years,
    CAST(account_balance AS DECIMAL(18,2)) AS account_balance,
    CAST(transaction_amount AS DECIMAL(18,2)) AS transaction_amount,
    CAST(num_prev_transactions AS INT) AS num_prev_transactions,
    CAST(transaction_freq_monthly AS DECIMAL(12,3)) AS transaction_freq_monthly,
    CAST(distance_from_home_km AS DECIMAL(12,3)) AS distance_from_home_km,
    CAST(time_since_last_txn_hrs AS DECIMAL(12,3)) AS time_since_last_txn_hrs,
    CAST(is_international AS BIT) AS is_international,
    CAST(failed_attempts AS INT) AS failed_attempts,
    CAST(pin_changed_recently AS BIT) AS pin_changed_recently,
    CAST(is_fraud AS BIT) AS is_fraud,
    CASE
        WHEN UPPER(fraud_type) = N'NONE' THEN NULL
        ELSE fraud_type
    END AS fraud_type
INTO dbo.stg_bank_fraud_clean
FROM dbo.raw_bank_fraud;
GO


SELECT c.name, t.name
FROM sys.columns AS c
JOIN sys.types AS t ON c.user_type_id = t.user_type_id
WHERE object_id = OBJECT_ID(N'dbo.stg_bank_fraud_clean')
-- Resultado: los tipos resultantes coinciden con los previstos en la conversión
-- (DATE, TIME, INT, DECIMAL y BIT); no hay columnas con tipos inesperados.

SELECT * FROM dbo.stg_bank_fraud_clean

-- Resumen antes y después: como no se reportaron filas inválidas generales, se espera
-- que ambas cantidades sean iguales.
SELECT
    (SELECT COUNT_BIG(*) FROM dbo.raw_bank_fraud) AS filas_raw,
    (SELECT COUNT_BIG(*) FROM dbo.stg_bank_fraud_clean) AS filas_limpias;
-- Resultado: 1.000.000 filas en ambas tablas; la conversión no descartó ni duplicó registros.
GO

-- Cantidad de discrepancias en los atributos temporales derivados.
SELECT
    SUM(CASE WHEN CAST(r.is_night_transaction AS INT) <> c.is_night_transaction THEN 1 ELSE 0 END) AS noche_inconsistente
FROM dbo.raw_bank_fraud AS r
JOIN dbo.stg_bank_fraud_clean AS c ON r.transaction_id = c.transaction_id;
-- Resultado: 41.430 discrepancias, igual que en el perfilamiento; la columna limpia
-- is_night_transaction es la recalculada (22:00-06:00) y corrige el indicador original
-- defectuoso del CSV.
GO


SELECT
    country,
    city,
    COUNT_BIG(*) AS transacciones
FROM dbo.stg_bank_fraud_clean
GROUP BY country, city
ORDER BY country, transacciones DESC, city;
-- Resultado: tras la normalización del CASE, cada ciudad queda asociada a un único país, de modo que cada uno de los 10 países presentes en el dataset tiene dos ciudades asociadas. Esto permite poblar DimLocation sin inconsistencias.
GO



SELECT
    payment_method,
    device_type,
    COUNT_BIG(*) AS transacciones
FROM dbo.stg_bank_fraud_clean
GROUP BY payment_method, device_type
ORDER BY payment_method, device_type
-- Resultado: tras la normalización del CASE, cada método de pago esta afiliado a sus tipos correspondientes de dispositivos utilizados.

