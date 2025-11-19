-- Postgres script
CREATE TYPE categoria_enum AS ENUM (
  'Vivienda',
  'Alimentación',
  'Transporte',
  'Educación',
  'Ocio y personales',
  'Otros'
);

CREATE TABLE estudiante (
    id_estudiante   INT PRIMARY KEY,
    nombre          VARCHAR(100),
    apellido        VARCHAR(100)
);

CREATE TABLE gastos (
    id_gasto        SERIAL PRIMARY KEY,
    egreso_cantidad NUMERIC(12,2),
    categoria       categoria_enum,
    id_estudiante   INT REFERENCES estudiante(id_estudiante)
);

