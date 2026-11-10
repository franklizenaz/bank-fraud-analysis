# Hallazgos y decisiones de negocio

Los siguientes hallazgos convierten las métricas del análisis en decisiones concretas para el banco. Los resultados provienen de un dataset sintético y deben calibrarse con datos reales antes de aplicarse en producción.

| Hallazgo accionable | Decisión de negocio |
|---|---|
| Las operaciones etiquetadas como fraude tienen un importe promedio de **228.079081**, superior al legítimo (**203.358743**), y representan el **6.16% del importe total**, aunque solo son el **5.53% de las transacciones**. | Implementar autenticación adicional para operaciones cuyo importe supere el comportamiento normal del cliente, en lugar de revisar todas las operaciones por igual. |
| **Credit Card concentra 19,568 fraudes**, equivalentes al **35.41% del grupo fraude**. | Priorizar la inversión antifraude en tarjetas de crédito mediante límites de velocidad, detección de dispositivo, MFA y confirmación para operaciones atípicas. |
| Las operaciones fraudulentas tienen mayor presencia internacional (**26.76% frente a 14.31%**) y nocturna (**47.95% frente a 32.51%**). | Crear una regla combinada: si una operación es internacional y nocturna, solicitar MFA o confirmación por otro canal. No bloquear por una sola condición. |
| Los casos con **2 intentos fallidos** representan **13.23% del fraude**, frente a **4.52% de las legítimas**. Con 3 intentos, la diferencia es **7.95% frente a 2.70%**. | Aplicar bloqueo progresivo: MFA desde el segundo intento, bloqueo temporal después del tercero y notificación inmediata al cliente. |
| **Jewelry, ATM Withdrawal y Crypto Exchange** concentran aproximadamente **10.5% del fraude cada una**, frente a cerca de **6.4% en legítimas**. | Crear límites de importe y revisión reforzada para esas categorías, especialmente cuando también existan intentos fallidos, actividad nocturna o cambio reciente de PIN. |
| **Mobile representa 52.14% de las transacciones y 52.26% del importe total**. | No bloquear el canal Mobile, porque afectaría la operación principal del banco. Implementar controles específicos de dispositivo, sesión y MFA adaptativa. |
| Rio lidera el volumen general, con **50,365 transacciones**, pero Sydney presenta el mayor promedio fraudulento (**262.434520**) y el mayor importe fraudulento (**720,382.76**). | No bloquear ciudades completas. Aplicar controles geográficos solo cuando la ubicación se combine con monto alto, actividad nocturna, operación internacional o múltiples intentos fallidos. |
| El cliente con mayor frecuencia registra **19 transacciones**, mientras que el mayor promedio individual es **9,712.600000** en una operación. | Separar las reglas de frecuencia y monto: una operación de alto valor no debe tratarse igual que un cliente con muchas operaciones pequeñas. |
| La distancia promedio es casi igual entre fraude y legítimas: **19.979719 km frente a 20.011654 km**. | No invertir en una regla de fraude basada únicamente en distancia, porque no diferencia suficientemente ambos grupos. |
| Se corrigieron **899,937 inconsistencias geográficas**, equivalentes al **89.99%** del total. | No usar ciudad o país para decisiones automáticas hasta ejecutar controles de calidad. Primero validar la ubicación y luego aplicar reglas geográficas. |
| Se corrigieron **41,430 inconsistencias en el indicador nocturno**, equivalentes al **4.14%**. | Establecer una validación previa de fecha y hora antes de activar alertas nocturnas para evitar falsos positivos. |

## Decisión principal

El banco no debería crear reglas como “ciudad peligrosa”, “categoría fraudulenta” o “transacción nocturna = fraude”. Debe implementar un esquema de riesgo combinado:

1. Una señal: generar una alerta.
2. Dos señales: solicitar autenticación multifactor.
3. Tres o más señales: retener temporalmente la operación y enviarla a revisión.
4. Medir fraude confirmado, falsos positivos, importe retenido y tiempo de resolución para ajustar los umbrales.

Así, los porcentajes se convierten en criterios para priorizar controles, asignar recursos y reducir revisiones innecesarias.
