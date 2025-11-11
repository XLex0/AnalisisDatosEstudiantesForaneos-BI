
CREATE DATABASE IF NOT EXISTS mart_bienestar;

-- ---------- Dimensiones ----------
CREATE TABLE IF NOT EXISTS mart_bienestar.dim_periodo
(
  id_periodo UInt32,                                 -- PK
  semestre LowCardinality(String),
  anio UInt16,
  etiqueta_periodo LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_periodo;

CREATE TABLE IF NOT EXISTS mart_bienestar.dim_universidad
(
  id_universidad UInt32,                             -- PK
  nombre_universidad LowCardinality(String),
  carrera LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_universidad;

CREATE TABLE IF NOT EXISTS mart_bienestar.dim_residencia
(
  id_residencia UInt32,                              -- PK
  zona LowCardinality(String),                       -- Norte/Centro/Sur/Valle u otra
  sector LowCardinality(String),
  tipo_vivienda LowCardinality(String),              -- Arrendada/Residencia/Familiar...
  codigo_postal LowCardinality(String),
  tiempo_traslado_min UInt16
)
ENGINE = MergeTree
ORDER BY id_residencia;

CREATE TABLE IF NOT EXISTS mart_bienestar.dim_origen
(
  id_origen UInt32,                                  -- PK
  ciudad LowCardinality(String),
  provincia LowCardinality(String),
  longitud Float64,                                  -- grados
  latitud Float64
)
ENGINE = MergeTree
ORDER BY id_origen;

CREATE TABLE IF NOT EXISTS mart_bienestar.dim_estudiante
(
  id_estudiante UInt32,                              -- PK
  genero LowCardinality(String),
  edad UInt8,
  modalidad LowCardinality(String),                  -- Presencial/Híbrida/Virtual
  es_becado UInt8                                    -- 1/0
)
ENGINE = MergeTree
ORDER BY id_estudiante;

-- ---------- Hechos ----------
CREATE TABLE IF NOT EXISTS mart_bienestar.hechos_bienestar
(
  promedio_academico Float32,
  indice_bienestar Float32,
  ingresos_totales Float32,
  balance_neto Float32,
  distancia_universidad_km Float32,
  distancia_origen_km Float32,
  num_viajes_origen UInt16,

  -- Claves (FK lógicas)
  id_estudiante UInt32,
  id_periodo   UInt32,
  id_universidad UInt32,
  id_residencia  UInt32,
  id_origen      UInt32
)
ENGINE = MergeTree
ORDER BY (id_estudiante, id_periodo, id_universidad, id_residencia, id_origen);

