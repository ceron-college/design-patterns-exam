-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------          CLEAR PREVIOUS CONFIGURATIONS                 -----------------------------------------------------------------------

-- Drop the 'public' schema and all its contents
DROP SCHEMA public CASCADE;

-- Recreate the 'public' schema
CREATE SCHEMA public;

-- Regrant necessary privileges
GRANT ALL ON SCHEMA public TO your_user;
GRANT ALL ON SCHEMA public TO public;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------         AUXILIARY TABLES SETUP                 -----------------------------------------------------------------------

CREATE TABLE aseguradoras (
    palabra_clave VARCHAR(100),
    nombre VARCHAR(100)
);

INSERT INTO aseguradoras (palabra_clave, nombre) VALUES
(NULL, 'SIN DATO'),
('CAPITAL SALUD', 'CAPITAL SALUD E.P.S.'),
('NUEVA EPS', 'NUEVA EPS S.A'),
('OTR', 'OTROS'),
('SALUD TOTAL', 'SALUD TOTAL S.A'),
('PREPAGADA SURAMERICANA', 'EPS Y MEDICINA PREPAGADA SURAMERICANA S.A'),
('FERROCARRILES NACIONAL', 'FERROCARRILES NACIONAL E.P.S.'),
('BOLIVAR', 'SALUD BOLIVAR E.P.S'),
('COMPENSAR', 'COMPENSAR E.P.S.'),
('SANITAS', 'E.P.S. SANITAS'),
('FAMISANAR', 'FAMISANAR E.P.S. LTDA - CAFAM - COLSUBSIDIO'),
('COLSUBSIDIO', 'FAMISANAR E.P.S. LTDA - CAFAM - COLSUBSIDIO'),
('CAFAM', 'FAMISANAR E.P.S. LTDA - CAFAM - COLSUBSIDIO'),
('ALIANSALUD', 'ALIANSALUD E.P.S.'),
('COOSALUD', 'COOSALUD E.P.S.'),
('SOS E.P.S', 'SOS E.P.S'),
('SOS EPS', 'SOS E.P.S'),
('MALLAMAS', 'MALLAMAS E.P.S.'),
('NO AFILIADO', 'SIN ASEGURAMIENTO');

CREATE TABLE sexos (
    palabra_clave VARCHAR(100),
    nombre VARCHAR(100)
);

INSERT INTO sexos (palabra_clave, nombre) VALUES
(NULL, 'NO REGISTRA'),
('1', 'HOMBRE'),
('2', 'MUJER'),
('3', 'INTERSEXUAL'),
('HOMBRE', 'HOMBRE'),
('MUJER', 'MUJER'),
('HOMBRES', 'HOMBRE'),
('MUJERES', 'MUJER'),
('MASCULINO', 'HOMBRE'),
('FEMENINO', 'MUJER'),
('INTERSEXUAL', 'INTERSEXUAL');

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Establishing the 'poblacion' table to associate 'localidades' across various datasets

CREATE TABLE poblacion (
    ano INT,
    codigo_localidad INT,
    nombre_localidad VARCHAR(50),
    sexo VARCHAR(10),
    edad INT,
    curso_de_vida VARCHAR(20),
    grupo_edad VARCHAR(10),
    poblacion_7 INT
);

COPY poblacion (
    ano, 
    codigo_localidad, 
    nombre_localidad, 
    sexo, 
    edad, 
    curso_de_vida, 
    grupo_edad, 
    poblacion_7
)
FROM '/data/POBLACION.txt'
DELIMITER '|'
CSV HEADER;

CREATE TABLE localidades (
    codigo INT,
    palabra_clave VARCHAR(100),
    nombre VARCHAR(100)
);

INSERT INTO localidades (codigo, palabra_clave, nombre)
SELECT DISTINCT 
    codigo_localidad, 
    nombre_localidad, 
    CONCAT(codigo_localidad, ' - ', nombre_localidad)
FROM poblacion 
WHERE codigo_localidad <> 0;

