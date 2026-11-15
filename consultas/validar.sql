
CREATE OR REPLACE TABLE errores_por_fila AS
-- R1: Formato ID
SELECT r.rowid, 'id_formato_invalido' AS regla
FROM tema_05_rrhh_raw r
WHERE r.id_empleado IS NULL OR NOT regexp_matches(r.id_empleado, 'EMP[0-9]{4}$')

UNION ALL
-- R2: ID Duplicado
SELECT rowid, 'id_duplicado'
FROM tema_05_rrhh_raw
WHERE id_empleado IN 
( SELECT id_empleado FROM tema_05_rrhh_raw WHERE id_empleado IS NOT NULL
   GROUP BY id_empleado HAVING COUNT(*) > 1 )

UNION ALL
-- R3: Nombre nulo o vacío
SELECT rowid, 'nombre_nulo'
FROM tema_05_rrhh_raw
WHERE nombre IS NULL OR trim(nombre) = ''

UNION ALL
-- R4: Apellido nulo o vacío
SELECT rowid, 'apellido_nulo'
FROM tema_05_rrhh_raw
WHERE apellido IS NULL OR trim(apellido) = ''

UNION ALL

-- R5: Nombre y apellido Primer letra ,ayuscula y luego minuscula y sin espacios extras
SELECT rowid, 'nombre_apellido_formato'
FROM tema_05_rrhh_raw
WHERE (nombre IS NOT NULL AND nombre <> upper(left(trim(nombre),1)) || lower(substr(trim(nombre),2)))
OR (apellido IS NOT NULL AND apellido <> upper(left(trim(apellido),1)) || lower(substr(trim(apellido),2)))

UNION ALL
-- R6: Email nulo
SELECT rowid, 'email_nulo'
FROM tema_05_rrhh_raw
WHERE email IS NULL OR trim(email) = ''

UNION ALL
-- R7: Formato Email
SELECT rowid, 'email_formato_invalido'
FROM tema_05_rrhh_raw
WHERE email IS NOT NULL AND NOT regexp_matches(email, '^[a-z0-9._]+@tecnosur\.com$')

UNION ALL
-- R8: Fecha válida
SELECT rowid, 'fecha_invalida_o_formato'
FROM tema_05_rrhh_raw
WHERE try_strptime(fecha_ingreso, '%Y-%m-%d') IS NULL

UNION ALL
-- R9: Fecha futura
SELECT rowid, 'fecha_futura'
FROM tema_05_rrhh_raw
WHERE try_strptime(fecha_ingreso, '%Y-%m-%d') > current_timestamp

UNION ALL
-- R10: Salario positivo
SELECT rowid, 'salario_no_positivo'
FROM tema_05_rrhh_raw
WHERE salario IS NULL OR salario <= 0

UNION ALL
-- R11: Departamento nulo
SELECT rowid, 'departamento_nulo'
FROM tema_05_rrhh_raw
WHERE departamento IS NULL

UNION ALL
-- R12: Departamento permitido
SELECT rowid, 'departamento_no_permitido'
FROM tema_05_rrhh_raw
WHERE departamento IS NOT NULL AND departamento NOT IN ('Tecnologia','Finanzas','RRHH','Comercial')

UNION ALL
-- R13: Modalidad permitida
SELECT rowid, 'modalidad_no_permitida'
FROM tema_05_rrhh_raw
WHERE modalidad IS NULL OR modalidad NOT IN ('presencial','remoto','hibrido')

UNION ALL
-- R14: Cargo nulo
SELECT rowid, 'cargo_nulo'
FROM tema_05_rrhh_raw
WHERE cargo IS NULL OR trim(cargo) = '';


CREATE OR REPLACE TABLE motivos_agrupados AS
SELECT rowid, string_agg(regla, '; ') AS motivo_rechazo
FROM errores_por_fila
GROUP BY rowid;


-- VÁLIDOS
CREATE OR REPLACE TABLE validos AS
SELECT id_empleado, nombre, apellido, email, fecha_ingreso, departamento, cargo, salario, modalidad
FROM tema_05_rrhh_raw
WHERE rowid NOT IN (SELECT rowid FROM motivos_agrupados);

-- RECHAZADOS
CREATE OR REPLACE TABLE rechazados AS
SELECT r.id_empleado, r.nombre, r.apellido, r.email, r.fecha_ingreso, r.departamento, r.cargo, r.salario, r.modalidad, m.motivo_rechazo 
FROM tema_05_rrhh_raw r, motivos_agrupados m
WHERE r.rowid = m.rowid;

-- RESUMEN DE RECHAZOS
CREATE OR REPLACE TABLE resumen_rechazos AS
SELECT regla, COUNT(*) AS cantidad
FROM errores_por_fila
GROUP BY regla
ORDER BY cantidad DESC;