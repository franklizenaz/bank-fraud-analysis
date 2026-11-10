# Diccionario de variables — Bank Transaction Fraud Detection Dataset

## 1. Contexto de uso
**Fuente:** [Bank Transaction Fraud Detection Dataset — Kaggle](https://www.kaggle.com/datasets/nafiulislam490/bank-transaction-fraud-detection-dataset). 
**Análisis:** Para ejecutar las consultas es necesario descargar la data de la fuente descrita y colocarla en esta misma carpeta con el nombre ``bank_fraud.csv``.

## 2. Convenciones

- Los tipos indicados corresponden al modelo físico SQL Server creado en `script05_modelo_estrella.sql`.
- Los indicadores `is_*` y `pin_changed_recently` se almacenan como `BIT` en SQL Server y deben contener valores 0/1.
- **PK** = clave primaria; **FK** = clave foránea; **NK** = clave natural de origen.
- La ubicación dimensional corresponde al modelo estrella implementado en el esquema `dw`.
- Los campos derivados o redundantes deben validarse contra su campo fuente.
- `DimCustomer` conserva una fila por `customer_id`; edad, puntaje y antigüedad se toman de la transacción más reciente. No se usarán en KPI.

## 3. Identificadores

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_id` | `NVARCHAR(100)` | NK única en `dw.FactTransaction` | Identificador único de la transacción; permite rastrear el registro de origen. | Revisar nulos y duplicados. No es una medida ni predictor. |
| `customer_id` | `NVARCHAR(100)` | NK única en `dw.DimCustomer`; FK mediante `customer_key` | Identificador del cliente asociado a la transacción; permite agrupar actividad simulada por cliente. | Si sus atributos cambian, `DimCustomer` toma los valores de la última fecha y hora observadas. No identifica a una persona real. |

## 4. Tiempo

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_date` | `DATE` | Atributo de `DimDateTime` | Fecha de la transacción; base de tendencias por día, mes, trimestre y año. | Validar conversión y rango 2020–2024 indicado por la ficha. |
| `transaction_time` | `TIME(0)` | Atributo de `dw.DimDateTime` | Hora de la transacción; permite analizar actividad intradía. | Validar formato y concordancia con `hour_of_day`. |
| `hour_of_day` | `TINYINT` | Atributo derivable de `dw.DimDateTime` | Hora numérica del día, entre 0 y 23. | Se calcula desde `transaction_time`. |
| `is_weekend` | `BIT` | Atributo de `dw.DimDateTime` | Indica sábado o domingo según la descripción. | Se conserva como fue validado en el perfilamiento. |
| `is_night_transaction` | `BIT` | Atributo de `dw.DimDateTime` | Marca transacciones en el intervalo nocturno descrito. | Se calcula desde `transaction_time`; el perfilamiento encontró diferencias con el indicador original. |

## 5. Cliente y cuenta

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `customer_age` | `INT` | `dw.DimCustomer` | Edad atribuida al cliente. Se almacena como atributo del perfil, pero no se usará en KPI. | No inferir una edad correcta sin fecha de nacimiento. |
| `credit_score` | `INT` | `dw.DimCustomer` | Puntaje crediticio. | No tratarlo como evaluación crediticia real. |
| `account_age_years` | `DECIMAL(6,2)` | `dw.DimCustomer` | Antigüedad de la cuenta en años. Se almacena como atributo del perfil, pero no se usará en KPI. | No intentar corregir variaciones sin una fecha de apertura confiable. |

## 6. Ubicación, comercio, pago y dispositivo

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `country` | `NVARCHAR(100)` | `dw.DimLocation` | País asociado al registro. | La relación país-ciudad se normaliza durante la limpieza. |
| `city` | `NVARCHAR(100)` | `dw.DimLocation` | Ciudad asociada al registro. | Validar relación con país; no inferir residencia real ni coordenadas. |
| `merchant_category` | `NVARCHAR(100)` | `dw.DimMerchantCategory` | Categoría del comercio. | Estandarizar valores; no asumir que identifica un comercio individual. |
| `payment_method` | `NVARCHAR(100)` | `dw.DimPaymentChannel` | Método de pago. | Se almacena junto con `device_type` en el canal de pago. |
| `device_type` | `NVARCHAR(100)` NULL | `dw.DimPaymentChannel` | Tipo de dispositivo o terminal asociado al método de pago. | Puede ser NULL; la clave dimensional identifica la combinación método-dispositivo. |

## 7. Importe y actividad transaccional

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_amount` | `DECIMAL(18,2)` | Medida en `dw.FactTransaction` | Importe de la transacción. Permite calcular sumas, promedios, medianas y distribuciones por segmento. | Revisar nulos, negativos y extremos. La ficha no especifica moneda; no asignarla sin confirmación. |
| `account_balance` | `DECIMAL(18,2)` | Atributo/medida no aditiva en `dw.FactTransaction` | Saldo de cuenta observado asociado al registro. | No sumar entre transacciones como flujo monetario. |
| `num_prev_transactions` | `INT` | Atributo de evento en `dw.FactTransaction` | Número total de transacciones previas según el campo. No se usará en KPI. | No asumir que puede reconstruirse con las filas del CSV. |
| `transaction_freq_monthly` | `DECIMAL(12,3)` | Atributo de evento en `dw.FactTransaction` | Frecuencia mensual promedio de transacciones. | Validar rango y definición del periodo. |

## 8. Señales de comportamiento y seguridad

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `distance_from_home_km` | `DECIMAL(12,3)` | Atributo de evento en `dw.FactTransaction` | Distancia en kilómetros respecto de la ubicación del hogar del cliente. | Validar no negatividad y extremos. |
| `time_since_last_txn_hrs` | `DECIMAL(12,3)` | Atributo de evento en `dw.FactTransaction` | Horas desde la transacción anterior. No se usará en KPI. | No corregirla comparando únicamente con las filas disponibles en el CSV. |
| `is_international` | `BIT` | Indicador en `dw.FactTransaction` | Indica si la transacción está marcada como internacional. | La definición operacional no está detallada. |
| `failed_attempts` | `INT` | Atributo de evento en `dw.FactTransaction` | Intentos fallidos asociados al evento. | Validar no negatividad y rango. |
| `pin_changed_recently` | `BIT` | Indicador en `dw.FactTransaction` | Indica si el PIN se cambió recientemente. | La ventana temporal de “recientemente” no está especificada. |

## 9. Etiquetas de resultado

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `is_fraud` | `BIT` | Etiqueta en `dw.FactTransaction` | 1 = fraude y 0 = legítimo según el dataset; permite comparar grupos dentro del conjunto. | Describirlo como etiqueta sintética, no fraude confirmado. |
| `fraud_type` | `NVARCHAR(100)` NULL | Resultado en `dw.FactTransaction` | Tipo de fraude descrito para filas etiquetadas. | Validar nulos y compatibilidad con `is_fraud`. **No usar como predictor de `is_fraud`**, pues revela el resultado. |

## 10. Distribución sugerida en el modelo estrella

### `FactTransaction`

**Grano:** una fila por transacción del archivo.

- **PK:** `transaction_key` (clave sustituta).
- **NK única:** `transaction_id`.
- **FK:** `datetime_key`, `customer_key`, `location_key`, `merchant_category_key`, `payment_channel_key`.
- **Medidas/atributos:** `transaction_amount`, `account_balance`, `num_prev_transactions`, `transaction_freq_monthly`, `distance_from_home_km`, `time_since_last_txn_hrs`, `is_international`, `failed_attempts`, `pin_changed_recently`, `is_fraud`, `fraud_type`.

### Dimensiones

| Dimensión | PK propuesta | NK / campos fuente principales |
|---|---|---|
| `DimDateTime` | `datetime_key` | `transaction_date`, `transaction_time`, `hour_of_day`, `is_weekend`, `is_night_transaction` |
| `DimCustomer` | `customer_key` | `customer_id`, `customer_age`, `credit_score`, `account_age_years` (perfil observado) |
| `DimLocation` | `location_key` | `country`, `city` |
| `DimMerchantCategory` | `merchant_category_key` | `merchant_category` |
| `DimPaymentChannel` | `payment_channel_key` | `payment_method`, `device_type` |

`fraud_type` puede permanecer como atributo de resultado en la tabla de hechos. Crear una dimensión aparte solo si el análisis necesita un catálogo separado. En ambos diseños, excluirlo de predictores de `is_fraud`.

## 11. Advertencias analíticas

1. **Naturaleza sintética:** describir hallazgos como patrones observados en datos simulados.
2. **Posible fuga de información:** la ficha dice que algunas señales se generaron correlacionadas con la probabilidad de fraude; no interpretar su asociación como causal ni independiente.
3. **Campos derivados:** `hour_of_day` e `is_night_transaction` se calculan desde `transaction_time`; `is_weekend` se conserva como fue validado en el perfilamiento.
4. **Etiqueta y tipo:** `fraud_type` contiene información del resultado y debe excluirse de cualquier predicción de `is_fraud`.
5. **Definiciones ausentes:** no asumir moneda, ventana de “recientemente” ni definiciones operativas no documentadas.
6. **Esquema físico:** el modelo implementado usa SQL Server, el esquema `dw` y seis tablas: `DimDateTime`, `DimCustomer`, `DimLocation`, `DimMerchantCategory`, `DimPaymentChannel` y `FactTransaction`.
7. **Grano:** `FactTransaction` contiene una fila por transacción y `transaction_id` es su clave natural única.
