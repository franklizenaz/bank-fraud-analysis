/*
    Paso 5: crear y cargar el modelo estrella.
    Ejecutar después de script04_limpieza_validacion.sql.
    Grano de FactTransaction: una fila por transacción.

    DimCustomer tiene una sola fila por customer_id. Sus atributos se toman de la
    transacción más reciente del cliente (fecha y hora). num_prev_transactions y
    time_since_last_txn_hrs quedan en los hechos, pero no se usarán para KPI.
*/
USE [Aethel_Capital_Bank];
GO

IF SCHEMA_ID(N'dw') IS NULL
    EXEC(N'CREATE SCHEMA dw');
GO

-- Se eliminan primero los hechos porque dependen de las dimensiones.
IF OBJECT_ID(N'dw.FactTransaction', N'U') IS NOT NULL DROP TABLE dw.FactTransaction;
IF OBJECT_ID(N'dw.DimDeviceType', N'U') IS NOT NULL DROP TABLE dw.DimDeviceType;
IF OBJECT_ID(N'dw.DimPaymentChannel', N'U') IS NOT NULL DROP TABLE dw.DimPaymentChannel;
IF OBJECT_ID(N'dw.DimMerchantCategory', N'U') IS NOT NULL DROP TABLE dw.DimMerchantCategory;
IF OBJECT_ID(N'dw.DimLocation', N'U') IS NOT NULL DROP TABLE dw.DimLocation;
IF OBJECT_ID(N'dw.DimCustomer', N'U') IS NOT NULL DROP TABLE dw.DimCustomer;
IF OBJECT_ID(N'dw.DimDateTime', N'U') IS NOT NULL DROP TABLE dw.DimDateTime;
GO

-- Una fila por combinación de fecha y hora que aparece en las transacciones.
CREATE TABLE dw.DimDateTime
(
    datetime_key INT IDENTITY(1,1) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME(0) NOT NULL,
    hour_of_day TINYINT NOT NULL,
    is_weekend BIT NOT NULL,
    is_night_transaction BIT NOT NULL,
    CONSTRAINT UQ_DimDateTime_Date_Time UNIQUE (transaction_date, transaction_time)
);

-- Una fila por cliente, con sus atributos en la transacción más reciente.
CREATE TABLE dw.DimCustomer
(
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id NVARCHAR(100) NOT NULL UNIQUE,
    customer_age INT NOT NULL,
    credit_score INT NOT NULL,
    account_age_years DECIMAL(6,2) NOT NULL
);

CREATE TABLE dw.DimLocation
(
    location_key INT IDENTITY(1,1) PRIMARY KEY,
    country NVARCHAR(100) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimLocation_Country_City UNIQUE (country, city)
);

CREATE TABLE dw.DimMerchantCategory
(
    merchant_category_key INT IDENTITY(1,1) PRIMARY KEY,
    merchant_category NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dw.DimPaymentChannel
(
    payment_channel_key INT IDENTITY(1,1) PRIMARY KEY,
    payment_method NVARCHAR(100) NOT NULL,
    device_type NVARCHAR(100) NULL
);

-- Una fila por transacción: transaction_id es la clave natural única.
CREATE TABLE dw.FactTransaction
(
    transaction_key INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id NVARCHAR(100) NOT NULL UNIQUE,
    datetime_key INT NOT NULL,
    customer_key INT NOT NULL,
    location_key INT NOT NULL,
    merchant_category_key INT NOT NULL,
    payment_channel_key INT NOT NULL,
    transaction_amount DECIMAL(18,2) NOT NULL,
    account_balance DECIMAL(18,2) NOT NULL,
    num_prev_transactions INT NOT NULL,
    transaction_freq_monthly DECIMAL(12,3) NOT NULL,
    distance_from_home_km DECIMAL(12,3) NOT NULL,
    time_since_last_txn_hrs DECIMAL(12,3) NOT NULL,
    is_international BIT NOT NULL,
    failed_attempts INT NOT NULL,
    pin_changed_recently BIT NOT NULL,
    is_fraud BIT NOT NULL,
    fraud_type NVARCHAR(100) NULL,
    CONSTRAINT FK_Fact_DimDateTime FOREIGN KEY (datetime_key) REFERENCES dw.DimDateTime(datetime_key),
    CONSTRAINT FK_Fact_DimCustomer FOREIGN KEY (customer_key) REFERENCES dw.DimCustomer(customer_key),
    CONSTRAINT FK_Fact_DimLocation FOREIGN KEY (location_key) REFERENCES dw.DimLocation(location_key),
    CONSTRAINT FK_Fact_DimMerchantCategory FOREIGN KEY (merchant_category_key) REFERENCES dw.DimMerchantCategory(merchant_category_key),
    CONSTRAINT FK_Fact_DimPaymentChannel FOREIGN KEY (payment_channel_key) REFERENCES dw.DimPaymentChannel(payment_channel_key),
);
GO

-- Cargar las dimensiones primero.
INSERT INTO dw.DimDateTime (transaction_date, transaction_time, hour_of_day, is_weekend, is_night_transaction)
SELECT DISTINCT transaction_date, transaction_time, hour_of_day, is_weekend, is_night_transaction
FROM dbo.stg_bank_fraud_clean;

WITH ClientesOrdenados AS
(
    SELECT
        customer_id,
        customer_age,
        credit_score,
        account_age_years,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY transaction_date DESC, transaction_time DESC, transaction_id DESC
        ) AS orden
    FROM dbo.stg_bank_fraud_clean
)
INSERT INTO dw.DimCustomer (customer_id, customer_age, credit_score, account_age_years)
SELECT customer_id, customer_age, credit_score, account_age_years
FROM ClientesOrdenados
WHERE orden = 1;
-- Observación: el perfilamiento (script03, fragmentos 10 y 11) mostró que customer_age y
-- account_age_years no son coherentes entre transacciones del mismo cliente (191.158 clientes
-- con edades distintas y sin secuencia anual; antigüedades en el mismo patrón). Por eso "tomar
-- la transacción más reciente" es una convención, no la selección del valor correcto:
-- DimCustomer guarda el último valor observado, no verificado, y por ello estos atributos
-- quedan fuera de KPI. credit_score no se perfiló por cliente y queda en la misma condición
-- de snapshot no validado.

