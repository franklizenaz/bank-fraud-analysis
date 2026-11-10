### Contexto del negocio

**Aethel Capital Bank** es una entidad financiera que opera en varios países y procesa transacciones mediante distintos canales, dispositivos y categorías de comercio. A medida que crece su actividad, el banco necesita organizar la información transaccional para entender mejor cómo se comporta el uso de sus servicios y cómo priorizar operaciones que ameritan una revisión adicional.

El área de prevención de riesgos recibe señales de distinta naturaleza: **montos de transacción, hora y fecha, ubicación, método de pago, tipo de dispositivo, actividad internacional, distancia respecto del hogar registrado, intentos fallidos y cambios recientes de PIN**. Analizadas por separado, estas señales ofrecen una visión parcial; consolidadas en un modelo de datos común, pueden ayudar a describir patrones, comparar segmentos y señalar transacciones que se apartan de los perfiles representados en el conjunto.

El proyecto propone integrar esas variables en un modelo dimensional tipo estrella. Sobre ella se realizarán controles de calidad, consultas e indicadores para responder preguntas como: *qué segmentos concentran mayor volumen e importe; cómo se distribuyen las transacciones según canal, ubicación, categoría y horario; y qué características aparecen con mayor frecuencia en las filas que el dataset etiqueta como fraude*. 

La finalidad empresarial del análisis sería ayudar a los equipos de operaciones a **priorizar revisiones y comprender los patrones registrados**, dejando cualquier decisión sobre una transacción bajo revisión humana.

### Problema de negocio

**Aethel Capital Bank** carece de una vista integrada que permita comparar de manera consistente sus transacciones según el momento, el cliente, la ubicación, el tipo de dispositivo, el método de pago y la categoría del comercio. Sin esa estructura, resulta más difícil distinguir patrones de actividad, detectar problemas de calidad de datos y organizar señales para análisis posterior.

### Objetivo del análisis

Diseñar e implementar un flujo SQL que limpie, valide y transforme los registros en un modelo estrella; calcular indicadores transaccionales y comparar los patrones asociados a la etiqueta `is_fraud`; y presentar hallazgos que orienten la priorización analítica en el escenario ficticio planteado.

### Alcance y uso de los resultados

El trabajo utilizará el conjunto sintético publicado en Kaggle, descrito como un millón de transacciones simuladas de 2020 a 2024, con variables transaccionales, temporales, geográficas y de comportamiento. Su campo `is_fraud` permitirá comparar grupos etiquetados dentro del dataset. El propio material describe relaciones generadas entre la etiqueta y señales como el importe, las operaciones nocturnas o internacionales, los intentos fallidos y la categoría del comercio. 
 [Dataset en Kaggle](https://www.kaggle.com/datasets/nafiulislam490/bank-transaction-fraud-detection-dataset) · [Descripción y diccionario publicados](https://github.com/zzfcharlie/kaggle-fetch/blob/master/out_fraud_50/datasets/nafiulislam490__bank-transaction-fraud-detection-dataset.md)

### Preguntas de negocio

#### Generales

1. ¿Cómo se distribuyen el número, el importe total y el importe promedio de las transacciones por fecha, hora, país, ciudad, método de pago, dispositivo y categoría de comercio?
2. ¿Qué diferencias descriptivas hay entre las transacciones etiquetadas como fraude y las etiquetadas como legítimas?
3. ¿Qué diferencias descriptivas se observan entre las transacciones etiquetadas como fraude y legítimas según los intentos fallidos, las operaciones internacionales, el horario, la distancia y los cambios recientes de PIN?
4. ¿Qué clientes o segmentos concentran más actividad o importe, y qué cambia al comparar cantidades absolutas con promedios y porcentajes?
5. ¿Qué valores nulos, duplicados o inconsistencias deben resolverse o marcarse antes de calcular los indicadores?


#### Específicas 

1. ¿Qué factores permiten identificar transacciones que requieren autenticación adicional?
2. ¿En qué métodos de pago y categorías debemos priorizar los controles antifraude?
3. ¿Cómo proteger el canal móvil sin afectar la mayoría de las operaciones legítimas?
4. ¿Qué diferencias geográficas justifican controles adicionales por país o ciudad?
5. ¿Qué controles de calidad deben aplicarse antes de usar estos datos para tomar decisiones?