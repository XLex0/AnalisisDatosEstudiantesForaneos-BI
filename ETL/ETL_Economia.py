from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sha2, concat_ws, lit
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



# ================== TEST DE CONEXIONES Y LECTURA ==================

print("\n=== Probando lectura de CSV ===")
try:
    df_csv.show(5)
    print(f"Filas CSV: {df_csv.count()}")
except Exception as e:
    print("Error leyendo CSV:", e)


print("\n=== Probando lectura de XLSX ===")
try:
    df_xlsx.show(5)
    print(f"Filas XLSX: {df_xlsx.count()}")
except Exception as e:
    print("Error leyendo XLSX:", e)


print("\n=== Probando conexión a PostgreSQL ===")
try:
    # Cambia 'public.tu_tabla_postgres' por una tabla real de tu BD
    df_pg_test = spark.read.jdbc(
        url=pg_url,
        table="public.estudiante",   # <-- AJUSTA ESTO
        properties=pg_props
    )
    df_pg_test.show(5)
    print(f"Filas Postgres: {df_pg_test.count()}")
except Exception as e:
    print("Error conectando/leyendo Postgres:", e)


print("\n=== Probando conexión a MySQL ===")
try:
    # Cambia 'tu_tabla_mysql' por una tabla real de tu BD
    df_mysql_test = spark.read.jdbc(
        url=mysql_url,
        table="ingreso",            # <-- AJUSTA ESTO
        properties=mysql_props
    )
    df_mysql_test.show(5)
    print(f"Filas MySQL: {df_mysql_test.count()}")
except Exception as e:
    print("Error conectando/leyendo MySQL:", e)


print("\n=== FIN DE PRUEBAS ===")
