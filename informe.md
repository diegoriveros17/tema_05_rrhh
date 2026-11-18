# Informe: Pipeline ETL de Recursos Humanos – TecnoSur S.A.

Este informe detalla la ejecución y los resultados del flujo automatizado de datos de empleados de TecnoSur S.A., orquestado mediante Apache Airflow que se ejecuta con frecuencia diaria de 24hs a las 02:00 A.M. El proceso extrae los registros desde una base de datos SQLite, aplica reglas de validación a los datos y los divide entre registros válidos y rechazados, ejecuta rutinas de limpieza sobre los errores que se pueden resolver para recuperarlos (`rechazados_limpios`) y consolida la información depurada en una `tabla_final` para el análisis de negocio.

## Calidad de Datos y Proceso de Limpieza

Durante la ingesta inicial se procesaron 2575 registros, de los cuales 2500 eran id únicos (`id_empleado`). Del total, 1500 filas superaron las validaciones iniciales, mientras que 1075 fueron pasaron a la instancia de rechazo por incumplir una o más reglas de integridad.

El diagnóstico de calidad: las principales inconsistencias se presentaban en el formato y completitud: se detectaron 360 registros con nombres o apellidos en mayúsculas o con espacios sobrantes, 256 fechas cargadas en el formato `DD/MM/YYYY` en lugar del estándar `YYYY/MM/DD`, 160 casos con el departamento nulo, 153 registros sin correo electrónico y 102 salarios expresados en valores negativos. También, se identificaron 75 filas duplicadas, mientras que las reglas referidas a campos nulos, formatos de identificador o fechas futuras no registraron problemas.

Para recuperar la información sin perder integridad, se aplicó una limpieza automatizada: se estandarizaron los nombres mediante recorte de espacios y capitalización, se convirtieron las fechas al tipo `DATE` y se aplicó valor absoluto a los salarios negativos bajo el supuesto de error de tipeo. Los departamentos faltantes se dedujeron a partir del cargo, aprovechando su relación unica, y los correos se construyeron siguiendo el patrón de los demas `nombre.apellido<N>@tecnosur.com` correo corporativo. Del proceso se descartaron 44 copias duplicadas, se recuperaron 1031 registros que, sumados a los válidos iniciales, conformaron una tabla final de 2500 empleados únicos sin valores nulos.

## Resultados de Negocio

El análisis sobre la base saneada arrojo los siguientes resultados

1. La consulta de remuneraciones por área, **Tecnología** lidera el salario promedio con **$ 1.774.298**, le sigue **Finanzas** con **$1.680.993**, luego **Recursos Humanos** con **$ 1.466.408** y por ultimo **Comercial** con **$ 1.423.987**.
2. La **masa salarial mensual total** de la compañía asciende a **$ 4.015.100.000**.
3. Respecto a la distribución operativa de la compañia, predomina el trabajo **remoto** con **891 empleados**, le sigue la modalidad **presencial** **832** y el **híbrido** con **777**.
4. En cuanto a la cantidad de empleados que ingresaron la consulta arrojo:

- 2015: 271 ingresos
- 2016: 273 ingresos
- 2017: 239 ingresos
- 2018: 258 ingresos
- 2019: 273 ingresos
- 2020: 279 ingresos
- 2021: 246 ingresos
- 2022: 282 ingresos
- 2023: 244 ingresos
- 2024: 135 ingresos

5. . En cuanto a los roles mejor remunerados, el puesto de **Desarrollador** con **$ 2.037.818**, seguido por **Analista de datos** con **$ 1.943.978** y finalmente **Contador** con **$ 1.738.793**.
