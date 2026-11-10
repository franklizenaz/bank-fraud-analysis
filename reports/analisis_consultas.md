# Análisis y Observaciones BI del Caso

## 1. Carga de datos
Todas las 1,000,000 se cargaron sin falta.
- **filas_no_cargadas:** 0

## 2. Métricas generales
- **Total:** 204,724,665.42
- **Promedio:** 204.724665
- **Mediano:** 73.12

## 3. Análisis temporal

### Transacciones por mes
- **Más transacciones:** Enero — 8.55% de las transacciones totales (85,493)
- **Menos transacciones:** Febrero — 7.76% de las transacciones totales (77,550)

### Importe total por mes
- **Mayor importe total:** Agosto — 8.58% (17,564,275.50)
- **Menos importe total:** Febrero — 7.72% (15,811,223.17)

### Observación puntual
- **Julio 2022** tuvo el mayor importe total representando el **1.75%** (3,578,891.33) de todos los importes por ventas registradas.

### Transacciones por año
| año | transacciones | %_transacciones | importe_total | %_importe_total | importe_promedio |
|---|---|---|---|---|---|
| 2020 | 201,016 | 20.10 | 41,132,640.45 | 20.09 | 204.623713 |
| 2021 | 199,351 | 19.94 | 40,775,502.77 | 19.92 | 204.541250 |
| 2022 | 200,635 | 20.06 | 40,947,282.24 | 20.00 | 204.088430 |
| 2023 | 199,673 | 19.97 | 40,894,087.47 | 19.98 | 204.805294 |
| 2024 | 199,325 | 19.93 | 40,975,152.49 | 20.01 | 205.569559 |

### Transacciones por hora
- **Más transacciones:** 3am — 41,933 (4.19%)
- **Más importe:** 3am — 8,829,012.97 (4.31%)
- **Menos transacciones:** 16:00 pm — 41,133 (4.11%)
- **Menos importe:** 8am — 8,376,726.29 (4.09%)

## 4. Análisis geográfico

- **Brazil/Río:** 50,365 transacciones (5.04% del total)
- **Brazil/Río:** 10,600,732.48 de importe total (5.18% del total)
- **Brazil/Río:** 210.478159 de importe promedio

### Ranking por importe promedio
| País | Ciudad | Importe promedio |
|---|---|---|
| Brazil | Rio | 210.478159 |
| UK | London | 208.536631 |
| Mexico | Guadalajara | 207.344565 |
| India | Delhi | 206.191318 |
| Japan | Tokyo | 206.071632 |
| Germany | Berlin | 205.711725 |
| Australia | Melbourne | 205.511742 |
| Australia | Sydney | 205.406955 |
| Japan | Osaka | 204.699882 |
| India | Mumbai | 204.551745 |
| Brazil | São Paulo | 203.910918 |
| UK | Manchester | 203.292102 |
| Mexico | Mexico City | 203.247129 |
| Germany | Munich | 203.246619 |
| USA | New York | 203.240568 |
| USA | Los Angeles | 202.783766 |
| Canada | Toronto | 202.772063 |
| France | Lyon | 202.759894 |
| Canada | Vancouver | 202.729086 |
| France | Paris | 201.953538 |

**Brazil / Río lidera las tres métricas:** más transacciones (50,365; 5.04%), mayor importe total (10,600,732.48; 5.18%) y mayor importe promedio (210.478159).

## 5. Análisis por método de pago

- **Más transacciones:** Credit Card — 349,618 transacciones (34.96% del total)
- **Más importe total:** Credit_Card — 71,554,168.73 (34.95% del total)
- **Más importe promedio:** Crypto — 208.052957
- **Cheque** quedó por debajo del promedio de todos, como sigue en la siguiente tabla:

