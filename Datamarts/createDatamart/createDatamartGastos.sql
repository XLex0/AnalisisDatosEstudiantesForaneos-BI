CREATE DATABASE IF NOT EXISTS dm_gastos;


CREATE TABLE dm_gastos.dim_estudiante (
    id_estudiante String,   
    edad Int32,
    genero String,
    modalidad String,
    becado UInt8            -- 0/1
)
ENGINE = MergeTree
ORDER BY id_estudiante;


CREATE TABLE dm_gastos.dim_periodo (
    id_periodo UInt32,
    semestre Int32,
    anio Int32,
    periodo String          -- etiqueta_periodo
)
ENGINE = MergeTree
ORDER BY id_periodo;


CREATE TABLE dm_gastos.dim_universidad (
    id_universidad UInt32,
    universidad String,
    carrera String
)
ENGINE = MergeTree
ORDER BY id_universidad;


CREATE TABLE dm_gastos.dim_categoria_gasto (
    id_categoria_gasto UInt32,
    categoria String
)
ENGINE = MergeTree
ORDER BY id_categoria_gasto;


CREATE TABLE dm_gastos.dim_origen (
    id_origen UInt32,
    ciudad String,
    provincia String
)
ENGINE = MergeTree
ORDER BY id_origen;


CREATE TABLE dm_gastos.fact_gasto (
    id_estudiante String,
    id_periodo UInt32,
    id_universidad UInt32,
    id_categoria_gasto UInt32,
    id_origen UInt32,
    monto_gasto Float64
)
ENGINE = MergeTree
ORDER BY (id_estudiante, id_periodo, id_categoria_gasto);