INSERT INTO localidades (codigo, palabra_clave, nombre) VALUES
(0, 'Bogota', '99 - Localidad Desconocida'),
(99, 'Bogota', '99 - Localidad Desconocida');

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-------------------                                            HANDLING PROGRAM 1 DATA                    ------------------------------------

CREATE TABLE temp_programa_1 (
    regimen_afiliacion VARCHAR(100),
    localidad_calculada VARCHAR(50),
    asegurador VARCHAR(100),
    fecha_nacimiento TEXT,
    sexo VARCHAR(50),
    fecha_consulta TEXT,
    nacionalidad VARCHAR(50) 
);

COPY temp_programa_1 (
    regimen_afiliacion, 
    localidad_calculada, 
    asegurador, 
    fecha_nacimiento, 
    sexo, 
    fecha_consulta, 
    nacionalidad
)
FROM '/data/PROGRAMA_1.txt'
DELIMITER ','
CSV HEADER;

CREATE TABLE programa_1 (
    localidad VARCHAR(50),
    eapb VARCHAR(100),
    edad INT,
    sexo VARCHAR(50),
    fecha_caracterizacion DATE
);

-- Populating programa_1 with processed information

INSERT INTO programa_1 (
    localidad, 
    eapb,
    edad, 
    sexo, 
    fecha_caracterizacion
)
SELECT 
    COALESCE(
        (
            SELECT loc.nombre
            FROM localidades loc
            WHERE tm.localidad_calculada ILIKE '%' || loc.palabra_clave || '%'
            LIMIT 1
        ), 
        '99 - Localidad desconocida'
    ) AS localidad,
    COALESCE(
        (
            SELECT aseg.nombre
            FROM aseguradoras aseg
            WHERE tm.asegurador ILIKE '%' || aseg.palabra_clave || '%'
            LIMIT 1
        ), 
        'OTROS'
    ) AS eapb,
    CASE 
        WHEN tm.fecha_nacimiento ~ '^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/\d{4}$'
             AND (
                 (CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 31) AND  
                 (CAST(SUBSTRING(tm.fecha_nacimiento FROM '/(0?[1-9]|1[0-2])/') AS INT) <= 12) AND  
                 (
                     (SUBSTRING(tm.fecha_nacimiento FROM '/(0?2)/') IS NULL OR CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 29) OR 
                     (SUBSTRING(tm.fecha_nacimiento FROM '/(0?[469]|11)/') IS NULL OR CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 30) 
                 )
             )
            THEN EXTRACT(YEAR FROM AGE(TO_DATE(tm.fecha_nacimiento, 'DD/MM/YYYY')))
        ELSE NULL 
    END AS edad,
    CASE 
        WHEN LOWER(tm.sexo) = 'masculino' THEN 'HOMBRE' 
        ELSE 'MUJER' 
    END AS sexo,
    CASE 
        WHEN tm.fecha_consulta ~ '^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/\d{4}$'
             AND (
                 (CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 31) AND  
                 (CAST(SUBSTRING(tm.fecha_consulta FROM '/(0?[1-9]|1[0-2])/') AS INT) <= 12) AND 
                 (
                     (SUBSTRING(tm.fecha_consulta FROM '/(0?2)/') IS NULL OR CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 29) OR 
                     (SUBSTRING(tm.fecha_consulta FROM '/(0?[469]|11)/') IS NULL OR CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 30)  
                 )
             )
            THEN TO_DATE(tm.fecha_consulta, 'DD/MM/YYYY')
        ELSE NULL 
    END AS fecha_caracterizacion
FROM temp_programa_1 tm;

DROP TABLE temp_programa_1;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------         HANDLING PROGRAM 2 DATA        ---------------------------------------------------------------

CREATE TABLE temp_programa_2 (
    sexo_biologico VARCHAR(100),
    localidad VARCHAR(100),
    eapb VARCHAR(100),
    fecha_nacimiento TEXT,
    pertenencia_etnica VARCHAR(100),
    sexo_biologico_1 VARCHAR(100),
    riesgo_psicosocial VARCHAR(10),
    fecha_consulta TEXT,
    talla TEXT
);

