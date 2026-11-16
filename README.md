# TPI – Paradigmas de Programación – Grupo 29
## Tema 9: El Juego de la Vida (UTN FRRe, 5.ª IE, 2026)

**Estado:** implementación propuesta y documentada, pendiente de carga, compilación, ejecución y validación efectiva en una imagen Pharo por parte del equipo. Los 27 casos SUnit están escritos, **no** debe afirmarse que pasaron en Pharo hasta ejecutarlos.

## Entregables

- `01_Codigo/TPI-JuegoDeLaVida.st`: cinco clases del dominio en Smalltalk para Pharo.
- `01_Codigo/TPI-JuegoDeLaVida-Tests.st`: 27 pruebas SUnit.
- `01_Codigo/Ejemplo-Playground.st.txt`: demostración de grilla plana, generaciones y población por `Transcript`.
- `01_Codigo/Ejemplo-Toroidal-Playground.st.txt`: demostración principal 30 × 30 con un planeador que cruza los bordes.
- `01_Codigo/Ejemplo-Comparacion-Modalidades.st.txt`: contraste controlado entre la grilla plana y la toroidal.
- `01_Codigo/Ejemplo-ErrorControlado.st.txt`: caso inválido con excepción controlada.
- `02_Documentacion/Informe_Tecnico_Grupo29.pdf`: borrador técnico conforme al formato general del Anexo A (autores pendientes).
- `02_Documentacion/DiagramaClases.png`, `.svg`, `.dot` y `.mmd`: diagrama y fuentes editables.
- `02_Documentacion/Consultas_Catedra.md`: puntos a confirmar ante los docentes.
- `03_Presentacion/Presentacion_Grupo29.pptx`: diapositivas para la defensa.
- `04_Pruebas/Plan_Pruebas.md`: plan de pruebas y criterios de aceptación.

## Requisitos

- Pharo estable reciente (anotar exactamente la versión instalada en el informe).
- SUnit en la imagen Pharo (incluido normalmente en el entorno de desarrollo).
- No se requieren paquetes externos, imágenes ni conexión a internet para ejecutar el modelo.

## Importar el código en Pharo

1. Abrir una **imagen nueva de Pharo** y guardar una copia por seguridad.
2. Descomprimir el ZIP y ubicar la carpeta `01_Codigo` en un directorio local accesible.
3. Importar `TPI-JuegoDeLaVida.st` con la función **File In** del entorno (por ejemplo, arrastrarlo a la ventana de Pharo y seleccionar *FileIn Entire File*, si esa opción está disponible en la versión instalada; alternativamente usar el explorador de archivos de la imagen).
4. Verificar en el navegador de clases que exista el paquete `TPI-JuegoDeLaVida` con `Celda`, `Grilla`, `GrillaPlana`, `GrillaToroidal`, `SimuladorJuegoDeLaVida`.
5. Importar después `TPI-JuegoDeLaVida-Tests.st`.
6. Abrir SUnit / Test Runner y ejecutar las pruebas del paquete `TPI-JuegoDeLaVida-Tests`; registrar resultados reales (cantidad, fallas, versión de Pharo).
7. Abrir un Playground, copiar el contenido de `Ejemplo-Toroidal-Playground.st.txt`, ejecutar **Do it** y observar `Transcript`.
8. Ejecutar después `Ejemplo-Comparacion-Modalidades.st.txt`, `Ejemplo-Playground.st.txt` (grilla plana) y `Ejemplo-ErrorControlado.st.txt`.

**Importante:** el formato `.st` fue generado como archivo Smalltalk chunk compatible con el mecanismo clásico File In. Podrían ser necesarios ajustes menores según la versión efectiva de Pharo. El código no ha sido compilado en una VM Pharo dentro del entorno de elaboración del informe.

## Reglas implementadas según el PDF de la cátedra (pág. 16)

- **R1**: con dos vecinas vivas, la célula conserva su estado anterior.
- **R2**: una célula muerta con tres vecinas vivas pasa a viva.
- **R3**: una célula viva con menos de dos o más de tres vecinas vivas pasa a muerta.
- **Aclaración docente confirmada (11/11/2026)**: una célula viva sobrevive con 2 o 3 vecinas vivas (profesor Rubén Bernal). Para una célula muerta sin condición de nacimiento, se conserva su estado, como interpretación del equipo.

