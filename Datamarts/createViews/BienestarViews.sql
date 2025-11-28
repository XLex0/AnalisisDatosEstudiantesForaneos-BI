CREATE OR REPLACE VIEW dm_bienestar.vw_bienestar_detalle_clean AS
SELECT
    f.id_estudiante,
    e.edad,
    e.genero,
    e.modalidad,
    e.becado,
    u.id_universidad,
    u.universidad,
    u.carrera,
    p.id_periodo,
    p.semestre,
    p.anio,
    p.periodo,
    r.id_residencia,
    r.zona,
    r.sector,
    r.tipo_vivienda,
    r.codigo_postal,
    r.tiempo_traslado_min,
    o.id_origen,
    o.ciudad,
    o.provincia,
    o.longitud,
    o.latitud,
    f.promedio_academico,
    f.indice_bienestar,
    f.distancia_universidad_km,
    f.distancia_origen_km,
    f.num_viajes_origen,
    f.ingreso_total,
    f.egreso_total,
    f.balance_neto
FROM dm_bienestar.fact_bienestar f
JOIN dm_bienestar.dim_estudiante e ON f.id_estudiante  = e.id_estudiante
JOIN dm_bienestar.dim_universidad u ON f.id_universidad = u.id_universidad
JOIN dm_bienestar.dim_periodo     p ON f.id_periodo     = p.id_periodo
JOIN dm_bienestar.dim_residencia  r ON f.id_residencia  = r.id_residencia
JOIN dm_bienestar.dim_origen      o ON f.id_origen      = o.id_origen
WHERE
    -- dim_estudiante (string, no XXX y no numéricos)
    (e.genero    IS NULL OR (e.genero    NOT LIKE '%XXX%' AND toFloat64OrNull(e.genero)    IS NULL)) AND
    (e.modalidad IS NULL OR (e.modalidad NOT LIKE '%XXX%' AND toFloat64OrNull(e.modalidad) IS NULL)) AND

    -- dim_universidad
    (u.universidad IS NULL OR (u.universidad NOT LIKE '%XXX%' AND toFloat64OrNull(u.universidad) IS NULL)) AND
    (u.carrera     IS NULL OR (u.carrera     NOT LIKE '%XXX%' AND toFloat64OrNull(u.carrera)     IS NULL)) AND

    -- dim_periodo
    (p.periodo IS NULL OR (p.periodo NOT LIKE '%XX%' AND toFloat64OrNull(p.periodo) IS NULL)) AND

    -- dim_residencia
    (r.zona          IS NULL OR (r.zona          NOT LIKE '%XXX%' AND toFloat64OrNull(r.zona)          IS NULL)) AND
    (r.sector        IS NULL OR (r.sector        NOT LIKE '%XXX%' AND toFloat64OrNull(r.sector)        IS NULL)) AND
    (r.tipo_vivienda IS NULL OR (r.tipo_vivienda NOT LIKE '%XXX%' AND toFloat64OrNull(r.tipo_vivienda) IS NULL)) AND

    -- dim_origen
    (o.ciudad    IS NULL OR (o.ciudad    NOT LIKE '%XXX%' AND toFloat64OrNull(o.ciudad)    IS NULL)) AND
    (o.provincia IS NULL OR (o.provincia NOT LIKE '%XXX%' AND toFloat64OrNull(o.provincia) IS NULL)) AND

    -- id_estudiante
    (f.id_estudiante NOT LIKE '%XXX%');


-- Chart 1: Lugar de origen,rendimiento académico y bienestar
CREATE OR REPLACE VIEW dm_bienestar.vw_dash1_chart1 AS
SELECT
    provincia,
    ciudad,
    avg(promedio_academico) AS promedio_rendimiento_academico,
    avg(indice_bienestar)   AS indice_bienestar_promedio
FROM dm_bienestar.vw_bienestar_detalle_clean
GROUP BY
    provincia,
    ciudad;


-- Chart 2: Relación ingresos,índice de bienestar
CREATE OR REPLACE VIEW dm_bienestar.vw_dash1_chart2 AS
SELECT
    ingreso_total,
    universidad,
    indice_bienestar
FROM dm_bienestar.vw_bienestar_detalle_clean;


-- Chart 3: Distancia a la universidad, bienestar y rendimiento académico (agrupado cada 2 km)
CREATE OR REPLACE VIEW dm_bienestar.vw_dash1_chart3 AS
SELECT
    floor(distancia_universidad_km / 2) * 2 AS distancia_2km,
    universidad,
    avg(indice_bienestar)   AS indice_bienestar_promedio,
    avg(promedio_academico) AS promedio_rendimiento_academico
FROM dm_bienestar.vw_bienestar_detalle_clean
WHERE distancia_universidad_km IS NOT NULL
GROUP BY
    distancia_2km,
    universidad
HAVING
    distancia_2km > 0
ORDER BY
    distancia_2km,
    universidad;



-- Chart 4: Mapa de zonas de residencia principales y nivel de bienestar
CREATE OR REPLACE VIEW dm_bienestar.vw_dash1_chart4 AS
SELECT
    sector,
    avg(indice_bienestar)          AS nivel_bienestar_promedio,
    countDistinct(f.id_estudiante)   AS cantidad_estudiantes
FROM dm_bienestar.vw_bienestar_detalle_clean
GROUP BY
    sector



CREATE OR REPLACE VIEW dm_bienestar.vw_dash1_chart5 AS
SELECT
    floor(distancia_origen_km / 20) * 20 AS distancia_20km,
    avg(indice_bienestar) AS indice_bienestar_promedio
FROM dm_bienestar.vw_bienestar_detalle_clean
WHERE distancia_origen_km IS NOT NULL
GROUP BY
    distancia_20km
HAVING
    distancia_20km > 15
ORDER BY
    distancia_20km;
