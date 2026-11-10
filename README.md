# Análisis de Transacciones Bancarias y Detección de Fraude
> Proyecto de Data Analytics & Business Intelligence | Blur Consulting

Proyecto integrador de **Blur Consulting** para diseñar e implementar una solución analítica en SQL Server sobre transacciones bancarias sintéticas.

## Resumen

El proyecto transforma un conjunto de 1,000,000 de transacciones en un modelo dimensional tipo estrella. El flujo incluye carga, perfilamiento, limpieza, validación, transformación y consultas analíticas para comparar operaciones etiquetadas como legítimas o fraude.

El análisis busca apoyar la priorización de revisiones antifraude mediante señales como importe, canal de pago, dispositivo, horario, actividad internacional, categoría, intentos fallidos y cambio reciente de PIN. Los resultados son descriptivos y corresponden a datos sintéticos; no representan fraude confirmado ni decisiones automáticas de bloqueo.

## Entregables principales

- Base de datos y esquema `dw` en SQL Server.
- Modelo estrella con `FactTransaction` y las dimensiones de fecha/hora, cliente, ubicación, categoría de comercio y canal de pago.
- Proceso de carga, perfilamiento, limpieza y validación de datos.
- Métricas y consultas para el análisis transaccional y de fraude.
- Hallazgos y decisiones de negocio para orientar controles combinados de autenticación y revisión.

## Resultados destacados

- Se cargaron **1,000,000 de transacciones** sin registros omitidos.
- Se identificaron **55,255 transacciones etiquetadas como fraude** (**5.53%**).
- El importe promedio de las operaciones etiquetadas como fraude fue **228.079081**, frente a **203.358743** en las legítimas.
- Se corrigieron **899,937 inconsistencias geográficas** y **41,430 inconsistencias del indicador nocturno**.
- Las señales más relevantes para priorizar revisión fueron la combinación de importe, actividad internacional o nocturna, intentos fallidos, cambio reciente de PIN y ciertas categorías o canales.

## Estructura del proyecto

```text
project-sql-blur-consulting/
├── data/           Datos de origen
├── docs/           Contexto, diccionario y criterios del proyecto
├── presentation/   Material de presentación
├── reports/        Análisis BI y decisiones de negocio
└── scripts/        Scripts SQL de implementación y análisis
```

## Ejecución recomendada

Ejecutar los scripts en SQL Server en el siguiente orden:

1. `script01_crear_base_datos.sql`
2. `script02_cargar_csv_raw.sql`
3. `script03_perfilamiento_datos.sql`
4. `script04_limpieza_validacion.sql`
5. `script05_modelo_estrella.sql`
6. `script06_metricas_resultados.sql`

Los supuestos, validaciones, definiciones de variables y resultados detallados se encuentran en [`docs/`](docs/) y [`reports/`](reports/).

## Consideraciones de interpretación

- `is_fraud` es una etiqueta del dataset sintético, no una confirmación operativa.
- `fraud_type` describe el resultado y no debe utilizarse como predictor de `is_fraud`.
- Los hallazgos deben validarse con datos reales antes de aplicarse en producción.
- No se recomienda bloquear por una sola señal; el proyecto propone combinar señales y mantener revisión constante.

## Autores

- **Frankli Zeña**
- **Josefina Urquiza**

**Grupo de Estudio Data Analyst — Blur Consulting**
