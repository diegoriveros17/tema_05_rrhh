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

| Regla                    | Rechazos | Regla                                               | Rechazos |
| ------------------------ | -------- | --------------------------------------------------- | -------- |
| nombre_apellido_formato  | 360      | id_duplicado                                        | 75       |
| fecha_invalida_o_formato | 256      | nombre / apellido / cargo nulo                      | 0        |
| departamento_nulo        | 160      | id_formato_invalido                                 | 0        |
| email_nulo               | 153      | email_formato_invalido                              | 0        |
| salario_no_positivo      | 102      | fecha_futura, departamento / modalidad no permitido | 0        |

**Limpieza aplicada:** trim + capitalizar nombres; fecha DD/MM/YYYY → DATE; salario `abs()`; departamento deducido del cargo (cada cargo pertenece a un único departamento); email reconstruido como `nombre.apellido<N>@tecnosur.com`; duplicados eliminados por `id_empleado`.

## Respuestas a las preguntas de negocio

### 1. Salario promedio por departamento

| Departamento | Salario Promedio (ARS) |
| ------------ | ---------------------- |
| Tecnología   | 1.774.298              |
| Finanzas     | 1.680.993              |
| RRHH         | 1.466.408              |
| Comercial    | 1.423.987              |

### 2. Masa salarial total

| Métrica                     | Valor (ARS)       |
| --------------------------- | ----------------- |
| Masa salarial mensual total | **4.015.100.000** |

### 3. Empleados por modalidad

| Modalidad  | Cantidad de Empleados |
| ---------- | --------------------- |
| Remoto     | 891                   |
| Presencial | 832                   |
| Híbrido    | 777                   |

### 4. Ingresos por año

| Año  | Ingresos |
| ---- | -------- |
| 2015 | 271      |
| 2016 | 273      |
| 2017 | 239      |
| 2018 | 258      |
| 2019 | 273      |
| 2020 | 279      |
| 2021 | 246      |
| 2022 | 282      |
| 2023 | 244      |
| 2024 | 135      |

### 5. Top 3 cargos por salario promedio

| Puesto | Cargo             | Salario Promedio (ARS) |
| ------ | ----------------- | ---------------------- |
| 1      | Desarrollador     | 2.037.818              |
| 2      | Analista de datos | 1.943.978              |
| 3      | Contador          | 1.738.793              |