| Metodo_pago | transacciones | %_transacciones | importe_total | %_importe_total | importe_promedio |
|---|---|---|---|---|---|
| Credit Card | 349,618 | 34.96 | 71,554,168.73 | 34.95 | 204.663858 |
| Debit Card | 300,860 | 30.09 | 61,435,286.95 | 30.01 | 204.198919 |
| Bank Transfer | 150,029 | 15.00 | 30,706,925.95 | 15.00 | 204.673269 |
| Mobile Payment | 119,697 | 11.97 | 24,652,345.66 | 12.04 | 205.956253 |
| Crypto | 50,158 | 5.02 | 10,435,520.26 | 5.10 | 208.052957 |
| Cheque | 29,638 | 2.96 | 5,940,417.87 | 2.90 | 200.432480 |

## 6. Análisis por categoría

- **Más transacciones:** Entertainment — 67,150 (6.72%)
- **Mayor importe:** Electronics — 44,524,739.65 (21.75%)
- **Mayor importe promedio:** Electronics, igual que el importe total, con **665.880113**.
- **Menor actividad:** Crypto Exchange, pero por muy poco; la verdad todas estuvieron cercanas. Su número de transacciones: 66,308 (6.63%)

## 7. Análisis por device type

- **Más transacciones:** Mobile — con una gran diferencia respecto a los demás, pues hizo 521,384 transacciones, representando el 52.14% del total.
- **Más importe:** Mobile — 106,981,432.42 (52.26%)
- Las filas **device type NULL** se trataron como cheques físicos clásicos, los cuales son poco recurrentes y lo demuestran siendo apenas el 2.96% de las transacciones y 2.9% de los ingresos del histórico.

## 8. Análisis de fraude

- **55,255** etiquetadas como fraude
- Representan el **5.53%**

| Grupo | transacciones | %_transacciones | importe_total | %_importe_total | importe_promedio |
|---|---|---|---|---|---|
| Etiquetada como legítima | 944,745 | 94.47 | 192,122,155.77 | 93.84 | 203.358743 |
| Etiquetada como fraude | 55,255 | 5.53 | 12,602,509.65 | 6.16 | 228.079081 |

## 9. Fraude por método de pago

### Legítimas y fraudulentas por método
| Metodo_Pago | Grupo | transacciones | %_transacciones | importe_total | %_importe_total | importe_promedio |
|---|---|---|---|---|---|---|
| Bank Transfer | Etiquetada como legítima | 141,768 | 14.18 | 28,806,358.58 | 14.07 | 203.193658 |
| Bank Transfer | Etiquetada como fraude | 8,261 | 0.83 | 1,900,567.37 | 0.93 | 230.065049 |
| Cheque | Etiquetada como legítima | 27,958 | 2.80 | 5,571,623.10 | 2.72 | 199.285467 |
| Cheque | Etiquetada como fraude | 1,680 | 0.17 | 368,794.77 | 0.18 | 219.520696 |
| Credit Card | Etiquetada como legítima | 330,050 | 33.01 | 67,050,237.20 | 32.75 | 203.151756 |
| Credit Card | Etiquetada como fraude | 19,568 | 1.96 | 4,503,931.53 | 2.20 | 230.168209 |
| Crypto | Etiquetada como legítima | 47,400 | 4.74 | 9,812,628.43 | 4.79 | 207.017477 |
| Crypto | Etiquetada como fraude | 2,758 | 0.28 | 622,891.83 | 0.30 | 225.849104 |
| Debit Card | Etiquetada como legítima | 284,440 | 28.44 | 57,763,547.86 | 28.22 | 203.078146 |
| Debit Card | Etiquetada como fraude | 16,420 | 1.64 | 3,671,739.09 | 1.79 | 223.613830 |
| Mobile Payment | Etiquetada como legítima | 113,129 | 11.31 | 23,117,760.60 | 11.29 | 204.348669 |
| Mobile Payment | Etiquetada como fraude | 6,568 | 0.66 | 1,534,585.06 | 0.75 | 233.645715 |

### Observaciones
- En **tarjeta de crédito (Credit_Card)** se concentra el mayor número de transacciones etiquetadas como fraudulentas, y tiene sentido ya que en parte son las que representan más del 50% de transacciones en general, siendo etiquetadas como fraude **19,568** (1.96% del total y 35.41% de las etiquetadas como fraude).
- **Mobile Payment** tiene el mayor importe promedio de las etiquetadas como fraude: **233.645715**.

