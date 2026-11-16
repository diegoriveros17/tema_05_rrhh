import sys
from pathlib import Path

import pendulum
from airflow.sdk import dag, task

# permite hacer "import pipeline" desde la carpeta padre de dags/
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import pipeline


@task
def extraer_y_cargar():
    print("######### Extracción y carga #############")
    print("Filas en la tabla raw:", pipeline.extraer_y_cargar())


@task
def validar():
    print("######### Validación #############")
    v, r = pipeline.validar()
    print("Válidos:", v, "| Rechazados:", r)


@task
def limpiar():
    print("######### Limpieza #############")
    print("Rechazados limpios:", pipeline.limpiar())


@task
def unir():
    print("######### Unión #############")
    print("Filas en tabla_final:", pipeline.unir())


@task
def preguntas():
    print("######### Preguntas de negocio #############")
    pipeline.preguntas()


@dag(
    dag_id="pipeline_rrhh_tecnosur",
    start_date=pendulum.datetime(2026, 11, 1, tz="America/Argentina/Buenos_Aires"),
    schedule="0 2 * * *",   # minuto 0, hora 2, todos los días
    catchup=False,
)
def main():
    extraer_y_cargar() >> validar() >> limpiar() >> unir() >> preguntas()

main()