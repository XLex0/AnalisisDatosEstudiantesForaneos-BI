import pandas as pd
from sqlalchemy import create_engine
# 1. CONEXIÓN A POSTGRES

engine = create_engine("postgresql://postgres:admin@localhost:5432/postgres")

df = pd.read_csv("df_gastos.csv")

print("Columnas DF:", df.columns.tolist())
print(df.head())

# Esperado:
# ['nombre', 'apellido', 'ciudad', 'becado', 'tipo_universidad', 'categoria_gasto', 'gasto_categoria']

# 3. GENERAR id_estudiante
df['id_estudiante'] = df.groupby(['nombre', 'apellido']).ngroup() + 1
# normalizamos estudiantes
df_estudiantes = df[['id_estudiante', 'nombre', 'apellido']].drop_duplicates()

print("\nPreview estudiantes:")
print(df_estudiantes.head())

# =================
df_gastos = df[['gasto_categoria', 'categoria_gasto', 'id_estudiante']].copy()

# Renombrar para que coincida con la tabla PostgreSQL
df_gastos = df_gastos.rename(columns={
    'gasto_categoria': 'egreso_cantidad',
    'categoria_gasto': 'categoria'
})

print("\nPreview gastos:")
print(df_gastos.head())

# insertar
df_estudiantes.to_sql('estudiante', engine, if_exists='append', index=False)
df_gastos.to_sql('gastos', engine, if_exists='append', index=False)

print("\nDatos de df_gastos.csv cargados")