### Más información
| Metodo_Pago | Grupo | transacciones | %_transacciones | %_transacciones_x_grupo | importe_total | %_importe_total | %_importe_total_x_grupo | importe_promedio |
|---|---|---|---|---|---|---|---|---|
| Credit Card | Etiquetada como fraude | 19,568 | 1.96 | 35.41 | 4,503,931.53 | 2.20 | 35.74 | 230.168209 |
| Debit Card | Etiquetada como fraude | 16,420 | 1.64 | 29.72 | 3,671,739.09 | 1.79 | 29.13 | 223.613830 |
| Bank Transfer | Etiquetada como fraude | 8,261 | 0.83 | 14.95 | 1,900,567.37 | 0.93 | 15.08 | 230.065049 |
| Mobile Payment | Etiquetada como fraude | 6,568 | 0.66 | 11.89 | 1,534,585.06 | 0.75 | 12.18 | 233.645715 |
| Crypto | Etiquetada como fraude | 2,758 | 0.28 | 4.99 | 622,891.83 | 0.30 | 4.94 | 225.849104 |
| Cheque | Etiquetada como fraude | 1,680 | 0.17 | 3.04 | 368,794.77 | 0.18 | 2.93 | 219.520696 |
| Credit Card | Etiquetada como legítima | 330,050 | 33.01 | 34.94 | 67,050,237.20 | 32.75 | 34.90 | 203.151756 |
| Debit Card | Etiquetada como legítima | 284,440 | 28.44 | 30.11 | 57,763,547.86 | 28.22 | 30.07 | 203.078146 |
| Bank Transfer | Etiquetada como legítima | 141,768 | 14.18 | 15.01 | 28,806,358.58 | 14.07 | 14.99 | 203.193658 |
| Mobile Payment | Etiquetada como legítima | 113,129 | 11.31 | 11.97 | 23,117,760.60 | 11.29 | 12.03 | 204.348669 |
| Crypto | Etiquetada como legítima | 47,400 | 4.74 | 5.02 | 9,812,628.43 | 4.79 | 5.11 | 207.017477 |
| Cheque | Etiquetada como legítima | 27,958 | 2.80 | 2.96 | 5,571,623.10 | 2.72 | 2.90 | 199.285467 |


## 10. Fraude por país

- USA tuvo el mayor número de transacciones etiquetadas como fraude: **5,595** (0.56% del total y 10.13% del grupo fraude).
- La distribución por país fue estable: USA, Brazil, Japan, Mexico, Germany y Canada concentraron los mayores volúmenes de fraude, pero todos se ubicaron alrededor de 10% del grupo fraude. Sus participaciones fueron similares a las observadas en el grupo legítimo.
- Australia registró el mayor importe total en el grupo fraude, con **1,330,512.54** (0.65% del total y 10.56% del importe del grupo fraude), y también el mayor importe promedio fraudulento: **241.779491**.

