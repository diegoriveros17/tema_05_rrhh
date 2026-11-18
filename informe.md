# Informe – Pipeline ETL RRHH (TecnoSur S.A.)

**Flujo:** SQLite → `raw_empleados` → `validos` / `rechazados` → `rechazados_limpios` → `tabla_final` → preguntas SQL. Orquestado con Airflow (`0 2 * * *`).

## Problemas encontrados (2575 filas, 2500 ids únicos)

- **75 filas duplicadas** exactas (mismo `id_empleado`).
- **256 fechas** en formato `DD/MM/YYYY` en vez de `YYYY-MM-DD`.
- **102 salarios negativos** (se asume signo cargado al revés → valor absoluto).
- **160 departamentos nulos** y **153 emails nulos**.
- **360 registros** con nombre/apellido en MAYÚSCULAS o con espacios sobrantes.

## Resultado por etapa

raw = 2575 · validos = 1500 · rechazados = 1075 · rechazados_limpios = 1031 (44 eran solo copias duplicadas y se descartan) · **tabla_final = 2500** (ids únicos, sin nulos).

## Rechazos por regla (un registro puede fallar varias)

- **nombre_apellido_formato:** 360 rechazos
- **fecha_invalida_o_formato:** 256 rechazos
- **departamento_nulo:** 160 rechazos
- **email_nulo:** 153 rechazos
- **salario_no_positivo:** 102 rechazos
- **id_duplicado:** 75 rechazos
- **nombre / apellido / cargo nulo:** 0 rechazos
- **id_formato_invalido:** 0 rechazos
- **email_formato_invalido:** 0 rechazos
- **fecha_futura, departamento / modalidad no permitido:** 0 rechazos

**Limpieza aplicada:** trim + capitalizar nombres; fecha DD/MM/YYYY → DATE; salario `abs()`; departamento deducido del cargo (cada cargo pertenece a un único departamento); email reconstruido como `nombre.apellido<N>@tecnosur.com`; duplicados eliminados por `id_empleado`.

## Respuestas a las preguntas de negocio

### 1. Salario promedio por departamento

- **Tecnología:** $ 1.774.298
- **Finanzas:** $ 1.680.993
- **RRHH:** $ 1.466.408
- **Comercial:** $ 1.423.987

### 2. Masa salarial total

- **Masa salarial mensual total:** **$4.015.100.000**

### 3. Empleados por modalidad

- **Remoto:** 891 empleados
- **Presencial:** 832 empleados
- **Híbrido:** 777 empleados

### 4. Ingresos por año

- **2015:** 271 ingresos
- **2016:** 273 ingresos
- **2017:** 239 ingresos
- **2018:** 258 ingresos
- **2019:** 273 ingresos
- **2020:** 279 ingresos
- **2021:** 246 ingresos
- **2022:** 282 ingresos
- **2023:** 244 ingresos
- **2024:** 135 ingresos

### 5. Top 3 cargos por salario promedio

1. **Desarrollador:** $2.037.818
2. **Analista de datos:** $1.943.978
3. **Contador:** $1.738.793
