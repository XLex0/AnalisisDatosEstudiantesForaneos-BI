
CREATE OR REPLACE VIEW dm_economia.vw_economia_detalle_clean AS
SELECT
    f.id_estudiante,
    e.edad,
    e.genero,
    e.modalidad,
    e.becado,
    p.id_periodo,
    p.semestre,
    p.anio,
    p.periodo,
    u.id_universidad,
    u.universidad,
    u.carrera,
    o.id_origen,
    o.ciudad,
    o.provincia,
    fi.id_fuente_ingresos,
    fi.tipo_fuente,
    f.ingresos_totales,
    f.egresos_totales,
    f.balance_neto
FROM dm_economia.fact_economia f
JOIN dm_economia.dim_estudiante      e  ON f.id_estudiante      = e.id_estudiante
JOIN dm_economia.dim_periodo         p  ON f.id_periodo         = p.id_periodo
JOIN dm_economia.dim_universidad     u  ON f.id_universidad     = u.id_universidad
JOIN dm_economia.dim_origen          o  ON f.id_origen          = o.id_origen
JOIN dm_economia.dim_fuente_ingreso  fi ON f.id_fuente_ingresos = fi.id_fuente_ingresos
WHERE
    -- dim_estudiante
    (e.genero        IS NULL OR (e.genero        NOT LIKE '%XXX%' AND toFloat64OrNull(e.genero)        IS NULL)) AND
    (e.modalidad     IS NULL OR (e.modalidad     NOT LIKE '%XXX%' AND toFloat64OrNull(e.modalidad)     IS NULL)) AND

    -- dim_periodo
    (p.periodo       IS NULL OR (p.periodo       NOT LIKE '%XX%' AND toFloat64OrNull(p.periodo)       IS NULL)) AND

    -- dim_universidad
    (u.universidad   IS NULL OR (u.universidad   NOT LIKE '%XXX%' AND toFloat64OrNull(u.universidad)   IS NULL)) AND
    (u.carrera       IS NULL OR (u.carrera       NOT LIKE '%XXX%' AND toFloat64OrNull(u.carrera)       IS NULL)) AND

    -- dim_origen
    (o.ciudad        IS NULL OR (o.ciudad        NOT LIKE '%XXX%' AND toFloat64OrNull(o.ciudad)        IS NULL)) AND
    (o.provincia     IS NULL OR (o.provincia     NOT LIKE '%XXX%' AND toFloat64OrNull(o.provincia)     IS NULL)) AND

    -- dim_fuente_ingreso
    (fi.tipo_fuente  IS NULL OR (fi.tipo_fuente  NOT LIKE '%XXX%' AND toFloat64OrNull(fi.tipo_fuente)  IS NULL)) AND

    -- id_estudiante: solo limpiamos XXX, permitimos numérico
    (f.id_estudiante NOT LIKE '%XXX%');


CREATE OR REPLACE VIEW dm_gastos.vw_gastos_detalle_clean AS
SELECT
    f.id_estudiante,
    e.edad,
    e.genero,
    e.modalidad,
    e.becado,
    p.id_periodo,
    p.semestre,
    p.anio,
    p.periodo,
    u.id_universidad,
    u.universidad,
    u.carrera,
    o.id_origen,
    o.ciudad,
    o.provincia,
    cg.id_categoria_gasto,
    cg.categoria,
    f.monto_gasto
FROM dm_gastos.fact_gasto f
JOIN dm_gastos.dim_estudiante      e  ON f.id_estudiante      = e.id_estudiante
JOIN dm_gastos.dim_periodo         p  ON f.id_periodo         = p.id_periodo
JOIN dm_gastos.dim_universidad     u  ON f.id_universidad     = u.id_universidad
JOIN dm_gastos.dim_origen          o  ON f.id_origen          = o.id_origen
JOIN dm_gastos.dim_categoria_gasto cg ON f.id_categoria_gasto = cg.id_categoria_gasto
WHERE
    -- dim_estudiante
    (e.genero        IS NULL OR (e.genero        NOT LIKE '%XXX%' AND toFloat64OrNull(e.genero)        IS NULL)) AND
    (e.modalidad     IS NULL OR (e.modalidad     NOT LIKE '%XXX%' AND toFloat64OrNull(e.modalidad)     IS NULL)) AND

    -- dim_periodo
    (p.periodo       IS NULL OR (p.periodo       NOT LIKE '%XXX%' AND toFloat64OrNull(p.periodo)       IS NULL)) AND

    -- dim_universidad
    (u.universidad   IS NULL OR (u.universidad   NOT LIKE '%XXX%' AND toFloat64OrNull(u.universidad)   IS NULL)) AND
    (u.carrera       IS NULL OR (u.carrera       NOT LIKE '%XXX%' AND toFloat64OrNull(u.carrera)       IS NULL)) AND

    -- dim_origen
    (o.ciudad        IS NULL OR (o.ciudad        NOT LIKE '%XXX%' AND toFloat64OrNull(o.ciudad)        IS NULL)) AND
    (o.provincia     IS NULL OR (o.provincia     NOT LIKE '%XXX%' AND toFloat64OrNull(o.provincia)     IS NULL)) AND

    -- dim_categoria_gasto
    (cg.categoria    IS NULL OR (cg.categoria    NOT LIKE '%XXX%' AND toFloat64OrNull(cg.categoria)    IS NULL)) AND

    -- id_estudiante: solo limpiamos XXX, permitimos numérico
    (f.id_estudiante NOT LIKE '%XXX%');


-- Chart 1: Lugar de origen ↔ ingresos y egresos totales
CREATE OR REPLACE VIEW dm_economia.vw_dash2_chart1 AS
SELECT
    provincia,
    ciudad,
    sum(ingresos_totales) AS ingresos_totales,
    sum(egresos_totales)  AS egresos_totales
FROM dm_economia.vw_economia_detalle_clean
GROUP BY
    provincia,
    ciudad;


-- Chart 2: Balance neto promedio por universidad
CREATE OR REPLACE VIEW dm_economia.vw_dash2_chart2 AS
SELECT
    universidad,
    avg(balance_neto) AS balance_neto_promedio
FROM dm_economia.vw_economia_detalle_clean
GROUP BY
    universidad;


-- Chart 3: Número de becas ↔ ciudad de origen
CREATE OR REPLACE VIEW dm_economia.vw_dash2_chart3 AS
SELECT
    provincia,
    ciudad,
    sum(becado) AS total_becas
FROM dm_economia.vw_economia_detalle_clean
GROUP BY
    provincia,
    ciudad;


-- Chart 4: Proporción de gasto por categoría
CREATE OR REPLACE VIEW dm_economia.vw_dash2_chart4 AS
SELECT
    categoria AS tipo_gasto,
    sum(monto_gasto) AS egresos_totales_categoria,
    sum(monto_gasto) / sum(sum(monto_gasto)) OVER () AS porcentaje_egresos
FROM dm_gastos.vw_gastos_detalle_clean
GROUP BY
    categoria;


-- Chart 5: Evolución del balance económico
CREATE OR REPLACE VIEW dm_economia.vw_dash2_chart5 AS
SELECT
    periodo,
    avg(balance_neto) AS balance_neto_promedio
FROM dm_economia.vw_economia_detalle_clean
GROUP BY
    periodo;