| País | Grupo | transacciones | %_transacciones | %_transacciones_x_grupo | importe_total | %_importe_total | %_importe_total_x_grupo | importe_promedio |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| USA | Etiquetada como fraude | 5,595 | 0.56 | 10.13 | 1,205,222.98 | 0.59 | 9.56 | 215.410720 |
| Brazil | Etiquetada como fraude | 5,542 | 0.55 | 10.03 | 1,287,080.14 | 0.63 | 10.21 | 232.241093 |
| Japan | Etiquetada como fraude | 5,540 | 0.55 | 10.03 | 1,265,298.09 | 0.62 | 10.04 | 228.393157 |
| Mexico | Etiquetada como fraude | 5,539 | 0.55 | 10.02 | 1,239,273.01 | 0.61 | 9.83 | 223.735874 |
| Germany | Etiquetada como fraude | 5,538 | 0.55 | 10.02 | 1,268,474.09 | 0.62 | 10.07 | 229.049131 |
| Canada | Etiquetada como fraude | 5,537 | 0.55 | 10.02 | 1,245,039.54 | 0.61 | 9.88 | 224.858143 |
| Australia | Etiquetada como fraude | 5,503 | 0.55 | 9.96 | 1,330,512.54 | 0.65 | 10.56 | 241.779491 |
| India | Etiquetada como fraude | 5,502 | 0.55 | 9.96 | 1,272,573.17 | 0.62 | 10.10 | 231.292833 |
| France | Etiquetada como fraude | 5,488 | 0.55 | 9.93 | 1,222,977.22 | 0.60 | 9.70 | 222.845703 |
| UK | Etiquetada como fraude | 5,471 | 0.55 | 9.90 | 1,266,058.87 | 0.62 | 10.05 | 231.412697 |
| Australia | Etiquetada como legítima | 95,032 | 9.50 | 10.06 | 19,325,349.53 | 9.44 | 10.06 | 203.356232 |
| Brazil | Etiquetada como legítima | 95,015 | 9.50 | 10.06 | 19,548,349.17 | 9.55 | 10.17 | 205.739611 |
| Mexico | Etiquetada como legítima | 94,725 | 9.47 | 10.03 | 19,345,030.21 | 9.45 | 10.07 | 204.223068 |
| India | Etiquetada como legítima | 94,638 | 9.46 | 10.02 | 19,293,318.95 | 9.42 | 10.04 | 203.864398 |
| Canada | Etiquetada como legítima | 94,320 | 9.43 | 9.98 | 19,001,028.92 | 9.28 | 9.89 | 201.452808 |
| France | Etiquetada como legítima | 94,310 | 9.43 | 9.98 | 18,971,803.88 | 9.27 | 9.87 | 201.164286 |
| UK | Etiquetada como legítima | 94,289 | 9.43 | 9.98 | 19,274,558.09 | 9.41 | 10.03 | 204.420007 |
| Japan | Etiquetada como legítima | 94,194 | 9.42 | 9.97 | 19,218,398.17 | 9.39 | 10.00 | 204.029961 |
| Germany | Etiquetada como legítima | 94,116 | 9.41 | 9.96 | 19,109,122.32 | 9.33 | 9.95 | 203.037977 |
| USA | Etiquetada como legítima | 94,106 | 9.41 | 9.96 | 19,035,196.53 | 9.30 | 9.91 | 202.273994 |

## 11. Fraude por ciudad

- La distribución por ciudad también fue estable, con diferencias porcentuales pequeñas entre las ciudades y entre ambos grupos de etiqueta.
- Rio (Brazil) concentró el mayor volumen de transacciones etiquetadas como fraude: **2,826** (0.28% del total y 5.11% del grupo fraude).
- Sydney (Australia) registró el mayor importe total fraudulento, con **720,382.76** (0.35% del total y 5.72% del importe del grupo fraude). Rio ocupó el segundo lugar con 670,470.19 (5.32% del importe del grupo fraude).
- Sydney también presentó el mayor importe promedio entre las transacciones etiquetadas como fraude, con **262.434520**; Mumbai fue segunda con 237.822187 y Rio tercera con 237.250598.
- En conjunto, ciudades y países mantuvieron participaciones similares en los grupos legítimo y etiquetado como fraude; los resultados describen la distribución del dataset sintético.


## 12. Fraude por device type

- **Mobile** nuevamente encabezando con más filas etiquetadas como fraude: 28,932 transacciones (2.89% del total y 52.36% de las etiquetadas como fraude).
- Lo más resaltante es cómo, asumiendo **dispositivo = NULL** como medio presencial en agente o ventanilla o así, en modalidad sin dispositivo, a pesar de que en legítimo está en último lugar de importe con 5,571,623.10 (2.72% del total y 2.90% del grupo legítimo), como fraude es el penúltimo con 368,794.77 de importe total (0.18% del total y 2.93% del grupo fraude), dejando en último lugar en fraude a **ATM** con 355,320.17 de importe total (0.17% del total y 2.82% del grupo fraude). A pesar de esto, ATM y NULL siguen siendo los grupos que menor porcentaje de volumen así como de importes representan, tanto en legítimo (5.62% del total y 5.99% del grupo) así como en fraude (0.35% del total y 5.75% del grupo).

## 13. Fraude por categoría

