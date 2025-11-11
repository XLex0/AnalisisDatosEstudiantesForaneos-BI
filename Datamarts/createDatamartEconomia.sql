
CREATE DATABASE IF NOT EXISTS mart_economia_general;

-- ---------- Dimensiones ----------
CREATE TABLE IF NOT EXISTS mart_economia_general.dim_periodo
(
  id_periodo UInt32,                               -- PK (mes/semestre)
  semestre LowCardinality(String),
  anio UInt16,
  etiqueta_periodo LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_periodo;

CREATE TABLE IF NOT EXISTS mart_economia_general.dim_universidad
(
  id_universidad UInt32,                           -- PK
  nombre_universidad LowCardinality(String),
  carrera LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_universidad;

CREATE TABLE IF NOT EXISTS mart_economia_general.dim_origen
(
  id_origen UInt32,                                -- PK
  ciudad LowCardinality(String),
  provincia LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_origen;

CREATE TABLE IF NOT EXISTS mart_economia_general.dim_fuente_ingreso
(
  id_fuente_ingresos UInt32,                       -- PK
  tipo_fuente LowCardinality(String)               -- familia/beca/trabajo/otros
)
ENGINE = MergeTree
ORDER BY id_fuente_ingresos;

CREATE TABLE IF NOT EXISTS mart_economia_general.dim_estudiante
(
  id_estudiante UInt32,                            -- PK
  genero LowCardinality(String),
  edad UInt8,
  modalidad LowCardinality(String),                -- Presencial/Híbrida/Virtual
  es_becado UInt8                                  -- 0/1
)
ENGINE = MergeTree
ORDER BY id_estudiante;


-- ---------- Hechos ----------
CREATE TABLE IF NOT EXISTS mart_economia_general.hechos_economia
(
  -- Medidas
  ingresos_totales Float32,
  egresos_totales  Float32,
  balance_neto     Float32,

  -- Claves (FK lógicas)
  id_estudiante      UInt32,
  id_periodo         UInt32,
  id_universidad     UInt32,
  id_residencia      UInt32,
  id_origen          UInt32,
  id_fuente_ingresos UInt32
)
ENGINE = MergeTree
ORDER BY (id_estudiante, id_periodo, id_universidad, id_residencia, id_origen, id_fuente_ingresos);
