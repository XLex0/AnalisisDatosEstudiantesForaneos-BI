CREATE DATABASE IF NOT EXISTS dm_economia;

CREATE TABLE dm_economia.dim_estudiante (
    id_estudiante String,     -- md5, viene como string
    edad Int32,
    genero String,
    modalidad String,
    becado UInt8              -- 0/1
)
ENGINE = MergeTree
ORDER BY id_estudiante;

CREATE TABLE dm_economia.dim_periodo (
    id_periodo UInt32,
    semestre Int32,
    anio Int32,
    periodo String
)
ENGINE = MergeTree
ORDER BY id_periodo;

CREATE TABLE dm_economia.dim_universidad (
    id_universidad UInt32,
    universidad String,
    carrera String
)
ENGINE = MergeTree
ORDER BY id_universidad;

CREATE TABLE dm_economia.dim_origen (
    id_origen UInt32,
    ciudad String,
    provincia String
)
ENGINE = MergeTree
ORDER BY id_origen;

CREATE TABLE dm_economia.dim_fuente_ingreso (
    id_fuente_ingresos UInt32,
    tipo_fuente String
)
ENGINE = MergeTree
ORDER BY id_fuente_ingresos;

CREATE TABLE dm_economia.fact_economia (
    id_estudiante String,
    id_periodo UInt32,
    id_universidad UInt32,
    id_origen UInt32,
    id_fuente_ingresos UInt32,
    ingresos_totales Float64,
    egresos_totales Float64,
    balance_neto Float64
)
ENGINE = MergeTree
ORDER BY (id_estudiante, id_periodo);