- **Más concentración de volumen de fraude:** Jewelry con 5,821 (0.58% del total y 10.53% del grupo), no muy lejano, dejando en 2do y 3er puesto a **ATM Withdrawal** con 5,802 (0.58% del total y 10.50% del grupo) y **Crypto Exchange** con 5,737 (0.57% del total y 10.38% del grupo).
- **Mayor importe promedio:** categoría **Electronics** con 733.673024, dejando como 2do y 3ero a **Travel** con 730.754641 y **Jewelry** con 693.188378, los cuales en el lado legítimo tienen las mismas posiciones con 662.439119, 658.535476 y 653.580389 respectivamente, lo cual es sorprendente ya que, hablando del resto de categorías ordenadas, de la 4ta posición hacia abajo tienen promedios inferiores a 95.0 aproximadamente.
- En general mantienen su estructura porcentual por grupo de 5.7 a 6.4 variando entre esos rangos entre sus grupos correspondientes fraude y legítimos (p. ej. Education 6.73% legítimo y 5.78% de las transacciones del grupo fraude), lo normal; sin embargo, se observan 3 categorías con cambios abismales porcentuales de volumen por grupos: **ATM Withdrawal** (6.41% del grupo legítimo y 10.50% del volumen del grupo fraude), **Crypto Exchange** (6.41% del volumen de los legítimos y 10.38% del volumen de los fraudes) y **Jewelry** (6.46% del volumen de los legítimos y 10.53% del grupo de fraude); es decir, hay diferencia notoria en esas 3 categorías.

## 14. Variables de comportamiento: internacional, nocturno, PIN cambiado, intentos fallidos y distancia

- **Para legítimas:** 944,745 transacciones (14.31% de internacional, 32.51% de nocturno y 7.80% de PIN cambiado)
- **Para fraude:** 55,255 transacciones (26.76% de internacional, 47.95% de nocturno y 12.18% de PIN cambiado)
- **Para legítimas:** 0.354294 intentos fallidos promedio y 20.011654 distancia promedio en km
- **Para fraude:** 0.820812 intentos fallidos promedio y 19.979719 distancia promedio en km
- Los intentos fallidos promedio entre legítimo (0.354294) y fraude (0.820812) se intensifican en casi un 0.5; sin embargo, esto puede ser resultado del número de personas que realmente hicieron más de un intento de ingresar a su cuenta en sus respectivos grupos, por lo cual se hizo el análisis para promediar únicamente las personas que tienen `failed_attempts > 0`, donde encontré que los legítimos tenían 1.850876 promedio y los fraudulentos 2.372071, diferenciados en 0.5, por lo que se puede decir que es más recurrente los intentos fallidos de una cuenta en el grupo de fraude.

## 15. Análisis por número de intentos fallidos

- **Más "0" intentos fallidos etiquetados como fraudes:** 36,135 transacciones (3.61% del total y 65.40% del volumen del grupo de fraude). Sin embargo, los siguientes son **2 intentos** con 7,308 transacciones (0.73% del total y 13.23% del grupo fraude), **1 intento** con 4,526 (0.45% del total y 8.19% del grupo fraude) y **3 intentos** con 4,391 (0.44% del total y 7.95% del grupo fraude); el resto no pasa del 3% aprox. con respecto al volumen del grupo fraude.
- Si bien el grupo de 4 y 5 intentos tiene un salto porcentual de 0.9 a 2.6 aprox., los primeros grupos de 1, 2 y 3 intentos mencionados al inicio son los de mayor recurrencia, en especial 2 y 3 intentos, que tienen saltos porcentuales de 4.52% del volumen legítimo a 13.23% del volumen fraudulento en 2 intentos, y 2.70% del volumen legítimo a 7.95% en volumen fraudulento para 3 intentos.
- **8,410,419.14** en importe para cero intentos fallidos; pero, como veremos, de los de intentos fallidos, el siguiente es **2 intentos** con 1,577,156.05, representando este último 0.77% de importe total y 12.51% de importe grupal.

### Detalle por cantidad de intentos fallidos

