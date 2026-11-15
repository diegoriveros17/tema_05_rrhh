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


# Punto 1 y 2 
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
    finally:
        con.close()
    print(f"tema_05_rrhh_raw: {filas} filas")
    return filas

    
def main() -> None:
    extraer_y_cargar()

if __name__ == "__main__":
    main()
