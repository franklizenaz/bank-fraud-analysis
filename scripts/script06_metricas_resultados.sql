/*
    Paso 6: indicadores y consultas del caso de negocio.
    Ejecutar después de script05_modelo_estrella.sql.

    Los resultados describen este conjunto sintético. is_fraud no es una tasa real
    de fraude y los importes no representan pérdidas económicas.
    customer_age, account_age_years, num_prev_transactions y time_since_last_txn_hrs
    no se utilizan para KPI.
*/
USE [Aethel_Capital_Bank];
GO

-- 1. Transacciones cargadas y filas que no llegaron a la tabla de hechos.
SELECT
    COUNT_BIG(*) AS transacciones_cargadas,
    (SELECT COUNT_BIG(*) FROM dbo.raw_bank_fraud) - COUNT_BIG(*) AS filas_no_cargadas
FROM dw.FactTransaction;
-- Resultado: se cargaron las 1,000,000 transacciones en la tabla de hechos y no quedaron filas sin cargar.

-- 2. Importe total y promedio por transacción.
SELECT
    COUNT_BIG(*) AS transacciones,
    SUM(transaction_amount) AS importe_total,
    AVG(transaction_amount) AS importe_promedio
FROM dw.FactTransaction;

-- Mediana del importe.
SELECT TOP (1)
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY transaction_amount) OVER () AS importe_mediano
FROM dw.FactTransaction;
-- Resultado: el importe total fue 204,724,665.42; el importe promedio fue 204.724665 y la mediana 73.12.
GO

-- 3. Distribución mensual: volumen e importe.
SELECT
    MONTH(dt.transaction_date) AS mes,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
GROUP BY MONTH(dt.transaction_date)
ORDER BY importe_total DESC;
-- Resultado: agosto tuvo el mayor importe total con 17,564,275.50 (8.58%); febrero registró el menor importe, 15,811,223.17 (7.72%).
-- En volumen, enero concentró más transacciones (85,493; 8.55%) y febrero menos (77,550; 7.76%).

SELECT
    YEAR(dt.transaction_date) AS anio,
    MONTH(dt.transaction_date) AS mes,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
GROUP BY YEAR(dt.transaction_date), MONTH(dt.transaction_date)
ORDER BY importe_total DESC;
-- Resultado: julio de 2022 presentó el mayor importe mensual, con 3,578,891.33 (1.75% del importe total).

-- Distribución anual: volumen e importe.
SELECT
    YEAR(dt.transaction_date) AS anio,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
GROUP BY YEAR(dt.transaction_date)
ORDER BY anio;
-- Resultado: los cinco años mantienen una distribución equilibrada: cada uno representa aproximadamente 20% de transacciones e importe total.
-- 2020 registró 201,016 transacciones y 41,132,640.45; 2024 tuvo el mayor promedio, 205.569559.


-- Distribución por hora.
SELECT
    dt.hour_of_day,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
GROUP BY dt.hour_of_day
ORDER BY importe_total DESC;
-- Resultado: las 03:00 concentraron el mayor volumen (41,933; 4.19%) y el mayor importe (8,829,012.97; 4.31%).
-- Las 16:00 tuvieron menos transacciones (41,133; 4.11%) y las 08:00 el menor importe (8,376,726.29; 4.09%).

-- Distribución por país y ciudad.
SELECT
    l.country,
    l.city,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimLocation AS l ON f.location_key = l.location_key
GROUP BY l.country, l.city
ORDER BY importe_promedio DESC;
-- Resultado: Brazil/Rio lideró las tres métricas: 50,365 transacciones (5.04%), 10,600,732.48 de importe total (5.18%) y 210.478159 de importe promedio.

-- Distribución por método de pago.
SELECT
    p.payment_method,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS p ON f.payment_channel_key = p.payment_channel_key
GROUP BY p.payment_method
ORDER BY importe_total DESC;
-- Resultado: Credit Card concentró más transacciones (349,618; 34.96%) y mayor importe (71,554,168.73; 34.95%).
-- Crypto tuvo el importe promedio más alto (208.052957), mientras Cheque registró la menor actividad (29,638 transacciones; 2.96%).

