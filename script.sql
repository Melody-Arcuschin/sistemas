-- Database: Horas

-- DROP DATABASE IF EXISTS "Horas";


/* CREATE DATABASE "Horas"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Argentina.1252'
    LC_CTYPE = 'Spanish_Argentina.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;*/
	
--creo la primer tabla
/*DROP TABLE IF EXISTS "empleadores";
	CREATE TABLE empleadores (
	nivel text,
   	anio int,
   	gestion text,
	unidades_educativas int,
    PRIMARY KEY (nivel, anio, gestion)
);*/

--importo los datos: Databases → Schemas → public → Tables (import/export data)

SELECT * FROM empleadores;

/* creo la segunda tabla
DROP TABLE IF EXISTS "niveles";
	CREATE TABLE niveles (
	nivel text,
  	desde_edad text,
	hasta_edad text,
    PRIMARY KEY (nivel)
);*/

--importo los datos: Databases → Schemas → public → Tables (import/export data)

SELECT * FROM niveles;

/* creo la tercer tabla
DROP TABLE IF EXISTS "horas_catedra";
CREATE TABLE horas_catedra (
	nivel text,
    	anio int,
	gestion text,
	contratacion text,
	horas numeric,
    PRIMARY KEY (nivel, anio, gestion, contratacion)
);*/

--importo los datos: Databases → Schemas → public → Tables (import/export data)
SELECT * FROM horas_catedra;

--Cuestiones a saber: 
--Porcentaje de horas cátedra fuera de la planta funcional sobre el total de horas cátedra, agrupando por años.
--Se aprecia un descenso importante de las horas fuera de la planta funcional hacia el presente. Es de destacar que la excepción a esto es el año 2020, quizá por cuestiones vinculadas con la pandemia.
SELECT anio, (SUM(CASE WHEN contratacion = 'Fuera de planta' THEN horas ELSE 0 END)/ NULLIF(SUM(horas), 0)) * 100.0  AS "porcentaje de horas fuera de planta"
FROM horas_catedra
GROUP BY anio
ORDER BY anio;

--Porcentaje de horas cátedra fuera de la planta funcional sobre el total de horas cátedra, agrupando por nivel.
--Se aprecia mayor un mayor porcentaje de horas fuera de la planta funcional en escuelas de nivel inicial y primario que en escuelas de nivel secundario.
SELECT nivel, (SUM(CASE WHEN contratacion = 'Fuera de planta' THEN horas ELSE 0 END) / NULLIF(SUM(horas), 0)) * 100.0 AS "porcentaje de horas fuera de planta"
FROM horas_catedra
GROUP BY nivel
ORDER BY nivel;

--Porcentaje de horas cátedra fuera de la planta funcional sobre el total de horas cátedra, agrupando por sector de gestión.
--Se aprecia mayor un mayor porcentaje de horas fuera de la planta funcional en escuelas de gestión privada que en escuelas de gestión estatal.
SELECT gestion, (SUM(CASE WHEN contratacion = 'Fuera de planta' THEN horas ELSE 0 END) / NULLIF(SUM(horas), 0)) * 100.0 AS "porcentaje de horas fuera de planta"
FROM horas_catedra
GROUP BY gestion
ORDER BY gestion;

--Ahora se retomarán todas las variables en cuestión:
CREATE TEMPORARY TABLE todas_las_variables AS
	SELECT anio, nivel, gestion, (SUM(CASE WHEN contratacion = 'Fuera de planta' THEN horas ELSE 0 END) * 100.0 / NULLIF(SUM(horas), 0)) AS "porcentaje de horas fuera de planta"
	FROM horas_catedra
	GROUP BY anio, nivel, gestion
	ORDER BY anio, nivel, gestion;
	
SELECT * FROM todas_las_variables;

--------------------------------------------------------------------------------------
--Como se podía predecir por los datos anteriormente nombrados, el mayor porcentaje de horas fuera de planta se encuentra en el 2015, nivel inicial y gestión privada: 
SELECT anio, nivel, gestion, "porcentaje de horas fuera de planta"
FROM todas_las_variables
ORDER BY "porcentaje de horas fuera de planta" DESC
LIMIT 1;

--En cambio, el menor porcentaje de horas fuera de planta se encuentra en el 2019, nivel secundario y gestión estatal:
SELECT anio, nivel, gestion, "porcentaje de horas fuera de planta"
FROM todas_las_variables
ORDER BY "porcentaje de horas fuera de planta" ASC
LIMIT 1;

--------------------------------------------------------------------------------------
--Cantidad de horas cátedra (total y fuera de planta funcional) promedio por unidad educativa, diferenciando por año, nivel y tipo de gestión.
SELECT
    e.nivel,
	e.anio,
    e.gestion,
	e.unidades_educativas AS "cantidad de unidades educativas",
    SUM(hc.horas) / e.unidades_educativas AS "promedio de horas cátedra por unidad educativa",
	SUM(CASE WHEN hc.contratacion = 'Fuera de planta' THEN hc.horas ELSE 0 END) / e.unidades_educativas AS "promedio de horas cátedra fuera de planta por unidad educativa",
	(SUM(CASE WHEN hc.contratacion = 'Fuera de planta' THEN hc.horas ELSE 0 END) / e.unidades_educativas)/( SUM(hc.horas) / e.unidades_educativas)*100 AS "relación entre horas fuera de planta y horas en total(%)"
	FROM empleadores e
INNER JOIN horas_catedra hc 
ON e.nivel = hc.nivel AND e.anio = hc.anio AND e.gestion = hc.gestion
GROUP BY e.anio, e.nivel, e.gestion
ORDER BY "relación entre horas fuera de planta y horas en total(%)" DESC;