COPY temp_programa_2 (
    sexo_biologico, 
    localidad, 
    eapb, 
    fecha_nacimiento, 
    pertenencia_etnica, 
    sexo_biologico_1, 
    riesgo_psicosocial,
    fecha_consulta, 
    talla 
)
FROM '/data/PROGRAMA_2.txt'
DELIMITER '|'
CSV HEADER;

CREATE TABLE programa_2 (
    sexo VARCHAR(100),
    localidad VARCHAR(100),
    eapb VARCHAR(100),
    edad INT,
    fecha_caracterizacion DATE
);

-- Populating programa_2 with transformed data

INSERT INTO programa_2 (
    sexo, 
    localidad, 
    eapb, 
    edad, 
    fecha_caracterizacion
)
SELECT 
    COALESCE(
        (
            SELECT sex.nombre
            FROM sexos sex
            WHERE tm.sexo_biologico ILIKE '%' || sex.palabra_clave || '%'
            LIMIT 1
        ), 
        'NO REGISTRA'
    ) AS sexo,
    COALESCE(
        (
            SELECT loc.nombre
            FROM localidades loc
            WHERE tm.localidad ILIKE '%' || loc.palabra_clave || '%'
            LIMIT 1
        ), 
        '99 - Localidad desconocida'
    ) AS localidad,
    'SIN DATO' AS eapb,
    CASE 
        WHEN tm.fecha_nacimiento ~ '^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/\d{4}$'
             AND (
                 (CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 31) AND  
                 (CAST(SUBSTRING(tm.fecha_nacimiento FROM '/(0?[1-9]|1[0-2])/') AS INT) <= 12) AND  
                 (
                     (SUBSTRING(tm.fecha_nacimiento FROM '/(0?2)/') IS NULL OR CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 29) OR 
                     (SUBSTRING(tm.fecha_nacimiento FROM '/(0?[469]|11)/') IS NULL OR CAST(SUBSTRING(tm.fecha_nacimiento FROM '^[0-3]?[0-9]') AS INT) <= 30) 
                 )
             )
            THEN EXTRACT(YEAR FROM AGE(TO_DATE(tm.fecha_nacimiento, 'DD/MM/YYYY')))
        ELSE NULL 
    END AS edad,
    CASE 
        WHEN tm.fecha_consulta ~ '^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/\d{4}$'
             AND (
                 (CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 31) AND  
                 (CAST(SUBSTRING(tm.fecha_consulta FROM '/(0?[1-9]|1[0-2])/') AS INT) <= 12) AND 
                 (
                     (SUBSTRING(tm.fecha_consulta FROM '/(0?2)/') IS NULL OR CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 29) OR 
                     (SUBSTRING(tm.fecha_consulta FROM '/(0?[469]|11)/') IS NULL OR CAST(SUBSTRING(tm.fecha_consulta FROM '^[0-3]?[0-9]') AS INT) <= 30)  
                 )
             )
            THEN TO_DATE(tm.fecha_consulta, 'DD/MM/YYYY')
        ELSE NULL 
    END AS fecha_caracterizacion
FROM temp_programa_2 tm;

DROP TABLE temp_programa_2;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------         HANDLING PROGRAM 3 DATA        ---------------------------------------------------------------

CREATE TABLE temp_programa_3 (
    localidadfic_3 VARCHAR(100),
    nacionalidad_10 VARCHAR(100),
    nombreeapb_27 VARCHAR(100),
    fecha_nacimiento_14 TEXT,
    etnia_18 VARCHAR(100),
    sexo_11 VARCHAR(100),
    genero_12 VARCHAR(100),
    fecha_intervencion_2 TEXT
);

COPY temp_programa_3 (
    localidadfic_3, 
    nacionalidad_10, 
    nombreeapb_27, 
    fecha_nacimiento_14, 
    etnia_18, 
    sexo_11, 
    genero_12,
    fecha_intervencion_2
)
FROM '/data/PROGRAMA_3.txt'
DELIMITER '|'
CSV HEADER;

