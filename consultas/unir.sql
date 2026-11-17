CREATE OR REPLACE TABLE rechazados_unicos AS
SELECT r.* FROM rechazados_limpios r
JOIN (
    SELECT id_empleado, MIN(rowid) AS primer_rowid
    FROM rechazados_limpios
    GROUP BY id_empleado
) u ON r.rowid = u.primer_rowid;

CREATE OR REPLACE TABLE tabla_final AS
-- válidos
SELECT
    CAST(id_empleado AS VARCHAR) AS id_empleado,
    CAST(nombre AS VARCHAR) AS nombre,
    CAST(apellido AS VARCHAR) AS apellido,
    CAST(email AS VARCHAR) AS email,
    CAST(fecha_ingreso AS DATE) AS fecha_ingreso,
    CAST(departamento AS VARCHAR) AS departamento,
    CAST(cargo AS VARCHAR) AS cargo,
    CAST(salario AS DOUBLE) AS salario,
    CAST(modalidad AS VARCHAR) AS modalidad
FROM validos

UNION ALL

-- los limpios 
SELECT
    CAST(r.id_empleado AS VARCHAR),
    CAST(r.nombre AS VARCHAR),
    CAST(r.apellido AS VARCHAR),
    CAST(r.email AS VARCHAR),
    CAST(r.fecha_ingreso AS DATE),
    CAST(r.departamento AS VARCHAR),
    CAST(r.cargo AS VARCHAR),
    CAST(r.salario AS DOUBLE),
    CAST(r.modalidad AS VARCHAR)
FROM rechazados_unicos r
LEFT JOIN validos v ON r.id_empleado = v.id_empleado
WHERE v.id_empleado IS NULL;