INSERT INTO dw.DimLocation (country, city)
SELECT DISTINCT country, city
FROM dbo.stg_bank_fraud_clean;

INSERT INTO dw.DimMerchantCategory (merchant_category)
SELECT DISTINCT merchant_category
FROM dbo.stg_bank_fraud_clean;

INSERT INTO dw.DimPaymentChannel (payment_method, device_type)
SELECT DISTINCT payment_method, device_type
FROM dbo.stg_bank_fraud_clean;
GO

-- Cargar los hechos relacionando cada fila con sus claves sustitutas.
INSERT INTO dw.FactTransaction
(
    transaction_id, datetime_key, customer_key, location_key,
    merchant_category_key, payment_channel_key,
    transaction_amount, account_balance, num_prev_transactions,
    transaction_freq_monthly, distance_from_home_km, time_since_last_txn_hrs,
    is_international, failed_attempts, pin_changed_recently, is_fraud, fraud_type
)
SELECT
    s.transaction_id, dt.datetime_key, c.customer_key, l.location_key,
    mc.merchant_category_key, pc.payment_channel_key,
    s.transaction_amount, s.account_balance, s.num_prev_transactions,
    s.transaction_freq_monthly, s.distance_from_home_km, s.time_since_last_txn_hrs,
    s.is_international, s.failed_attempts, s.pin_changed_recently, s.is_fraud, s.fraud_type
FROM dbo.stg_bank_fraud_clean AS s
JOIN dw.DimDateTime AS dt
    ON s.transaction_date = dt.transaction_date AND s.transaction_time = dt.transaction_time
JOIN dw.DimCustomer AS c
    ON s.customer_id = c.customer_id
JOIN dw.DimLocation AS l ON s.country = l.country AND s.city = l.city
JOIN dw.DimMerchantCategory AS mc ON s.merchant_category = mc.merchant_category
JOIN dw.DimPaymentChannel AS pc ON s.payment_method = pc.payment_method AND ( s.device_type = pc.device_type OR (s.device_type IS NULL AND pc.device_type IS NULL) )
GO

-- Revisar cuántas filas quedaron en cada tabla.
SELECT N'DimDateTime' AS tabla, COUNT_BIG(*) AS filas FROM dw.DimDateTime
UNION ALL SELECT N'DimCustomer', COUNT_BIG(*) FROM dw.DimCustomer
UNION ALL SELECT N'DimLocation', COUNT_BIG(*) FROM dw.DimLocation
UNION ALL SELECT N'DimMerchantCategory', COUNT_BIG(*) FROM dw.DimMerchantCategory
UNION ALL SELECT N'DimPaymentChannel', COUNT_BIG(*) FROM dw.DimPaymentChannel
UNION ALL SELECT N'FactTransaction', COUNT_BIG(*) FROM dw.FactTransaction;

-- El total de hechos debe coincidir con el total de filas limpias y los IDs deben ser únicos.
SELECT
    (SELECT COUNT_BIG(*) FROM dbo.stg_bank_fraud_clean) AS filas_limpias,
    (SELECT COUNT_BIG(*) FROM dw.FactTransaction) AS filas_hechos,
    (SELECT COUNT_BIG(DISTINCT transaction_id) FROM dw.FactTransaction) AS transacciones_distintas;
GO
