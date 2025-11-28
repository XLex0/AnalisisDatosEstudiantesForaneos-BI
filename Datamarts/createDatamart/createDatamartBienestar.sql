CREATE DATABASE IF NOT EXISTS dm_bienestar;

USE dm_bienestar;

CREATE TABLE dim_estudiante (
    id_estudiante String,
    edad          Int32,
    genero        String,
    modalidad     String,
    becado        UInt8
)
ENGINE = MergeTree
ORDER BY id_estudiante;

CREATE TABLE dim_universidad (
    id_universidad Int32,
    universidad    String,
    carrera        String
)
ENGINE = MergeTree
ORDER BY id_universidad;

CREATE TABLE dim_periodo (
    id_periodo Int32,
    semestre   Int32,
    anio       Int32,
    periodo    String
)
ENGINE = MergeTree
ORDER BY id_periodo;

CREATE TABLE dim_residencia (
    id_residencia       Int32,
    zona                String,
    sector              String,
    tipo_vivienda       String,
    codigo_postal       String,
    tiempo_traslado_min Float64
)
ENGINE = MergeTree
ORDER BY id_residencia;

CREATE TABLE dim_origen (
    id_origen Int32,
    ciudad    String,
    provincia String,
    longitud  Float64,
    latitud   Float64
)
ENGINE = MergeTree
ORDER BY id_origen;

CREATE TABLE fact_bienestar (
    id_estudiante            String,
    id_universidad           Int32,
    id_periodo               Int32,
    id_residencia            Int32,
    id_origen                Int32,
    promedio_academico       Float64,
    indice_bienestar         Float64,
    distancia_universidad_km Float64,
    distancia_origen_km      Float64,
    num_viajes_origen        Int32,
    ingreso_total            Float64,
    egreso_total             Float64,
    balance_neto             Float64
)
ENGINE = MergeTree
ORDER BY (
    id_estudiante,
    id_universidad,
    id_periodo,
    id_residencia,
    id_origen
);