-- Distribución por categoría de comercio.
SELECT
    m.merchant_category,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimMerchantCategory AS m ON f.merchant_category_key = m.merchant_category_key
GROUP BY m.merchant_category
ORDER BY importe_promedio DESC;
-- Resultado: Entertainment tuvo más transacciones (67,150; 6.72%); Electronics lideró importe total (44,524,739.65; 21.75%) e importe promedio (665.880113).
-- Crypto Exchange tuvo la menor cantidad de transacciones (66,308; 6.63%), con una diferencia reducida frente a las demás categorías.
GO

-- Distribución por dispositivo.
SELECT
    d.device_type,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS d ON f.payment_channel_key = d.payment_channel_key
GROUP BY d.device_type
ORDER BY importe_total DESC;
-- Resultado: Mobile concentró más transacciones (521,384; 52.14%) y mayor importe (106,981,432.42; 52.26%).
-- El valor NULL corresponde a las transacciones con Cheque en la normalización aplicada y representa 2.96% de transacciones y 2.90% del importe.
GO

-- 4. Prevalencia de la etiqueta en este conjunto sintético; no es una tasa real de fraude.
SELECT
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS filas_etiquetadas_fraude,
    COUNT_BIG(*) AS transacciones,
    CAST(100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_etiquetado_fraude
FROM dw.FactTransaction;
-- Resultado: 55,255 transacciones quedaron etiquetadas como fraude, equivalentes al 5.53% del total.

-- Comparación descriptiva de volumen e importes entre las dos etiquetas.
SELECT
    CASE WHEN is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction as f
GROUP BY is_fraud
ORDER BY is_fraud;
-- Resultado: las legítimas sumaron 944,745 transacciones, 192,122,155.77 de importe y promedio de 203.358743.
-- Las etiquetadas como fraude fueron 55,255, con 12,602,509.65 de importe y un promedio mayor de 228.079081.







-- Comparación por país
SELECT
    l.country,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimLocation AS l ON f.location_key = l.location_key
GROUP BY l.country, f.is_fraud
ORDER BY f.is_fraud DESC, importe_promedio DESC;
-- Resultado: USA tuvo el mayor número de transacciones etiquetadas como fraude (5,595; 0.56% del total y 10.13% del grupo fraude).
-- La distribución por país fue estable: USA, Brazil, Japan, Mexico, Germany y Canada concentraron los mayores volúmenes, con participaciones cercanas al 10% del grupo fraude y similares a las del grupo legítimo.
-- Australia registró el mayor importe total fraudulento (1,330,512.54; 0.65% del total y 10.56% del importe del grupo fraude) y el mayor importe promedio fraudulento (241.779491).
GO



-- Comparación por ciudad
SELECT
    l.city,
    l.country,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimLocation AS l ON f.location_key = l.location_key
GROUP BY l.city, l.country, f.is_fraud
ORDER BY f.is_fraud DESC, importe_promedio DESC;
-- Resultado: la distribución por ciudad fue estable, con diferencias porcentuales pequeñas entre las ciudades y entre ambos grupos de etiqueta.
-- Rio (Brazil) concentró el mayor volumen de transacciones etiquetadas como fraude (2,826; 0.28% del total y 5.11% del grupo fraude).
-- Sydney (Australia) registró el mayor importe total fraudulento (720,382.76; 0.35% del total y 5.72% del importe del grupo fraude), seguida por Rio con 670,470.19 (5.32% del importe del grupo fraude).
-- Sydney también presentó el mayor importe promedio fraudulento (262.434520), seguida por Mumbai (237.822187) y Rio (237.250598).
GO


-- Fraude y Legítimas por pais y ciudad
SELECT
    l.country,
    l.city,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimLocation AS l ON f.location_key = l.location_key
GROUP BY l.country, l.city, f.is_fraud
ORDER BY l.country, l.city, f.is_fraud;
-- Resultado: ciudades y países mantuvieron participaciones similares en los grupos legítimo y etiquetado como fraude, con una distribución estable en el dataset sintético.
GO





-- Comparación por método de pago.
SELECT
    p.payment_method,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS p ON f.payment_channel_key = p.payment_channel_key
GROUP BY p.payment_method, f.is_fraud
ORDER BY p.payment_method, f.is_fraud;
-- Resultado: Credit Card concentró el mayor número de filas etiquetadas como fraude (19,568; 35.41% del grupo fraude).
-- Mobile Payment tuvo el mayor importe promedio entre esas filas, con 233.645715.

-- Método de mayor número de transacciones legítimas y fraudulentas
SELECT
    p.payment_method,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS p ON f.payment_channel_key = p.payment_channel_key
GROUP BY p.payment_method, f.is_fraud
ORDER BY f.is_fraud DESC, transacciones DESC;
-- Resultado: dentro de las legítimas y las etiquetadas como fraude, Credit Card fue el método con mayor volumen.
-- En las transacciones etiquetadas como fraude concentró 4,503,931.53 de importe total (35.74% del importe del grupo).
GO

-- Comparación por dispositivo.
SELECT
    p.device_type,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS p ON f.payment_channel_key = p.payment_channel_key
GROUP BY p.device_type, f.is_fraud
ORDER BY f.is_fraud DESC, importe_total DESC;
-- Resultado: Mobile concentró más transacciones etiquetadas como fraude (28,932; 52.36% del grupo fraude).
-- ATM y el valor NULL fueron los grupos de menor participación por volumen e importe en ambos grupos de etiqueta.
GO


-- Diferencias entre fraudes y legitimas por dispositivo
SELECT
    p.device_type,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimPaymentChannel AS p ON f.payment_channel_key = p.payment_channel_key
GROUP BY p.device_type, f.is_fraud
ORDER BY p.device_type, f.is_fraud DESC;
-- Resultado: en el grupo fraude, el valor NULL sumó 368,794.77 de importe, por encima de ATM (355,320.17), aunque ambos tuvieron una participación reducida.
GO

-- Comparación por categoría de comercio.
SELECT
    m.merchant_category,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimMerchantCategory AS m ON f.merchant_category_key = m.merchant_category_key
GROUP BY m.merchant_category, f.is_fraud
ORDER BY f.is_fraud DESC, importe_promedio DESC;
-- Resultado: Jewelry tuvo el mayor volumen de transacciones etiquetadas como fraude (5,821; 10.53% del grupo).
-- Electronics presentó el mayor importe promedio fraudulento (733.673024), seguido por Travel y Jewelry.
GO


-- Fraude y Legítimas por categorías
SELECT
    m.merchant_category,
    CASE WHEN f.is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction AS f
JOIN dw.DimMerchantCategory AS m ON f.merchant_category_key = m.merchant_category_key
GROUP BY m.merchant_category, f.is_fraud
ORDER BY m.merchant_category, f.is_fraud;
-- Resultado: ATM Withdrawal, Crypto Exchange y Jewelry aumentaron su participación en el grupo fraude frente al grupo legítimo.
-- Sus participaciones fueron 10.50%, 10.38% y 10.53% del grupo fraude, respectivamente.
GO

-- 5. Señales por etiqueta: proporción internacional, nocturna y con cambio reciente de PIN.
SELECT
    f.is_fraud,
    COUNT_BIG(*) AS transacciones,
    CAST(100.0 * SUM(CASE WHEN f.is_international = 1 THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_internacional,
    CAST(100.0 * SUM(CASE WHEN dt.is_night_transaction = 1 THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_nocturno,
    CAST(100.0 * SUM(CASE WHEN f.pin_changed_recently = 1 THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_pin_cambiado
FROM dw.FactTransaction AS f
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
GROUP BY f.is_fraud
ORDER BY f.is_fraud;
-- Resultado: frente a las legítimas, las filas etiquetadas como fraude mostraron mayor proporción internacional (26.76% vs. 14.31%), nocturna (47.95% vs. 32.51%) y con PIN cambiado (12.18% vs. 7.80%).

-- Promedio de intentos fallidos y distancia al hogar por etiqueta.
SELECT
    is_fraud,
    AVG(CAST(failed_attempts AS DECIMAL(10,2))) AS intentos_fallidos_promedio,
    AVG(distance_from_home_km) AS distancia_promedio_km
FROM dw.FactTransaction
GROUP BY is_fraud
ORDER BY is_fraud;
-- Resultado: el promedio de intentos fallidos fue 0.820812 en fraude y 0.354294 en legítimas.
-- La distancia promedio fue similar: 19.979719 km en fraude y 20.011654 km en legítimas.


-- Promedio de intentos fallidos de lso que hicieron más de 1 intento.
SELECT
    is_fraud,
    SUM(CAST(failed_attempts AS DECIMAL(10,2))) /
        COUNT_BIG(*) AS intentos_fallidos_promedio
FROM dw.FactTransaction
WHERE failed_attempts > 0
GROUP BY is_fraud
ORDER BY is_fraud;
-- Resultado: al considerar solo filas con al menos un intento fallido, el promedio fue 2.372071 en fraude y 1.850876 en legítimas.


-- Etiquetas según la cantidad de intentos fallidos.
SELECT
    failed_attempts,
    CASE WHEN is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction as f
GROUP BY failed_attempts, is_fraud
ORDER BY is_fraud DESC, transacciones DESC;
-- Resultado: en las filas etiquetadas como fraude predominó cero intentos fallidos (36,135; 65.40% del grupo), seguido por 2 intentos (7,308; 13.23%).
-- Los niveles de 2 y 3 intentos tuvieron una participación mayor en fraude que en legítimas.
GO


-- Fraude y Legítimas por cantidad de intentos fallidos.
SELECT
    failed_attempts,
    CASE WHEN is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction as f
GROUP BY failed_attempts, is_fraud
ORDER BY failed_attempts, is_fraud;
-- Resultado: la distribución confirma que cero intentos reúne el mayor volumen en ambos grupos; no obstante, 2 y 3 intentos son relativamente más frecuentes en el grupo fraude.
GO


-- Etiquetas según la cantidad de intentos fallidos (importes).
SELECT
    failed_attempts,
    CASE WHEN is_fraud = 1 THEN N'Etiquetada como fraude' ELSE N'Etiquetada como legítima' END AS grupo,
    COUNT_BIG(*) AS transacciones,
    CAST(
        COUNT_BIG(*) * 100.0 /
        SUM(COUNT_BIG(*)) OVER()
        AS DECIMAL(6,2)
    ) AS [% transacciones],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    COUNT_BIG(*) * 100.0 /
                    (SELECT COUNT_BIG(*) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_transacciones_x_grupo],
    SUM(f.transaction_amount) AS importe_total,
    CAST(
        SUM(f.transaction_amount) * 100.0 /
        SUM(SUM(f.transaction_amount)) OVER()
        AS DECIMAL(6,2)
    ) AS [% importe_total],
    CASE
        WHEN is_fraud = 0 
            THEN CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=0)
                    AS DECIMAL(6,2)
                    )
        ELSE CAST(
                    SUM(f.transaction_amount) * 100.0 /
                    (SELECT SUM(transaction_amount) FROM dw.FactTransaction WHERE is_fraud=1)
                    AS DECIMAL(6,2)
                 )
    END AS [%_importe_total_x_grupo],
    AVG(f.transaction_amount) AS importe_promedio
FROM dw.FactTransaction as f
GROUP BY failed_attempts, is_fraud
ORDER BY is_fraud DESC, importe_total DESC;
-- Resultado: las filas fraudulentas con cero intentos acumularon 8,410,419.14 (66.74% del importe fraudulento).
-- Entre los niveles con intentos, 2 intentos concentró el mayor importe fraudulento: 1,577,156.05 (12.51% del grupo).
GO

-- 6. Clientes con más transacciones: volumen, importe total y promedio.
SELECT TOP (100)
    c.customer_id,
    COUNT_BIG(*) AS transacciones,
    SUM(f.transaction_amount) AS importe_total,
    AVG(f.transaction_amount) AS importe_promedio,
    SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS numero_fraudes
FROM dw.FactTransaction AS f
JOIN dw.DimCustomer AS c ON f.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY transacciones DESC, importe_total DESC;
-- Resultado: CUST00165481 fue el cliente con más transacciones, con 19 operaciones.

-- Clientes con mayor importe acumulado.
SELECT TOP (100)
    c.customer_id,
    COUNT_BIG(*) AS transacciones,
    SUM(f.transaction_amount) AS importe_total,
    AVG(f.transaction_amount) AS importe_promedio,
    SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS numero_fraudes
FROM dw.FactTransaction AS f
JOIN dw.DimCustomer AS c ON f.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY importe_total DESC, transacciones DESC;
-- Resultado: CUST00163991 tuvo el mayor importe acumulado, 47,555.22, distribuido en 11 transacciones.

-- Clientes con mayor importe promedio por transacción.
SELECT TOP (100)
    c.customer_id,
    COUNT_BIG(*) AS transacciones,
    SUM(f.transaction_amount) AS importe_total,
    AVG(f.transaction_amount) AS importe_promedio,
    SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS numero_fraudes
FROM dw.FactTransaction AS f
JOIN dw.DimCustomer AS c ON f.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY importe_promedio DESC, transacciones DESC;
-- Resultado: CUST00073756 tuvo el mayor importe promedio, 9,712.600000, pero solo registró una transacción.

-- Participación de cada cliente: cantidades absolutas frente a porcentajes del total.
SELECT TOP (100)
    c.customer_id,
    COUNT_BIG(*) AS transacciones,
    SUM(f.transaction_amount) AS importe_total,
    CAST(100.0 * COUNT_BIG(*) / (SELECT COUNT_BIG(*) FROM dw.FactTransaction) AS DECIMAL(6,2)) AS porcentaje_transacciones,
    CAST(100.0 * SUM(f.transaction_amount) / (SELECT SUM(transaction_amount) FROM dw.FactTransaction) AS DECIMAL(6,2)) AS porcentaje_importe_total
FROM dw.FactTransaction AS f
JOIN dw.DimCustomer AS c ON f.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY transacciones DESC, importe_total DESC;
-- Resultado: la participación de los principales clientes es extremadamente pequeña frente al histórico de 1,000,000 de transacciones.
-- Los clientes con más volumen, mayor importe acumulado y mayor promedio no coinciden; la recurrencia no implica necesariamente importes más altos.
GO

-- 7. Controles de calidad: IDs vacíos o repetidos en raw.
SELECT
    SUM(CASE WHEN transaction_id IS NULL OR transaction_id = N'' THEN 1 ELSE 0 END) AS ids_vacios,
    (SELECT COUNT_BIG(*)
     FROM
     (
         SELECT transaction_id
         FROM dbo.raw_bank_fraud
         GROUP BY transaction_id
         HAVING COUNT_BIG(*) > 1
     ) AS ids_repetidos) AS identificadores_repetidos
FROM dbo.raw_bank_fraud;
-- Resultado: no se detectaron IDs vacíos ni identificadores repetidos en la tabla raw.

-- Inconsistencias temporales y países corregidos según la ciudad.
-- is_weekend se conserva como ya fue validado en script03.
SELECT
    COUNT_BIG(*) AS transacciones,
    SUM(CASE WHEN CAST(r.is_night_transaction AS BIT) <> dt.is_night_transaction THEN 1 ELSE 0 END) AS noche_inconsistente,
    CAST(100.0 * SUM(CASE WHEN CAST(r.is_night_transaction AS BIT) <> dt.is_night_transaction THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_noche_inconsistente,
    SUM(CASE WHEN r.country <> l.country THEN 1 ELSE 0 END) AS pais_corregido_por_ciudad,
    CAST(100.0 * SUM(CASE WHEN r.country <> l.country THEN 1 ELSE 0 END) / COUNT_BIG(*) AS DECIMAL(6,2)) AS porcentaje_pais_corregido
FROM dbo.raw_bank_fraud AS r
JOIN dbo.stg_bank_fraud_clean AS s ON r.transaction_id = s.transaction_id
JOIN dw.FactTransaction AS f ON s.transaction_id = f.transaction_id
JOIN dw.DimDateTime AS dt ON f.datetime_key = dt.datetime_key
JOIN dw.DimLocation AS l ON f.location_key = l.location_key;
-- Resultado: se corrigieron 41,430 indicadores nocturnos inconsistentes (4.14%) y 899,937 países inconsistentes con su ciudad (89.99%).
-- Tras la normalización, cada uno de los 10 países queda asociado con sus dos ciudades correspondientes.
GO
