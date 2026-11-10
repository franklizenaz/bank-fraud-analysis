/*
    Paso 3: perfilar los datos de la tabla raw antes de limpiarlos.
    Este script solo consulta datos.
*/

-- Usamos la base de datos Aethel_Capital_Bank, que contiene la tabla raw_bank_fraud.
USE [Aethel_Capital_Bank];
GO

-- 1. Volumen y esquema: confirma la carga y muestra los tipos físicos de las columnas.
SELECT
    (SELECT COUNT_BIG(*) FROM dbo.raw_bank_fraud) AS total_filas,
    (SELECT COUNT(*) FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.raw_bank_fraud')) AS total_columnas;

SELECT
    c.name AS columna,
    t.name AS tipo_sql,
    c.max_length AS longitud_bytes
FROM sys.columns AS c
JOIN sys.types AS t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.raw_bank_fraud')
ORDER BY c.column_id;
-- Resultado: 1.000.000 filas y 26 columnas; todas las columnas quedaron como NVARCHAR, coincidiendo 1:1 con el CSV.
GO

-- 2. Cardinalidad: cantidad de valores distintos por columna.
SELECT
    v.columna,
    COUNT_BIG(DISTINCT v.valor) AS total_valores_distintos
FROM dbo.raw_bank_fraud AS r
CROSS APPLY (
    VALUES
        (N'transaction_id',           CAST(r.transaction_id AS NVARCHAR(MAX))),
        (N'customer_id',              CAST(r.customer_id AS NVARCHAR(MAX))),
        (N'transaction_date',         CAST(r.transaction_date AS NVARCHAR(MAX))),
        (N'transaction_time',         CAST(r.transaction_time AS NVARCHAR(MAX))),
        (N'hour_of_day',              CAST(r.hour_of_day AS NVARCHAR(MAX))),
        (N'is_weekend',               CAST(r.is_weekend AS NVARCHAR(MAX))),
        (N'is_night_transaction',     CAST(r.is_night_transaction AS NVARCHAR(MAX))),
        (N'country',                  CAST(r.country AS NVARCHAR(MAX))),
        (N'city',                     CAST(r.city AS NVARCHAR(MAX))),
        (N'merchant_category',        CAST(r.merchant_category AS NVARCHAR(MAX))),
        (N'payment_method',           CAST(r.payment_method AS NVARCHAR(MAX))),
        (N'device_type',              CAST(r.device_type AS NVARCHAR(MAX))),
        (N'customer_age',             CAST(r.customer_age AS NVARCHAR(MAX))),
        (N'credit_score',             CAST(r.credit_score AS NVARCHAR(MAX))),
        (N'account_age_years',        CAST(r.account_age_years AS NVARCHAR(MAX))),
        (N'account_balance',          CAST(r.account_balance AS NVARCHAR(MAX))),
        (N'transaction_amount',       CAST(r.transaction_amount AS NVARCHAR(MAX))),
        (N'num_prev_transactions',    CAST(r.num_prev_transactions AS NVARCHAR(MAX))),
        (N'transaction_freq_monthly', CAST(r.transaction_freq_monthly AS NVARCHAR(MAX))),
        (N'distance_from_home_km',    CAST(r.distance_from_home_km AS NVARCHAR(MAX))),
        (N'time_since_last_txn_hrs',  CAST(r.time_since_last_txn_hrs AS NVARCHAR(MAX))),
        (N'is_international',         CAST(r.is_international AS NVARCHAR(MAX))),
        (N'failed_attempts',          CAST(r.failed_attempts AS NVARCHAR(MAX))),
        (N'pin_changed_recently',     CAST(r.pin_changed_recently AS NVARCHAR(MAX))),
        (N'is_fraud',                 CAST(r.is_fraud AS NVARCHAR(MAX))),
        (N'fraud_type',               CAST(r.fraud_type AS NVARCHAR(MAX)))
    ) AS v(columna, valor)
 GROUP BY v.columna
 ORDER BY v.columna;
-- Resultado: cardinalidad coherente; transaction_id presenta valores distintos equivalentes
-- al total de filas y las columnas categóricas muestran dominios acotados, sin valores distintos inesperados.
GO

-- 3. Calidad de carga: cuenta NULL, cadenas vacías y marcadores textuales.
-- En la revisión inicial estos conteos dieron cero; se conservan como control de perfilamiento.
SELECT
    v.columna,
    COUNT_BIG(*) AS total_filas,
    SUM(CASE WHEN v.valor IS NULL THEN 1 ELSE 0 END) AS nulos_sql,
    SUM(CASE WHEN v.valor IS NOT NULL AND v.valor = N'' THEN 1 ELSE 0 END) AS vacios,
    SUM(CASE WHEN UPPER(v.valor) IN (N'NONE', N'NULL', N'N/A') THEN 1 ELSE 0 END) AS marcadores_textuales
FROM dbo.raw_bank_fraud AS r
CROSS APPLY (
    VALUES
        (N'transaction_id',           CAST(r.transaction_id AS NVARCHAR(MAX))),
        (N'customer_id',              CAST(r.customer_id AS NVARCHAR(MAX))),
        (N'transaction_date',         CAST(r.transaction_date AS NVARCHAR(MAX))),
        (N'transaction_time',         CAST(r.transaction_time AS NVARCHAR(MAX))),
        (N'hour_of_day',              CAST(r.hour_of_day AS NVARCHAR(MAX))),
        (N'is_weekend',               CAST(r.is_weekend AS NVARCHAR(MAX))),
        (N'is_night_transaction',     CAST(r.is_night_transaction AS NVARCHAR(MAX))),
        (N'country',                  CAST(r.country AS NVARCHAR(MAX))),
        (N'city',                     CAST(r.city AS NVARCHAR(MAX))),
        (N'merchant_category',        CAST(r.merchant_category AS NVARCHAR(MAX))),
        (N'payment_method',           CAST(r.payment_method AS NVARCHAR(MAX))),
        (N'device_type',              CAST(r.device_type AS NVARCHAR(MAX))),
        (N'customer_age',             CAST(r.customer_age AS NVARCHAR(MAX))),
        (N'credit_score',             CAST(r.credit_score AS NVARCHAR(MAX))),
        (N'account_age_years',        CAST(r.account_age_years AS NVARCHAR(MAX))),
        (N'account_balance',          CAST(r.account_balance AS NVARCHAR(MAX))),
        (N'transaction_amount',       CAST(r.transaction_amount AS NVARCHAR(MAX))),
        (N'num_prev_transactions',    CAST(r.num_prev_transactions AS NVARCHAR(MAX))),
        (N'transaction_freq_monthly', CAST(r.transaction_freq_monthly AS NVARCHAR(MAX))),
        (N'distance_from_home_km',    CAST(r.distance_from_home_km AS NVARCHAR(MAX))),
        (N'time_since_last_txn_hrs',  CAST(r.time_since_last_txn_hrs AS NVARCHAR(MAX))),
        (N'is_international',         CAST(r.is_international AS NVARCHAR(MAX))),
        (N'failed_attempts',          CAST(r.failed_attempts AS NVARCHAR(MAX))),
        (N'pin_changed_recently',     CAST(r.pin_changed_recently AS NVARCHAR(MAX))),
        (N'is_fraud',                 CAST(r.is_fraud AS NVARCHAR(MAX))),
        (N'fraud_type',               CAST(r.fraud_type AS NVARCHAR(MAX)))
    ) AS v(columna, valor)
GROUP BY v.columna
ORDER BY v.columna;
-- Resultado: 0 nulos SQL y 0 cadenas vacías en todas las columnas. El único marcador
-- textual detectado es fraud_type = 'NONE' en las filas con is_fraud = 0 (esperado: sin
-- tipo de fraude en transacciones legítimas); el resto de variables sin problemas.
GO

-- 4. Fechas y horas: detecta formatos no convertibles y revisa el periodo observado.
-- El rango 2020-2024 es el indicado por la ficha del conjunto de datos.
SELECT
    COUNT_BIG(*) AS total_filas,
    SUM(CASE WHEN TRY_CONVERT(TIME, transaction_time) IS NULL THEN 1 ELSE 0 END) AS horas_invalidas,
    MIN(TRY_CONVERT(TIME(0), transaction_time)) AS hora_minima,
    MAX(TRY_CONVERT(TIME(0), transaction_time)) AS hora_maxima,
    SUM(CASE WHEN TRY_CONVERT(DATE, transaction_date, 23) IS NULL THEN 1 ELSE 0 END) AS fechas_invalidas,
    MIN(TRY_CONVERT(DATE, transaction_date, 23)) AS fecha_minima,
    MAX(TRY_CONVERT(DATE, transaction_date, 23)) AS fecha_maxima,
    SUM(CASE WHEN TRY_CONVERT(DATE, transaction_date, 23) < '20200101'
               OR TRY_CONVERT(DATE, transaction_date, 23) > '20241231' THEN 1 ELSE 0 END) AS fechas_fuera_rango_2020_2024
FROM dbo.raw_bank_fraud;
-- Resultado: 0 horas inválidas, 0 fechas inválidas y 0 fechas fuera del rango 2020-2024;
-- el periodo observado coincide con el indicado por la ficha del conjunto de datos.
GO

-- 5. Variables numéricas: detecta texto no convertible y resume mínimo, máximo y promedio.
-- Los extremos se reportan para revisión; no se eliminan durante el perfilamiento.
WITH Valores AS
(
    SELECT
        v.campo,
        v.raw_value,
        TRY_CONVERT(DECIMAL(28,8), v.raw_value) AS valor
    FROM dbo.raw_bank_fraud AS r
    CROSS APPLY (VALUES
        (N'hour_of_day', r.hour_of_day),
        (N'customer_age', r.customer_age),
        (N'credit_score', r.credit_score),
        (N'account_age_years', r.account_age_years),
        (N'account_balance', r.account_balance),
        (N'transaction_amount', r.transaction_amount),
        (N'num_prev_transactions', r.num_prev_transactions),
        (N'transaction_freq_monthly', r.transaction_freq_monthly),
        (N'distance_from_home_km', r.distance_from_home_km),
        (N'time_since_last_txn_hrs', r.time_since_last_txn_hrs),
        (N'failed_attempts', r.failed_attempts)
    ) AS v(campo, raw_value)
)
SELECT
    campo,
    SUM(CASE WHEN valor IS NULL THEN 1 ELSE 0 END) AS no_convertibles,
    MIN(valor) AS minimo,
    MAX(valor) AS maximo,
    AVG(valor) AS promedio
FROM Valores
GROUP BY campo
ORDER BY campo;
-- Resultado: 0 valores no convertibles en las 11 variables numéricas; mínimos, máximos y
-- promedios dentro de lo esperado, sin textos ni extremos que impidan la conversión.
GO

-- 6. Rangos declarados: cuenta valores convertibles que incumplen límites conocidos.
-- Los límites proceden del diccionario; los campos sin rango documentado no se fuerzan aquí.
SELECT campo, valores_fuera_rango
FROM
(
    SELECT N'hour_of_day' AS campo,
           SUM(CASE WHEN TRY_CONVERT(INT, hour_of_day) NOT BETWEEN 0 AND 23 THEN 1 ELSE 0 END) AS valores_fuera_rango
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'credit_score',
           SUM(CASE WHEN TRY_CONVERT(INT, credit_score) NOT BETWEEN 300 AND 850 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'account_age_years',
           SUM(CASE WHEN TRY_CONVERT(DECIMAL(28,8), account_age_years) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'transaction_amount',
           SUM(CASE WHEN TRY_CONVERT(DECIMAL(28,8), transaction_amount) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'num_prev_transactions',
           SUM(CASE WHEN TRY_CONVERT(INT, num_prev_transactions) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'distance_from_home_km',
           SUM(CASE WHEN TRY_CONVERT(DECIMAL(28,8), distance_from_home_km) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'time_since_last_txn_hrs',
           SUM(CASE WHEN TRY_CONVERT(DECIMAL(28,8), time_since_last_txn_hrs) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
    UNION ALL
    SELECT N'failed_attempts',
           SUM(CASE WHEN TRY_CONVERT(INT, failed_attempts) < 0 THEN 1 ELSE 0 END)
    FROM dbo.raw_bank_fraud
) AS rangos
ORDER BY campo;
-- Resultado: 0 valores fuera de rango en los 8 controles (hour_of_day 0-23, credit_score
-- 300-850 y no negatividad de account_age_years, transaction_amount, num_prev_transactions,
-- distance_from_home_km, time_since_last_txn_hrs y failed_attempts).
GO

-- 7. Categorías: frecuencia por valor para detectar etiquetas inesperadas.
SELECT
    v.campo,
    v.valor,
    COUNT_BIG(*) AS frecuencia
FROM dbo.raw_bank_fraud AS r
CROSS APPLY (VALUES
    (N'country', r.country),
    (N'city', r.city),
    (N'merchant_category', r.merchant_category),
    (N'payment_method', r.payment_method),
    (N'device_type', r.device_type),
    (N'fraud_type', r.fraud_type)
) AS v(campo, valor)
GROUP BY v.campo, v.valor
ORDER BY v.campo, frecuencia DESC, v.valor;
-- Resultado: dominios con etiquetas inesperadas en la geografía; muchas ciudades aparecen
-- asociadas a países que no les corresponden (ver fragmento 14). 
GO

-- 8. Indicadores binarios: cuenta valores no convertibles o distintos de 0 y 1.
-- Se perfila dbo.raw_bank_fraud, igual que en los demás bloques.
SELECT
    v.columna,
    SUM(CASE WHEN TRY_CONVERT(INT, v.valor) NOT IN (0, 1) THEN 1 ELSE 0 END) AS valores_invalidos
FROM dbo.raw_bank_fraud AS r
CROSS APPLY (VALUES
    (N'is_weekend', r.is_weekend),
    (N'is_night_transaction', r.is_night_transaction),
    (N'is_international', r.is_international),
    (N'pin_changed_recently', r.pin_changed_recently),
    (N'is_fraud', r.is_fraud)
) AS v(columna, valor)
GROUP BY v.columna
ORDER BY v.columna;
-- Resultado: 0 valores inválidos en los 5 indicadores binarios; todos contienen exclusivamente
-- 0 y 1, por lo que pueden convertirse a BOOLEAN tras el perfilamiento.
GO

-- 9. Coherencia temporal: compara los indicadores derivados con fecha y hora.
-- La noche se define según el diccionario como 22:00-06:00.
SELECT
    SUM(CASE WHEN TRY_CONVERT(INT, r.is_weekend) IN (0, 1)
                  AND TRY_CONVERT(DATE, r.transaction_date, 23) IS NOT NULL
                  AND TRY_CONVERT(INT, r.is_weekend) <> CASE
                      WHEN DATEDIFF(DAY, '19000101', TRY_CONVERT(DATE, r.transaction_date, 23)) % 7 IN (5, 6) THEN 1 ELSE 0 END
             THEN 1 ELSE 0 END) AS fin_de_semana_inconsistente,
    SUM(CASE WHEN TRY_CONVERT(INT, r.hour_of_day) IS NOT NULL
                  AND TRY_CONVERT(TIME, r.transaction_time) IS NOT NULL
                  AND TRY_CONVERT(INT, r.hour_of_day) <> DATEPART(HOUR, TRY_CONVERT(TIME, r.transaction_time))
             THEN 1 ELSE 0 END) AS hora_inconsistente,
    SUM(CASE WHEN TRY_CONVERT(INT, r.is_night_transaction) IN (0, 1)
                  AND TRY_CONVERT(TIME, r.transaction_time) IS NOT NULL
                  AND TRY_CONVERT(INT, r.is_night_transaction) <> CASE
                      WHEN TRY_CONVERT(TIME, r.transaction_time) >= CAST('22:00' AS TIME)
                        OR TRY_CONVERT(TIME, r.transaction_time) < CAST('06:00' AS TIME) THEN 1 ELSE 0 END
             THEN 1 ELSE 0 END) AS horario_nocturno_inconsistente
FROM dbo.raw_bank_fraud AS r;
-- Resultado: 0 inconsistencias en fin de semana y 0 en hora; pero 41.430 inconsistencias en
-- horario nocturno, donde is_night_transaction = 1 sin que la hora caiga en la ventana
-- 22:00-06:00. El indicador original no es fiable y se recalculará mediante transaction_time.
GO

-- 10. Coherencia de atributos del cliente: edades distintas observadas por customer_id.
-- Una variación es una señal para revisar; sin fecha de nacimiento no puede validarse la edad real.
SELECT
    customer_id,
    COUNT(DISTINCT TRY_CONVERT(INT, customer_age)) AS edades_distintas,
    MIN(TRY_CONVERT(INT, customer_age)) AS edad_minima,
    MAX(TRY_CONVERT(INT, customer_age)) AS edad_maxima,
    MIN(TRY_CONVERT(DATE, transaction_date, 23)) AS primera_fecha,
    MAX(TRY_CONVERT(DATE, transaction_date, 23)) AS ultima_fecha
FROM dbo.raw_bank_fraud
GROUP BY customer_id
HAVING COUNT(DISTINCT TRY_CONVERT(INT, customer_age)) > 1
ORDER BY customer_id;
-- Resultado: 191.158 customer_id con más de una edad distinta y sin secuencialidad anual
-- (p. ej. 26 en una transacción y 48 en otra del mismo cliente). La edad no se comporta como
-- atributo estable del cliente; sin fecha de nacimiento no puede validarse cuál es correcta.
GO

-- 11. Coherencia de cuenta: variaciones de account_age_years por cliente.
-- La antigüedad podría ser un atributo fijo o una instantánea; interpretar el resultado según su definición.
SELECT
    customer_id,
    COUNT(DISTINCT TRY_CONVERT(DECIMAL(12,3), account_age_years)) AS antiguedades_distintas,
    MIN(TRY_CONVERT(DECIMAL(12,3), account_age_years)) AS antiguedad_minima,
    MAX(TRY_CONVERT(DECIMAL(12,3), account_age_years)) AS antiguedad_maxima,
    MIN(TRY_CONVERT(DATE, transaction_date, 23)) AS primera_fecha,
    MAX(TRY_CONVERT(DATE, transaction_date, 23)) AS ultima_fecha
FROM dbo.raw_bank_fraud
GROUP BY customer_id
HAVING COUNT(DISTINCT TRY_CONVERT(DECIMAL(12,3), account_age_years)) > 1
ORDER BY customer_id;
-- Resultado: 191.758 variaciones de account_age_years por cliente similares a las del fragmento 10,
-- también sin secuencia anual coherente. La antigüedad no se comporta como atributo fijo y
-- requiere una definición clara (fijo vs instantánea) antes de usarse en DimCustomer.
GO

-- 12. Coherencia transaccional: compara time_since_last_txn_hrs con la fila previa del cliente.
-- La comparación es diagnóstica: el CSV podría no contener todas las transacciones del historial.
WITH Transacciones AS
(
    SELECT
        r.customer_id,
        r.transaction_id,
        TRY_CONVERT(DECIMAL(18,3), r.time_since_last_txn_hrs) AS horas_desde_transaccion_anterior,
        CASE
            WHEN d.fecha IS NOT NULL AND tm.hora IS NOT NULL
            THEN DATEADD(SECOND,
                         DATEDIFF(SECOND, CAST('00:00:00' AS TIME), tm.hora),
                         CAST(d.fecha AS DATETIME2(0)))
        END AS fecha_hora_transaccion
    FROM dbo.raw_bank_fraud AS r
    CROSS APPLY (VALUES (TRY_CONVERT(DATE, r.transaction_date, 23))) AS d(fecha)
    CROSS APPLY (VALUES (TRY_CONVERT(TIME(0), r.transaction_time))) AS tm(hora)
), Ordenadas AS
(
    SELECT
        customer_id,
        transaction_id,
        horas_desde_transaccion_anterior,
        fecha_hora_transaccion,
        LAG(fecha_hora_transaccion) OVER
            (PARTITION BY customer_id ORDER BY fecha_hora_transaccion, transaction_id) AS fecha_hora_anterior
    FROM Transacciones
)
SELECT
    customer_id,
    transaction_id,
    fecha_hora_anterior,
    fecha_hora_transaccion,
    horas_desde_transaccion_anterior,
    DATEDIFF_BIG(SECOND, fecha_hora_anterior, fecha_hora_transaccion) / 3600.0 AS horas_segun_fechas,
    horas_desde_transaccion_anterior
        - DATEDIFF_BIG(SECOND, fecha_hora_anterior, fecha_hora_transaccion) / 3600.0 AS diferencia_horas
FROM Ordenadas
WHERE fecha_hora_anterior IS NOT NULL
  AND fecha_hora_transaccion > fecha_hora_anterior
ORDER BY customer_id, fecha_hora_transaccion, transaction_id;
-- Resultado: 801.338 horas transcurridas declaradas no cuadran con la diferencia real entre
-- fechas y horas consecutivas del mismo cliente; hay discrepancias sin sentido. Confirma que
-- time_since_last_txn_hrs no puede derivarse solo con las filas del CSV (historial posible
-- incompleto) y por eso queda excluido de KPI.
GO

-- 13. Coherencia transaccional: detecta disminuciones en num_prev_transactions por cliente.
-- Solo es una inconsistencia si el campo representa un contador acumulado y el historial está ordenado.
WITH Transacciones AS
(
    SELECT
        customer_id,
        transaction_id,
        TRY_CONVERT(INT, num_prev_transactions) AS transacciones_previas,
        TRY_CONVERT(DATE, transaction_date, 23) AS fecha,
        TRY_CONVERT(TIME(0), transaction_time) AS hora
    FROM dbo.raw_bank_fraud
), Ordenadas AS
(
    SELECT
        customer_id,
        transaction_id,
        transacciones_previas,
        fecha,
        hora,
        LAG(transacciones_previas) OVER
            (PARTITION BY customer_id ORDER BY fecha, hora, transaction_id) AS transacciones_previas_anterior
    FROM Transacciones
)
SELECT
    customer_id,
    transaction_id,
    fecha,
    hora,
    transacciones_previas_anterior,
    transacciones_previas
FROM Ordenadas
WHERE transacciones_previas_anterior IS NOT NULL
  AND transacciones_previas < transacciones_previas_anterior
ORDER BY customer_id, fecha, hora, transaction_id;
-- Resultado: 391.165 filas con disminución de num_prev_transactions entre transacciones
-- consecutivas del mismo cliente (p. ej. de 157 a 148), cuando un contador acumulado debería
-- aumentar. El campo no es un contador acumulado confiable y queda excluido de KPI.
GO

-- 14. Coherencia espacial: frecuencias de cada combinación país-ciudad.

SELECT DISTINCT country
FROM dbo.raw_bank_fraud;
GO

SELECT DISTINCT UPPER(city)
FROM dbo.raw_bank_fraud;
GO

SELECT
    country,
    city,
    COUNT_BIG(*) AS transacciones
FROM dbo.raw_bank_fraud
GROUP BY country, city
ORDER BY country, transacciones DESC, city;
GO

-- Ciudades asociadas a más de un país; revisar posibles homónimos, no son errores confirmados.
SELECT
    city,
    COUNT(DISTINCT country) AS paises_asociados,
    COUNT_BIG(*) AS transacciones
FROM dbo.raw_bank_fraud
GROUP BY city
HAVING COUNT(DISTINCT country) > 1
ORDER BY paises_asociados DESC, city;
-- Resultado: existen ciudades asociadas a más de un país (posibles homónimos, no errores
-- confirmados) y asignaciones de ciudad a países que no les corresponden. La geografía debe
-- normalizarse antes de poblar DimLocation.
GO

-- 15. Distribución de Métodos de Pago y Dispositivos para la Transacción
SELECT 
	payment_method AS metodo_pago, 
	device_type AS dispositivo, 
	COUNT_BIG(*) AS transferencias,
	MIN(transaction_amount) AS monto_minimo, 
	MAX(transaction_amount) AS monto_maximo
FROM dbo.raw_bank_fraud
GROUP BY payment_method, device_type
ORDER BY payment_method, device_type
-- Se observan discrepancias en las relaciones entre métodos de pago y dispositivos
-- Se observa que se han cargado aleatoriamente y no respetando la lógica 
-- (p ej. Mobile Payment por ATM)
GO

-- 16. Distribución de etiquetas: cuenta filas legítimas y fraudulentas.
-- fraud_type describe el resultado y no debe usarse como predictor de is_fraud.
SELECT
    SUM(CASE WHEN TRY_CONVERT(INT, is_fraud) = 0 THEN 1 ELSE 0 END) AS total_legitimas,
    SUM(CASE WHEN TRY_CONVERT(INT, is_fraud) = 1 THEN 1 ELSE 0 END) AS total_fraudes
FROM dbo.raw_bank_fraud;
-- Resultado: 944.745 transacciones legítimas (94,47%) y 55.255 fraudulentas (5,53%);
-- clase desbalanceada. fraud_type describe el resultado y no debe usarse como predictor de is_fraud. (Se mencionó en la ficha del conjunto de datos).
GO
