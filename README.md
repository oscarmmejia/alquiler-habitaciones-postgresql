# Consultas SQL — Plataforma de alquiler de propiedades y habitaciones

Proyecto académico de **Backend · Bases de Datos** desarrollado con **PostgreSQL 18** y **pgAdmin 4**. Incluye el esquema relacional de la plataforma, registros de ejemplo y consultas de creación, lectura, actualización, eliminación, filtros, relaciones y agregación.

## Modelo de datos

La base `alquiler_habitaciones` contiene las entidades `owner`, `country`, `city`, `client`, `property`, `room`, `facility`, `room_facility`, `reservation`, `payment`, `visit` y `review`. Las propiedades están asociadas a propietarios y ciudades; las habitaciones pertenecen a propiedades. Las asignaciones de servicios utilizan una tabla intermedia. Los importes son de ejemplo y se expresan en euros.

## Estructura del repositorio

- `sql/00_creacion_base_datos.sql`: creación de la base de datos.
- `sql/01_creacion_tablas.sql`: estructura de las doce tablas.
- `sql/02_insercion_datos.sql`: datos de ejemplo.
- `sql/03_nivel_I.sql`: consultas y operaciones del Nivel I (ejercicios 2–18).
- `sql/04_nivel_II.sql`: Nivel II (19–37, con las dos consignas número 30).
- `sql/05_nivel_III.sql`: Nivel III (38–73).
- `sql/06_nivel_IV_opcional.sql`: consultas opcionales seleccionadas (74, 77, 79, 82, 91, 93, 94 y 95).
- `sql/07_preguntas_analisis.sql`: ejemplos de las preguntas 98 y 100.
- `docs/CONSULTAS_SQL.md`: catálogo completo con numeración y títulos.
- `docs/Informe_SQL_Inmobiliaria.pdf`: explicación y capturas organizadas por ejercicio.
- `docs/Informe_SQL_Inmobiliaria.docx`: informe editable.

## Cómo utilizar los scripts

1. Crear `alquiler_habitaciones` con `00_creacion_base_datos.sql` conectado a la base `postgres`, si todavía no existe.
2. Abrir el **Query Tool** en `alquiler_habitaciones` y ejecutar `01_creacion_tablas.sql` y `02_insercion_datos.sql` **solo sobre una base vacía**.
3. Abrir los archivos de los niveles y ejecutar las consultas **por separado o en bloques elegidos**. No ejecutar indiscriminadamente todas las instrucciones de modificación y eliminación.
4. Consultar el PDF y el catálogo Markdown para localizar cada ejercicio y sus explicaciones.

**Nota:** los ejercicios 17 y 18 prueban deliberadamente restricciones de claves foráneas, por lo que pueden producir errores esperados. El enunciado repite el número **30**: en el catálogo se identifican como **30A** (LIKE) y **30B** (ordenamiento).

Las consultas corresponden a un conjunto de datos académico de ejemplo; los resultados dependen del estado de la base cuando se ejecuten.