El cálculo de `estadoSiguiente` de todas las células precede a la confirmación de cualquier `estadoActual`.

## Modalidades de grilla

- **GrillaPlana (comparación):** vecinas dentro de los límites. Admite dimensiones desde 1 × 1.
- **GrillaToroidal (modalidad principal):** los extremos se conectan; requiere al menos 3 filas y 3 columnas para evitar vecinas repetidas. El grupo propone este comportamiento como variante original. El profesor autorizó la conexión de extremos el 11/11/2026, aunque no confirmó por separado que baste para cumplir el aporte original.
- **Tamaño de demostración elegido por el grupo:** 30 × 30, con dimensiones configurables. El profesor indicó el 11/11/2026 que el tamaño debe permitir ver casos interesantes y que lo decida el grupo.
- La modalidad se selecciona durante la construcción de la grilla y no se cambia durante la evolución.

## Ejecución básica

**Para la demostración principal**, utilizar `Ejemplo-Toroidal-Playground.st.txt`: tablero 30 × 30, patrón planeador de cinco células junto a la esquina inferior derecha; avanza ocho generaciones y cruza los bordes.

Este ejemplo pequeño sirve únicamente para comparar con la modalidad plana:

En Playground:

```smalltalk
| grilla simulador |
grilla := GrillaToroidal
    conFilas: 5
    columnas: 5
    vivasEn: #((2 3) (3 3) (4 3)).
simulador := SimuladorJuegoDeLaVida
    conGrilla: grilla
    generaciones: 10.
simulador ejecutar.
simulador generacionActual.   "10"
simulador poblacionActual.    "3: patron parpadeador"
```

La generación **0** es el tablero inicial. `generaciones: 10` solicita diez transiciones.

## Decisiones técnicas

- Cinco clases, sin patrón State ni clases de excepciones personalizadas.
- Array lineal de tamaño filas × columnas con índice Pharo `(fila - 1) * columnas + columna`.
- Vecindades almacenadas como referencias a objetos durante la inicialización.
- Población expuesta mediante `poblacionActual` y visualizada en cada generación por el ejemplo de Playground; no se almacena un historial por defecto.
- Los errores de dimensiones, coordenadas y generaciones se señalan mediante `self error:`. El script de caso inválido muestra cómo capturar un error controlado.
- Las coordenadas iniciales repetidas no duplican células: la activación es idempotente.

## Entrega institucional

- Completar nombres, apellidos, comisión, correos y versión real de Pharo antes de presentar.
- Revalidar los requisitos y las fechas que figuran en `5 IE - Paradigmas - 2026.pdf`.
- Registrar la confirmación docente de la supervivencia con tres vecinos y consultar los apartados incongruentes del Anexo A (gramáticas, parsers, AST).
- Antes de entregar: ejecutar SUnit en Pharo, conservar evidencias de la demostración, revisar el PDF y actualizar los diagramas según el código realmente implementado.

## Alcance honesto

Las comprobaciones automáticas hechas para crear el paquete son análisis estáticos de archivos y validaciones de una especificación de referencia externa; **no equivalen a compilar, correr o aprobar las pruebas en Pharo**. Toda afirmación de funcionamiento final y resultados de SUnit debe verificarse en la instalación del grupo.

## Aclaraciones recibidas del profesor (11/11/2026)

- **Reglas:** una célula viva con 2 o 3 vecinas vivas sobrevive a la siguiente generación (Rubén Bernal).
- **Dimensiones:** elegir un tamaño suficientemente grande para mostrar casos interesantes; el tamaño queda a criterio del grupo. En nuestra demostración se usan 30 × 30.
- **Bordes conectados:** el profesor autorizó implementar esa topología como un mundo que se une por sus extremos. No confirmó expresamente si la considera suficiente, por sí sola, como variante original.
- **Anexo A:** sigue pendiente la consulta sobre las secciones de gramáticas y parsers.
