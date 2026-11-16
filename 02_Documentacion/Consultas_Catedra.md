# Aclaraciones de cátedra y consultas pendientes — Grupo 29

**Fuente primaria:** consigna `5 IE - Paradigmas - 2026.pdf`, tema 9, pág. 16.

## Confirmado por el profesor Rubén Bernal (11/11/2026)

1. **Supervivencia:** una célula viva con **2 o 3 vecinas vivas** sobrevive a la siguiente generación. El modelo ya utiliza esta interpretación.
2. **Tamaño de grilla:** debe ser suficientemente grande para permitir observar casos interesantes. El docente deja la elección al grupo. Decisión del equipo: demo principal 30 × 30 y dimensiones configurables.
3. **Conexión de extremos:** autorizó implementar bordes opuestos conectados; lo describió como un mundo que se une por los extremos. Esta es la modalidad toroidal elegida como variante por el grupo.

**Precisión:** la autorización de la topología toroidal no equivale a una afirmación explícita de que por sí sola cubra el criterio de originalidad.

## Pendientes de consulta

- **Anexo A:** ¿Se reemplazan apartados de BNF, parser y AST por modelado de objetos, UML, pruebas y decisiones de POO?
- **Entrega:** ¿La demostración textual por Transcript es suficiente o debe incluir una interfaz gráfica?
- **Originalidad:** ¿La conexión toroidal cuenta como la característica original exigida?

## Decisión de implementación que no se atribuye a la cátedra

- Las células muertas que no cumplen la regla de nacimiento permanecen muertas. Es la interpretación del equipo para los casos que el documento no especifica expresamente.
- Grilla toroidal exige 3 × 3 como mínimo para evitar vecinas duplicadas. No es un mínimo establecido por el profesor.
