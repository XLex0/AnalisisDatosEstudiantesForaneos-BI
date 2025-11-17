from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sha2, concat_ws, lit, udf, row_number
from pyspark.sql.window import Window
from pyspark.sql.types import StringType

import pandas as pd

from hash import generar_hash

import os
import os

os.environ["HADOOP_HOME"] = r"C:\hadoop"
os.environ["hadoop.home.dir"] = r"C:\hadoop"

import hashlib
from dotenv import load_dotenv

# Variables de entorno
# ---------------------------------------------------
load_dotenv()

SALT = os.getenv("HASH_SALT")
if not SALT:
    raise RuntimeError("No se encontró la variable de entorno HASH_SALT")

# Postgres
PG_HOST = os.getenv("PG_HOST")
PG_PORT = os.getenv("PG_PORT", "5432")
PG_DB   = os.getenv("PG_DB")
PG_USER = os.getenv("PG_USER")
PG_PASSWORD = os.getenv("PG_PASSWORD")

# MySQL
MY_HOST = os.getenv("MY_HOST")
MY_PORT = os.getenv("MY_PORT", "3306")
MY_DB   = os.getenv("MY_DB")
MY_USER = os.getenv("MY_USER")
MY_PASSWORD = os.getenv("MY_PASSWORD")

# Spark Session
# ---------------------------------------------------
spark = (
    SparkSession.builder
    .appName("ETL Bienestar Estudiantil")
    .config(
        "spark.jars",
        "conector/mysql-connector-j-9.5.0.jar,conector/postgresql-42.7.8.jar"
    )
    .getOrCreate()
)

# Extracción de datos
# ---------------------------------------------------
# CSV
df_csv = (
    spark.read
    .option("header", True)
    .option("inferSchema", True)
    .csv("data/df_general.csv")
)

# XLSX
pdf_xlsx = pd.read_excel("data/df_bienestar.xlsx")
df_xlsx = spark.createDataFrame(pdf_xlsx)

# Postgres
pg_url = f"jdbc:postgresql://{PG_HOST}:{PG_PORT}/{PG_DB}"
pg_props = {
    "user": PG_USER,
    "password": PG_PASSWORD,
    "driver": "org.postgresql.Driver",
}

# MySQL
mysql_url = f"jdbc:mysql://{MY_HOST}:{MY_PORT}/{MY_DB}?serverTimezone=UTC"
mysql_props = {
    "user": MY_USER,
    "password": MY_PASSWORD,
    "driver": "com.mysql.cj.jdbc.Driver",
}

# Transformaciones 
# ---------------------------------------------------

generar_hash_udf = udf(generar_hash, StringType())

df_csv = df_csv.withColumn(
    "identifier",
    generar_hash_udf(col("nombre"), col("apellido"))
)
# ================== DIMENSION UNIVERSIDAD ==================
dim_universidad = (
    df_csv
    .select("nombre_universidad", "carrera")
    .dropDuplicates()
)

w_uni = Window.orderBy("nombre_universidad", "carrera")

dim_universidad = dim_universidad.withColumn(
    "id_universidad",
    row_number().over(w_uni)
)


# ================== DIMENSION PERIODO ==================
dim_periodo = (
    df_csv
    .select("semestre", "año", "etiqueta_periodo")
    .dropDuplicates()
)

w_per = Window.orderBy("semestre", "año", "etiqueta_periodo")

dim_periodo = dim_periodo.withColumn(
    "id_periodo",
    row_number().over(w_per)
)

# ================== DIMENSION RESIDENCIA ==================
dim_residencia_a = (
    df_csv
    .select("zona", "sector", "tipo_vivienda", "código_postal", "nombre", "apellido")
    .dropDuplicates()
)

dim_residencia_b = (
    df_xlsx
    .select("tiempo_translado_min", "nombre", "apellido")
    .dropDuplicates()
)

dim_residencia = (
    dim_residencia_a.join(
        dim_residencia_b,
        on=["nombre", "apellido"],
        how="inner"
    )
    .drop("nombre", "apellido")
)

w_res = Window.orderBy("zona", "sector", "tipo_vivienda", "código_postal", "tiempo_translado_min")

dim_residencia = dim_residencia.withColumn(
    "id_residencia",
    row_number().over(w_res)
)

# ================== DIMENSION ESTUDIANTE ==================

# creamos un identificador único para el estudiante basado en nombre+apellido
df_mysql_estudiante = spark.read.jdbc(
    url=mysql_url,
    table="estudiante",
    properties=mysql_props
)