CREATE TABLE programa_3 (
    localidad VARCHAR(100),
    eapb VARCHAR(100),
    edad INT,
    sexo VARCHAR(100),
    fecha_caracterizacion DATE
);

-- Populating programa_3 with cleaned data

INSERT INTO programa_3 (
    localidad, 
    eapb, 
    edad, 
    sexo, 
    fecha_caracterizacion
)
SELECT 
    COALESCE(
        (
            SELECT loc.nombre
            FROM localidades loc
            WHERE tm.localidadfic_3 ILIKE '%' || loc.palabra_clave || '%'
            LIMIT 1
        ), 
        '99 - Localidad desconocida'
    ) AS localidad,
    COALESCE(
        (
            SELECT aseg.nombre
            FROM aseguradoras aseg
            WHERE tm.nombreeapb_27 ILIKE '%' || aseg.palabra_clave || '%'
            LIMIT 1
        ), 
        'OTROS'
    ) AS eapb,
    CASE 
        WHEN tm.fecha_nacimiento_14 ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' 
            THEN EXTRACT(YEAR FROM AGE(TO_TIMESTAMP(tm.fecha_nacimiento_14, 'YYYY-MM-DD HH24:MI:SS')::DATE)) 
        ELSE NULL 
    END AS edad,
    COALESCE(
        (
            SELECT sex.nombre
            FROM sexos sex
            WHERE tm.sexo_11 ILIKE '%' || sex.palabra_clave || '%'
            LIMIT 1
        ), 
        'NO REGISTRA'
    ) AS sexo,
    TO_TIMESTAMP(tm.fecha_intervencion_2, 'YYYYMMDD HH24MISS')::DATE AS fecha_caracterizacion
FROM temp_programa_3 tm;

DROP TABLE temp_programa_3;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------         HANDLING PROGRAM 4 DATA        ---------------------------------------------------------------

CREATE TABLE temp_programa_4 (
    localidad_fic INTEGER,
    estado_civil VARCHAR(100),
    nombre_eapb VARCHAR(100),
    fecha_nacimiento TEXT,
    etnia VARCHAR(100),
    profesion VARCHAR(100),
    fecha_intervencion TEXT
);

COPY temp_programa_4 (
    localidad_fic, 
    estado_civil, 
    nombre_eapb, 
    fecha_nacimiento, 
    etnia, 
    profesion,
    fecha_intervencion
)
FROM '/data/PROGRAMA_4.txt'
DELIMITER '|'
CSV HEADER;

CREATE TABLE programa_4 (
    localidad VARCHAR(100),
    eapb VARCHAR(100),
    edad INT,
    sexo VARCHAR(100),
    fecha_caracterizacion DATE
);

-- Populating programa_4 with refined data

INSERT INTO programa_4 (
    localidad, 
    eapb, 
    edad, 
    sexo, 
    fecha_caracterizacion
)
SELECT 
    COALESCE(
        (
            SELECT loc.nombre
            FROM localidades loc
            WHERE tm.localidad_fic = loc.codigo
            LIMIT 1
        ), 
        '99 - Localidad desconocida'
    ) AS localidad,
    COALESCE(
        (
            SELECT aseg.nombre
            FROM aseguradoras aseg
            WHERE tm.nombre_eapb ILIKE '%' || aseg.palabra_clave || '%'
            LIMIT 1
        ), 
        'OTROS'
    ) AS eapb,
    CASE 
        WHEN tm.fecha_nacimiento ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' 
            THEN EXTRACT(YEAR FROM AGE(TO_TIMESTAMP(tm.fecha_nacimiento, 'YYYY-MM-DD HH24:MI:SS')::DATE))
        ELSE NULL 
    END AS edad,
    'NO REGISTRA' AS sexo,
    CASE 
        WHEN tm.fecha_intervencion ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' 
            THEN TO_TIMESTAMP(tm.fecha_intervencion, 'YYYY-MM-DD HH24:MI:SS')::DATE 
        ELSE NULL 
    END AS fecha_caracterizacion
