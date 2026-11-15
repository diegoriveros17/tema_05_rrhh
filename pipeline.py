import sqlite3
from pathlib import Path

import duckdb
import pandas as pd

BASE = Path(__file__).resolve().parent
ORIGEN = BASE / "datos" / "rrhh.sqlite"      # NUNCA se modifica (se abre solo lectura)
DUCKDB = BASE / "pipeline.duckdb"
SQL_DIR = BASE / "consultas"


def sql(nombre: str) -> str:
    """Lee un archivo .sql de la carpeta consultas/."""
    return (SQL_DIR / nombre).read_text(encoding="utf-8")


def conectar():
    return duckdb.connect(str(DUCKDB))


# Funcion extraer y cargar
def extraer() -> pd.DataFrame:
    """Lee los datos del SQLite original (modo solo lectura)."""
    uri = f"file:{ORIGEN}?mode=ro"
    with sqlite3.connect(uri, uri=True) as origen:
        return pd.read_sql_query(sql("extract.sql"), origen)


def extraer_y_cargar():
    """Extrae y carga tema_05_rrhh_raw"""
    df = extraer()
    con = conectar()
    try:
        con.register("df_origen", df)
        con.execute("CREATE OR REPLACE TABLE tema_05_rrhh_raw AS SELECT * FROM df_origen") # ACA A LA TABLA LA LLAME COMO EL TEMA QUE NOS TOCO, ASI DICE EL DOCX, MIENTRAS QUE EN EL MARKDOWN DEL REPO DICE QUE LE PONGA COMO raw_empleados
        filas = con.execute("SELECT count(*) FROM tema_05_rrhh_raw").fetchone()[0]
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()
        print(f"Etapa de extraer y cargar, cantidad de registros: {filas} filas")
    return filas


# Funcion para validar
def validar() -> tuple[int, int]:
    """Aplica las reglas y separa en validos rechazados."""
    con = conectar()
    try:
        con.execute(sql("validar.sql"))
        v = con.execute("SELECT count(*) FROM validos").fetchone()[0]
        r = con.execute("SELECT count(*) FROM rechazados").fetchone()[0]
        total = con.execute("SELECT count(*) FROM tema_05_rrhh_raw").fetchone()[0]
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()
    assert v + r == total, "validos + rechazados debe ser igual a raw"
    print(f"Etapa de validación: validos={v} rechazados={r}, total = {v + r}")
    return v, r


# Funcion Limpiar
def limpiar() -> int:
    """Corrige lo corregible de los rechazados -> rechazados_limpios."""
    con = conectar()
    try:
        con.execute(sql("limpiar.sql"))
        n = con.execute("SELECT count(*) FROM rechazados_limpios").fetchone()[0]
        pendientes = con.execute("""
            SELECT count(*) FROM rechazados_limpios
            WHERE fecha_ingreso IS NULL OR departamento IS NULL OR email IS NULL OR salario <= 0
        """).fetchone()[0]
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()
    print(f"Etapa de limpieza: rechazados_limpios={n} - sin resolver: {pendientes}")
    return n

# Funcion unir
def unir() -> int:
    """validos + rechazados_limpios -> tabla_final (sin duplicados, tipos correctos)."""
    con = conectar()
    try:
        con.execute(sql("unir.sql"))
        n = con.execute("SELECT count(*) FROM tabla_final").fetchone()[0]
        ids = con.execute("SELECT count(DISTINCT id_empleado) FROM tabla_final").fetchone()[0]
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()
    assert n == ids, "tabla_final tiene ids repetidos"
    print(f"Etapa de unir: tabla_final={n} filas, {ids} ids unicos")
    return n

# Funcion para responder las preguntas de negocio
def preguntas() -> None:
    """Ejecuta las 5 preguntas de negocio e imprime los resultados."""
    con = conectar()
    try:
        con.execute(sql("preguntas.sql"))
        for i in range(1, 6):
            print(f"\n--- Pregunta {i} ---")
            print(con.execute(f"SELECT * FROM respuesta_{i}").df().to_string(index=False))
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()
    
# Funcion resumen de rechazados
def resumen_rechazos() -> None:
    con = conectar()
    try:
        print("\n--- Rechazos por regla ---")
        print(con.execute("SELECT * FROM resumen_rechazos ORDER BY cantidad DESC").df().to_string(index=False))
    except Exception as e:
        print("Error al procesar los datos", e)
    finally:
        con.close()

def main() -> None:
    extraer_y_cargar()
    validar()
    limpiar()
    unir()
    preguntas()
    resumen_rechazos()

if __name__ == "__main__":
    main()
