# Análisis de datos de estudiantes foráneos — BI

Proyecto de Business Intelligence que implementa un flujo completo de generación de datos, procesos ETL, modelado OLAP en ClickHouse y dashboards analíticos en Power BI.

## Estructura del proyecto

El repositorio se encuentra organizado siguiendo las principales etapas del pipeline de datos:

### GeneracionDatos/
Contiene los notebooks y scripts encargados de la **generación de datos sintéticos**, distribuidos en múltiples fuentes (CSV, XLSX, MySQL y PostgreSQL).  
Estos datos incluyen variables académicas, económicas y de bienestar, además de errores controlados utilizados para pruebas de limpieza.

### ETL/
Incluye los procesos de **extracción, transformación y limpieza de datos**, donde se integran las diferentes fuentes, se normalizan estructuras y se construyen tablas consolidadas listas para el modelado analítico.

### Datamarts/
Contiene los scripts de **modelado dimensional**, donde se definen los datamarts temáticos (Bienestar, Economía y Gastos) y las estructuras necesarias para el modelo estrella cargado en ClickHouse.

### Dashboard/
Incluye los archivos de **Power BI** utilizados para la construcción de dashboards interactivos, basados en las vistas analíticas generadas en el entorno OLAP.

---

Esta organización refleja un flujo completo de ingeniería de datos y Business Intelligence, desde la generación de información hasta su explotación analítica en dashboards interactivos.