FROM temp_programa_4 tm;

DROP TABLE temp_programa_4;

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------          COMBINED DATA VIEW                     -----------------------------------------------------------

CREATE VIEW vista_consolidado AS
SELECT 
    localidad, 
    eapb, 
    edad, 
    sexo, 
    'PROGRAMA 4' AS programa, 
    fecha_caracterizacion
FROM programa_4
UNION ALL
SELECT 
    localidad, 
    eapb, 
    edad, 
    sexo,
    'PROGRAMA 3' AS programa, 
    fecha_caracterizacion
FROM programa_3
UNION ALL
SELECT 
    localidad, 
    eapb, 
    edad, 
    sexo,
    'PROGRAMA 2' AS programa, 
    fecha_caracterizacion
FROM programa_2
UNION ALL
SELECT 
    localidad, 
    eapb, 
    edad, 
    sexo,
    'PROGRAMA 1' AS programa, 
    fecha_caracterizacion
FROM programa_1;

-- Saving the consolidated dataset to an output file
COPY (SELECT * FROM vista_consolidado) 
TO '/data/consolidated_output.txt' 
(FORMAT text, DELIMITER '|', HEADER);

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------          PERFORMANCE METRICS VIEW               -----------------------------------------------------------

CREATE VIEW vista_indicadores AS
WITH atendidos AS (
    SELECT 
        EXTRACT(YEAR FROM subat.fecha) AS ano,
        COUNT(*) AS total,
        subat.grupo_edad,
        subat.cod_loc,
        subat.localidad
    FROM (
        SELECT 
            vs.localidad,
            vs.fecha_caracterizacion AS fecha,
            CASE 
                WHEN vs.localidad <> '99 - Localidad desconocida' 
                THEN CAST(LEFT(vs.localidad, 2) AS INT) 
                ELSE 0 
            END AS cod_loc,
            (
                SELECT p.grupo_edad
                FROM poblacion p
                WHERE 
                    (p.grupo_edad = '100 o más' AND vs.edad >= 100) OR
                    (p.grupo_edad <> '100 o más' AND vs.edad BETWEEN CAST(LEFT(p.grupo_edad, 2) AS INT) 
                        AND CAST(SUBSTRING(p.grupo_edad, 6, 2) AS INT))
                LIMIT 1
            ) AS grupo_edad
        FROM vista_consolidado vs
    ) subat
    GROUP BY 
        EXTRACT(YEAR FROM subat.fecha), 
        subat.grupo_edad, 
        subat.cod_loc, 
        subat.localidad
),
pobla AS (
    SELECT 
        subpob.cod_loc,
        subpob.ano, 
        subpob.grupo_edad,
        SUM(subpob.poblacion_7) AS poblacion
    FROM (
        SELECT
            ano,
            CASE 
                WHEN codigo_localidad <> 0 THEN codigo_localidad 
                ELSE 99 
            END AS cod_loc,
            grupo_edad,
            poblacion_7
        FROM poblacion pob 
    ) AS subpob
    GROUP BY 
        subpob.cod_loc, 
        subpob.ano, 
        subpob.grupo_edad
)
SELECT  
    pob.ano AS año, 
    ate.localidad, 
    pob.grupo_edad AS quinquenio, 
    SUM(pob.poblacion) AS poblacion, 
    SUM(ate.total) AS atendidos,
    SUM(ate.total)::FLOAT / SUM(pob.poblacion) AS indicador_atendidos
FROM pobla pob
JOIN atendidos ate 
    ON ate.grupo_edad = pob.grupo_edad 
    AND ate.cod_loc = pob.cod_loc 
    AND ate.ano = pob.ano
GROUP BY 
    pob.grupo_edad, 
    ate.localidad, 
    pob.ano;

-- Exporting performance metrics to a designated file
COPY (SELECT * FROM vista_indicadores) 
TO '/data/performance_metrics_output.txt' 
(FORMAT text, DELIMITER '|', HEADER);
