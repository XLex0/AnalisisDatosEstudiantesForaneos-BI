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
    generar_hash_udf(col("nombre"), col("apellido")))

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

# ================== DIMENSION ORIGEN ==================
dim_origen = (
    df_csv
    .select("ciudad", "provincia")
    .dropDuplicates()
)

w_ori = Window.orderBy("ciudad", "provincia")

dim_origen = dim_origen.withColumn(
    "id_origen",
    row_number().over(w_ori)
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

#=================== DIMENSION CATEGORIA GASTOS ==================
df_mysql_gasto = spark.read.jdbc(
    url=mysql_url,
    table="gastos",
    properties=mysql_props
)

dim_categoria_gasto = (
    df_mysql_gasto
    .select("categoria")
    .dropDuplicates()
)

w_cat = Window.orderBy("categoria")
dim_categoria_gasto = dim_categoria_gasto.withColumn(
    "id_categoria_gasto",
    row_number().over(w_cat)
)

# ================== OBTENCIÖN EGRESOS ==================
