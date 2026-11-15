-- P1 ¿Cual es el salario promedio por departamento?
CREATE OR REPLACE TABLE respuesta_1 AS
SELECT departamento, round(avg(salario), 2) AS salario_promedio
FROM tabla_final GROUP BY departamento
ORDER BY salario_promedio DESC;

-- P2 ¿Cuanto es la masa salarial total de la empresa?
CREATE OR REPLACE TABLE respuesta_2 AS
SELECT sum(salario) AS masa_salarial_total FROM tabla_final;

-- P3 ¿Cuantos empleados hay por modalidad de trabajo?
CREATE OR REPLACE TABLE respuesta_3 AS
SELECT modalidad, count(*) AS empleados
FROM tabla_final GROUP BY modalidad
ORDER BY empleados DESC;

-- P4 ¿Cuantos empleados ingresaron por año?
CREATE OR REPLACE TABLE respuesta_4 AS
SELECT year(fecha_ingreso) AS anio, count(*) AS ingresos
FROM tabla_final GROUP BY anio ORDER BY anio;

-- P5 ¿Cuales son los 3 cargos con mejor salario promedio?
CREATE OR REPLACE TABLE respuesta_5 AS
SELECT cargo, round(avg(salario), 2) AS salario_promedio
FROM tabla_final GROUP BY cargo
ORDER BY salario_promedio DESC LIMIT 3;
