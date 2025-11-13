
CREATE DATABASE IF NOT EXISTS mart_gastos;

-- ---------- Dimensiones ----------
CREATE TABLE IF NOT EXISTS mart_gastos.dim_periodo
(
  id_periodo UInt32,                                  -- PK
  semestre LowCardinality(String),
  anio UInt16,
  etiqueta_periodo LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_periodo;

CREATE TABLE IF NOT EXISTS mart_gastos.dim_universidad
(
  id_universidad UInt32,                              -- PK
  nombre_universidad LowCardinality(String),
  carrera LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_universidad;

CREATE TABLE IF NOT EXISTS mart_gastos.dim_origen
(
  id_origen UInt32,                                   -- PK
  ciudad LowCardinality(String),
  provincia LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id_origen;

CREATE TABLE IF NOT EXISTS mart_gastos.dim_estudiante
(
  id_estudiante UInt32,                               -- PK
  genero LowCardinality(String),
  edad UInt8,
  modalidad LowCardinality(String),                   -- Presencial/Híbrida/Virtual
  es_becado UInt8                                     -- 0/1
)
ENGINE = MergeTree
ORDER BY id_estudiante;

CREATE TABLE IF NOT EXISTS mart_gastos.dim_categoria_gasto
(
  id_categoria_gasto UInt32,                          -- PK
  categoria LowCardinality(String)                    -- alimentación, vivienda, etc.
)
ENGINE = MergeTree
ORDER BY id_categoria_gasto;

-- ---------- Hechos ----------
CREATE TABLE IF NOT EXISTS mart_gastos.hechos_gasto
(
  monto_gasto Float32,

  -- Claves (FK lógicas)
  id_estudiante       UInt32,
  id_periodo          UInt32,
  id_universidad      UInt32,
  id_categoria_gasto  UInt32,
  id_origen           UInt32
)
ENGINE = MergeTree
ORDER BY (id_estudiante, id_periodo, id_universidad, id_categoria_gasto, id_origen);
