# Plan de pruebas — 5.ª IE — Grupo 29

## Objetivo
Comprobar transiciones, actualización simultánea, vecindades, límites, parámetros y población mediante SUnit y demostración presencial.

## Preparación
1. Importar código de dominio y pruebas en Pharo.
2. Registrar versión de imagen/VM, fecha y entorno.
3. Ejecutar los 27 casos que comienzan con `test` en los tres test cases: `CeldaTest`, `GrillaTest` y `SimuladorJuegoDeLaVidaTest`.
4. Guardar evidencia del resultado real, sin inventar éxitos.

## Casos automatizados incluidos
| Grupo | Caso | Resultado esperado |
|---|---|---|
| Celda | Estado inicial | Muerta |
| Celda | Aislada viva | Muere en una generación |
| Celda | Muerta con 3 vecinas | Nace |
| Celda | Muerta con 2 vecinas | Permanece muerta |
| Celda | Viva con 2 vecinas | Sobrevive |
| Celda | Viva con 3 vecinas | Sobrevive (confirmado por el profesor el 11/11/2026) |
| Celda | Viva con 4 vecinas | Muere |
| Celda | Sin transición | Conserva estado |
| Celda | Preparación | No cambia estado actual |
| Grilla | Construcción y población | Datos y acceso correcto |
| Grilla | Coordenadas repetidas | Activación idempotente |
| Grilla | Esquina plana 5×5 | 3 vecinas |
| Grilla | Plana 1×1 | 0 vecinas y extinción |
| Grilla | Toroidal 3×3 | 8 vecinas distintas |
| Grilla | Vecinas al otro lado | Se consideran extremos opuestos |
| Grilla | Bloque 2×2 | Configuración estable |
| Grilla | Parpadeador | Ciclo de período 2 |
| Grilla | Dimensiones incorrectas | Excepción Error |
| Grilla | Coordenadas fuera de rango | Excepción Error |
| Grilla | Estructura de coordenada inválida | Excepción Error |
| Grilla | Nacimiento toroidal en esquina (5×5) | (1,1) nace por vecinas de bordes opuestos |
| Grilla | Mismo patrón en grilla plana (5×5) | (1,1) permanece muerta |
| Grilla | Planeador toroidal 30×30 (4 generaciones) | 5 células, desplazamiento diagonal atravesando extremos |
| Simulador | 0 generaciones | No evoluciona |
| Simulador | 10 generaciones | Ejecuta exactamente 10 |
| Simulador | Generaciones negativas | Excepción Error |
| Simulador | Paso simple | Incrementa generación y actualiza población |

## Demostración para la defensa
- **Válido 1:** parpadeador 5×5 por cuatro generaciones, población 3.
- **Válido 2:** planeador en grilla toroidal 30×30 atravesando los bordes en cuatro generaciones; mostrar además comparación plana/toroidal en una esquina.
- **Inválido:** intentar construir `GrillaToroidal` de 2×2, capturar e informar la excepción.

## Registro de resultados (llenar en Pharo)
| Fecha | Versión Pharo | Ejecutadas | Aprobadas | Fallidas | Evidencia |
|---|---|---:|---:|---:|---|
| Pendiente | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |

## Nota
Los 27 casos han sido redactados, pero **aún no se ejecutaron en una VM Pharo** en este entorno; se requiere verificación real antes de la entrega.

## Aclaraciones docentes incorporadas

El profesor Rubén Bernal confirmó el 11/11/2026 que una célula viva con 2 o 3 vecinas vivas sobrevive; autorizó implementar conexión de bordes y dejó al grupo la elección de un tamaño suficientemente grande. Se usa 30×30 como caso principal para la demostración.
