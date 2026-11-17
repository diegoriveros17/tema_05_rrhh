
CREATE OR REPLACE TABLE cargo_departamento AS
SELECT cargo, MAX(departamento) AS departamento
FROM validos
GROUP BY cargo;

CREATE OR REPLACE TABLE rechazados_base AS
SELECT
    trim(id_empleado) AS id_empleado,
    upper(left(trim(nombre), 1)) || lower(substr(trim(nombre), 2)) AS nombre,
    upper(left(trim(apellido), 1)) || lower(substr(trim(apellido), 2)) AS apellido,
    lower(trim(email)) AS email,
    CAST( coalesce(
            try_strptime(trim(fecha_ingreso), '%Y-%m-%d'),
            try_strptime(trim(fecha_ingreso), '%d/%m/%Y')
        ) AS DATE
    ) AS fecha_ingreso,
    nullif(trim(departamento), '') AS departamento,
    trim(cargo) AS cargo,
    abs(salario) AS salario,
    lower(trim(modalidad)) AS modalidad, motivo_rechazo
FROM rechazados
WHERE motivo_rechazo <> 'id_duplicado';

CREATE OR REPLACE TABLE rechazados_limpios AS
SELECT b.id_empleado, b.nombre, b.apellido,
    coalesce( nullif(b.email, ''),
        lower( b.nombre || '.' || b.apellido || 
            coalesce(nullif(ltrim(substr(b.id_empleado, 4), '0'), ''), '0') || 
            '@tecnosur.com'
        )
    ) AS email,
    b.fecha_ingreso,
    coalesce(b.departamento, m.departamento) AS departamento,
    b.cargo,
    b.salario,
    b.modalidad,
    b.motivo_rechazo
FROM rechazados_base b
JOIN cargo_departamento m ON m.cargo = b.cargo;