| intentos_fallidos | grupo | transacciones | %_transacciones | %_transacciones_x_grupo | importe_total | %_importe_total | %_importe_total_x_grupo | importe_promedio |
|---|---|---|---|---|---|---|---|---|
| 0 | Etiquetada como fraude | 36,135 | 3.61 | 65.40 | 8,410,419.14 | 4.11 | 66.74 | 232.749941 |
| 2 | Etiquetada como fraude | 7,308 | 0.73 | 13.23 | 1,577,156.05 | 0.77 | 12.51 | 215.812267 |
| 1 | Etiquetada como fraude | 4,526 | 0.45 | 8.19 | 1,019,658.47 | 0.50 | 8.09 | 225.289100 |
| 3 | Etiquetada como fraude | 4,391 | 0.44 | 7.95 | 967,726.30 | 0.47 | 7.68 | 220.388590 |
| 5 | Etiquetada como fraude | 1,459 | 0.15 | 2.64 | 305,925.32 | 0.15 | 2.43 | 209.681507 |
| 4 | Etiquetada como fraude | 1,436 | 0.14 | 2.60 | 321,624.37 | 0.16 | 2.55 | 223.972402 |
| 0 | Etiquetada como legítima | 763,902 | 76.39 | 80.86 | 155,262,373.32 | 75.84 | 80.81 | 203.249072 |
| 1 | Etiquetada como legítima | 95,436 | 9.54 | 10.10 | 19,382,004.83 | 9.47 | 10.09 | 203.089031 |
| 2 | Etiquetada como legítima | 42,730 | 4.27 | 4.52 | 8,766,840.22 | 4.28 | 4.56 | 205.168271 |
| 3 | Etiquetada como legítima | 25,505 | 2.55 | 2.70 | 5,260,305.07 | 2.57 | 2.74 | 206.246032 |
| 5 | Etiquetada como legítima | 8,619 | 0.86 | 0.91 | 1,739,458.01 | 0.85 | 0.91 | 201.816685 |
| 4 | Etiquetada como legítima | 8,553 | 0.86 | 0.91 | 1,711,174.32 | 0.84 | 0.89 | 200.067148 |

## 16. Análisis por cliente

- El cliente con más transacciones fue **CUST00165481** con 19 transacciones.
- Sin embargo, el cliente con mayor aporte acumulado fue **CUST00163991** con 47,555.22, acumulado en solo 11 transacciones.
- Sin embargo, el cliente con mayor aporte promedio por transacción fue **CUST00073756** de 9,712.600000 promedio, con solo 1 transacción.
- El máximo de transacciones es de 19 para el primer lugar, ya que a partir del 2do disminuye; teniendo en cuenta que son 198,662 clientes y 1 millón de transacciones, se hace un porcentaje muy pequeño como para analizar ello.
- No coinciden el de mayor volumen o recurrencia, el de mayor aporte y el de mayor promedio, como hemos visto hace poco: el transaccionar recurrentemente no implica grandes sumas de dinero transaccionadas, y el de mayor aporte tampoco implica grandes recurrencias, quizá un depósito y ya, pero de una fuerte suma; así como el promedio, se notó que los de mayores promedios de aporte por volumen de transacción eran los que menor recurrencia a transacciones tenían, ya que los primeros lugares presentaban 1 o 2 transacciones en su historial.
- Los porcentajes de participación de los principales clientes sobre el total de 1,000,000 de transacciones y sobre el importe histórico son extremadamente pequeños (del orden de 0.00…%), por lo que se enfatiza que su volumen es muy reducido en comparación con el histórico como para que dichos porcentajes resulten representativos.

## 17. Calidad de datos

- Ningún ID vacío y ningún repetido.
- Hubieron **41,430** indicadores nocturnos inconsistentes (4.14% del total), los cuales se corrigieron.
- Hubo **899,937** inconsistencias geográficas de ciudades, las cuales se corrigieron (89.99% del total).
- **Países corregidos según ciudad:** todos los países fueron corregidos. Hay 10 países y 20 ciudades; al hacer `DISTINCT` para ver cómo se cruzaban, se terminó con 200 registros, es decir, había 18 ciudades erróneas por país. Ahora hay 2 ciudades distintas en cada uno de los 10 países, por lo que todo cuadra.

