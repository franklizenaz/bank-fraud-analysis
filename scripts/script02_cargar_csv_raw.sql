/*
    Paso 2: crear la tabla raw y cargar el CSV original.
*/

-- Cargar la tabla raw_bank_fraud con los datos originales del CSV. Esta tabla no se toca en el resto del proyecto, sirve como referencia para la limpieza y transformación de datos.
USE [Aethel_Capital_Bank];
GO

-- Ajustar la ruta si se mueve el archivo. SQL Server debe tener acceso de lectura.
IF OBJECT_ID(N'dbo.raw_bank_fraud', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.raw_bank_fraud
    (
        transaction_id           NVARCHAR(100) NULL,
        customer_id              NVARCHAR(100) NULL,
        transaction_date         NVARCHAR(50) NULL,
        transaction_time         NVARCHAR(50) NULL,
        hour_of_day              NVARCHAR(20) NULL,
        is_weekend               NVARCHAR(10) NULL,
        is_night_transaction     NVARCHAR(10) NULL,
        country                  NVARCHAR(100) NULL,
        city                     NVARCHAR(100) NULL,
        merchant_category        NVARCHAR(100) NULL,
        payment_method           NVARCHAR(100) NULL,
        device_type              NVARCHAR(100) NULL,
        customer_age             NVARCHAR(20) NULL,
        credit_score             NVARCHAR(20) NULL,
        account_age_years        NVARCHAR(30) NULL,
        account_balance          NVARCHAR(40) NULL,
        transaction_amount       NVARCHAR(40) NULL,
        num_prev_transactions    NVARCHAR(20) NULL,
        transaction_freq_monthly NVARCHAR(30) NULL,
        distance_from_home_km    NVARCHAR(30) NULL,
        time_since_last_txn_hrs  NVARCHAR(30) NULL,
        is_international         NVARCHAR(10) NULL,
        failed_attempts          NVARCHAR(20) NULL,
        pin_changed_recently     NVARCHAR(10) NULL,
        is_fraud                 NVARCHAR(10) NULL,
        fraud_type               NVARCHAR(100) NULL
    );
END;
GO

-- Evita duplicar filas si se vuelve a ejecutar el script.
IF EXISTS (SELECT 1 FROM dbo.raw_bank_fraud)
    THROW 50001, 'La tabla raw_bank_fraud ya contiene datos. No se realizó otra carga.', 1;
GO

BULK INSERT dbo.raw_bank_fraud
FROM N'D:\workspace\courses\data-engineering\database-management\BC-2020610-01GEDA SQL Server\Sessions\S04\Project\data\bank_fraud.csv'
WITH
(
    FORMAT = 'CSV',        
    FIRSTROW = 2,           -- Salta los encabezados del CSV
    FIELDTERMINATOR = ',',  -- Cambia por ';' si tu Excel lo guardó con punto y coma
    ROWTERMINATOR = '0x0a',  -- Obliga a Windows a leer el salto de línea de Kaggle
    CODEPAGE = '65001',     -- Codificación UTF-8 para evitar errores con caracteres raros
    FIELDQUOTE = '"',
    TABLOCK
);
GO


-- Confirma la cantidad cargada.
SELECT COUNT_BIG(*) AS filas_cargadas
FROM dbo.raw_bank_fraud;
GO


-- Pequeño ajuste de datos

UPDATE dbo.raw_bank_fraud
SET
    transaction_id = LTRIM(RTRIM(transaction_id)),
    customer_id = LTRIM(RTRIM(customer_id)),
    transaction_date = LTRIM(RTRIM(transaction_date)),
    transaction_time = LTRIM(RTRIM(transaction_time)),
    hour_of_day = LTRIM(RTRIM(hour_of_day)),
    is_weekend = LTRIM(RTRIM(is_weekend)),
    is_night_transaction = LTRIM(RTRIM(is_night_transaction)),
    country = LTRIM(RTRIM(country)),
    city = LTRIM(RTRIM(city)),
    merchant_category = LTRIM(RTRIM(merchant_category)),
    payment_method = LTRIM(RTRIM(payment_method)),
    device_type = LTRIM(RTRIM(device_type)),
    customer_age = LTRIM(RTRIM(customer_age)),
    credit_score = LTRIM(RTRIM(credit_score)),
    account_age_years = LTRIM(RTRIM(account_age_years)),
    account_balance = LTRIM(RTRIM(account_balance)),
    transaction_amount = LTRIM(RTRIM(transaction_amount)),
    num_prev_transactions = LTRIM(RTRIM(num_prev_transactions)),
    transaction_freq_monthly = LTRIM(RTRIM(transaction_freq_monthly)),
    distance_from_home_km = LTRIM(RTRIM(distance_from_home_km)),
    time_since_last_txn_hrs = LTRIM(RTRIM(time_since_last_txn_hrs)),
    is_international = LTRIM(RTRIM(is_international)),
    failed_attempts = LTRIM(RTRIM(failed_attempts)),
    pin_changed_recently = LTRIM(RTRIM(pin_changed_recently)),
    is_fraud = LTRIM(RTRIM(is_fraud)),
    fraud_type = LTRIM(RTRIM(fraud_type));
GO