dim_estudiante = (
    df_csv.alias("c")
    .join(
        df_mysql_estudiante
        .select("nombre", "apellido", "becado")
        .alias("m"),
        on=["nombre", "apellido"],
        how="left"
    )
    .select(
        col("identifier").alias("id_estudiante"),
        "edad",
        "genero",
        "modalidad",
        "becado"
    )
    .dropDuplicates()
)

map_estudiante = (
    df_csv
    .select("identifier", "nombre", "apellido")
    .dropDuplicates()
    .withColumnRenamed("identifier", "id_estudiante")
)
# ================== DIMENSION ORIGEN ==================
dim_origen = (
    df_csv
    .select("ciudad", "provincia", "longitud", "latitud")
    .dropDuplicates()
)

w_ori = Window.orderBy("ciudad", "provincia", "longitud", "latitud")

dim_origen = dim_origen.withColumn(
    "id_origen",
    row_number().over(w_ori)
)

query_ingresos_totales = """
(
    SELECT 
        e.nombre,
        e.apellido,
        SUM(i.ingreso_cantidad) AS ingreso_total
    FROM ingresos i
    JOIN estudiante e ON i.id_estudiante = e.id_estudiante
    GROUP BY e.nombre, e.apellido
) ingresos_totales
"""

df_ingresos_totales = spark.read.jdbc(
    url=mysql_url,
    table=query_ingresos_totales,
    properties=mysql_props
)

query_egresos_totales = """
(
    SELECT 
        e.nombre,
        e.apellido,
        SUM(i.egreso_cantidad) AS egreso_total
    FROM gastos i
    JOIN estudiante e ON i.id_estudiante = e.id_estudiante
    GROUP BY e.nombre, e.apellido
) egresos_totales
"""

df_egresos_totales = spark.read.jdbc(
    url=pg_url,
    table=query_egresos_totales,
    properties=pg_props
)

# ================== FACT BIENESTAR ESTUDIANTIL ==================

fact_bienestar = (
    df_csv
    .select("nombre", "apellido", "distancia_origen_km")
    .join(
        df_xlsx
        .select(
            "nombre",
            "apellido",
            "promedio_academico",
            "distancia_universidad_km",
            "num_viajes_origen",
            "indice_bienestar"
        ),
        on=["nombre", "apellido"],
        how="inner"
    )
    .join(
        df_ingresos_totales,
        on=["nombre", "apellido"],
        how="left"
    )
    .join(
        df_egresos_totales,
        on=["nombre", "apellido"],
        how="left"
    )
    .withColumn(
        "balance_neto",
        col("ingreso_total") - col("egreso_total")
    )
)


fact_bienestar_keys = (
    fact_bienestar
    # Universidad, periodo, residencia y origen desde df_csv
    .join(
        df_csv.select(
            "nombre",
            "apellido",
            "nombre_universidad",
            "carrera",
            "semestre",
            "año",
            "etiqueta_periodo",
            "zona",
            "sector",
            "tipo_vivienda",
            "código_postal",
            "ciudad",
            "provincia",
            "longitud",
            "latitud"
        ).dropDuplicates(),
        on=["nombre", "apellido"],
        how="left"
    )
    .join(
        df_xlsx.select(
            "nombre",
            "apellido",
            "tiempo_translado_min"
        ).dropDuplicates(),
        on=["nombre", "apellido"],
        how="left"
    )
)

fact_bienestar_modelo = (
    fact_bienestar_keys
    # FK estudiante
    .join(
        map_estudiante,
        on=["nombre", "apellido"],
        how="left"
    )
    # FK universidad
    .join(
        dim_universidad,
        on=["nombre_universidad", "carrera"],
        how="left"
    )
    # FK periodo
    .join(
        dim_periodo,
        on=["semestre", "año", "etiqueta_periodo"],
        how="left"
    )
    # FK residencia
    .join(
        dim_residencia,
        on=["zona", "sector", "tipo_vivienda", "código_postal", "tiempo_translado_min"],
        how="left"
    )
    # FK origen
    .join(
        dim_origen,
        on=["ciudad", "provincia", "longitud", "latitud"],
        how="left"
    )
    .select(
        # FK a dimensiones
        "id_estudiante",
        "id_universidad",
        "id_periodo",
        "id_residencia",
        "id_origen",
        # Medidas del hecho
        "promedio_academico",
        "indice_bienestar",
        "distancia_universidad_km",
        "distancia_origen_km",
        "num_viajes_origen",
        "ingreso_total",
        "egreso_total",
        "balance_neto"
    )
)

# (opcional) Cargar al DW, por ejemplo en Postgres esquema dw:
# fact_bienestar_modelo.write.jdbc(
#     url=pg_url,
#     table="dw.fact_bienestar",
#     mode="overwrite",
#     properties=pg_props
# )