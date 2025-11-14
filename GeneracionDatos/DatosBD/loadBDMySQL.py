import pandas as pd
from sqlalchemy import create_engine


engine = create_engine("mysql+pymysql://root:admin@localhost:3306/ingresos")
df = pd.read_csv("df_economia_ingresos.csv")

# Debe tener: [nombre, apellido, becado, tipo_ingreso, tipo_universidad, ingreso_cantidad]
print("Columnas DF:", df.columns.tolist())

# generar id_estudiante

df['id_estudiante'] = df.groupby(['nombre', 'apellido']).ngroup() + 1

# estrucutra de mysql de tipo de ingreso y tipo de universidad y mapeo
tipo_ingreso_sql = pd.read_sql(
    "SELECT id_tipo_ingreso, nombre AS tipo_ingreso FROM tipo_ingreso",
    engine
)

tipo_universidad_sql = pd.read_sql(
    "SELECT id_tipo_universidad, nombre AS tipo_universidad FROM tipo_universidad",
    engine
)

df = df.merge(tipo_ingreso_sql, on="tipo_ingreso", how="left")
df = df.merge(tipo_universidad_sql, on="tipo_universidad", how="left")


faltan_ingreso = df[df['id_tipo_ingreso'].isna()]['tipo_ingreso'].unique()
faltan_uni = df[df['id_tipo_universidad'].isna()]['tipo_universidad'].unique()


#tabal estudiantes
df_estudiantes = df[['id_estudiante',
                     'nombre',
                     'apellido',
                     'becado',
                     'id_tipo_universidad']].drop_duplicates()

df_estudiantes = df_estudiantes.rename(columns={
    'becado': 'es_becado'
})

print(df_estudiantes.head())

# tabal ingresos
df_ingresos = df[['ingreso_cantidad',
                  'id_tipo_ingreso',
                  'id_estudiante']].copy()

print(df_ingresos.head())

# insertar en MySQL
df_estudiantes.to_sql('estudiante', engine, if_exists='append', index=False)
df_ingresos.to_sql('ingreso', engine, if_exists='append', index=False)

print("🚀 Datos cargados correctamente en MySQL (ingresos).")
