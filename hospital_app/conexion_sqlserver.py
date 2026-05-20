"""
=============================================================
MÓDULO: CONEXIÓN Y CONSULTAS A POSTGRESQL (SUPABASE)
=============================================================
Este archivo maneja toda la comunicación con la base de datos
PostgreSQL alojada en Supabase.
Incluye:
  - Función de conexión
  - Consulta de vistas
  - Ejecución de procedimiento (función PostgreSQL)
  - Llamada a función escalar
  - Consultas avanzadas (JOIN, GROUP BY)

La base de datos está en Supabase (PostgreSQL en la nube),
por lo que no requiere instalación de drivers adicionales.
=============================================================
"""

import psycopg2
import pandas as pd
import streamlit as st


# ─────────────────────────────────────────
# DATOS DE CONEXIÓN — SUPABASE POSTGRESQL
# ─────────────────────────────────────────
# Credenciales del proyecto hospitalario en Supabase.

POSTGRES_CONFIG = {
    "host":     "aws-1-us-west-2.pooler.supabase.com",
    "port":     5432,
    "database": "postgres",
    "user":     "postgres.hnyirvighntyxijokuvk",
    "password": "cZPoPmROhYNF9KEo",
}


# ─────────────────────────────────────────
# FUNCIÓN: CONECTAR A POSTGRESQL
# ─────────────────────────────────────────
def conectar_sqlserver():
    """
    Crea y devuelve una conexión a PostgreSQL en Supabase.
    Devuelve el objeto de conexión si tiene éxito, o None si falla.
    """
    try:
        conexion = psycopg2.connect(
            host=POSTGRES_CONFIG["host"],
            port=POSTGRES_CONFIG["port"],
            database=POSTGRES_CONFIG["database"],
            user=POSTGRES_CONFIG["user"],
            password=POSTGRES_CONFIG["password"],
            sslmode="require",
            connect_timeout=10,
        )
        return conexion
    except Exception as e:
        st.error(f"Error de conexión a PostgreSQL (Supabase): {e}")
        return None


# ─────────────────────────────────────────
# VISTAS
# ─────────────────────────────────────────

def consultar_vista_citas():
    """
    Consulta la vista vw_citas_detalle.
    Muestra cada cita con el nombre completo del paciente y del médico.
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None
    try:
        query = "SELECT * FROM vw_citas_detalle ORDER BY id_cita"
        df = pd.read_sql(query, conn)
        return df
    except Exception as e:
        st.error(f"Error al consultar la vista de citas: {e}")
        return None
    finally:
        conn.close()


def consultar_vista_medicos():
    """
    Consulta la vista vw_medicos_especialidad_sede.
    Muestra cada médico con su especialidad y la sede donde trabaja.
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None
    try:
        query = "SELECT * FROM vw_medicos_especialidad_sede ORDER BY id_medico"
        df = pd.read_sql(query, conn)
        return df
    except Exception as e:
        st.error(f"Error al consultar la vista de médicos: {e}")
        return None
    finally:
        conn.close()


def consultar_vista_pacientes_habitaciones():
    """
    Consulta la vista vw_pacientes_habitaciones.
    Muestra los pacientes con su habitación asignada y fechas de estancia.
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None
    try:
        query = "SELECT * FROM vw_pacientes_habitaciones ORDER BY paciente"
        df = pd.read_sql(query, conn)
        return df
    except Exception as e:
        st.error(f"Error al consultar la vista de pacientes y habitaciones: {e}")
        return None
    finally:
        conn.close()


# ─────────────────────────────────────────
# PROCEDIMIENTO ALMACENADO
# (en PostgreSQL se implementa como función que retorna tabla)
# ─────────────────────────────────────────

def ejecutar_procedimiento_citas_por_medico(id_medico: int):
    """
    Ejecuta la función sp_citas_por_medico(id_medico).
    En PostgreSQL los procedimientos se llaman con SELECT * FROM función().
    Devuelve las citas del médico indicado con el nombre del paciente.
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        # En PostgreSQL llamamos la función con SELECT * FROM
        cursor.execute("SELECT * FROM sp_citas_por_medico(%s)", (id_medico,))

        columnas = [desc[0] for desc in cursor.description]
        filas = cursor.fetchall()
        df = pd.DataFrame(filas, columns=columnas)
        return df
    except Exception as e:
        st.error(f"Error al ejecutar sp_citas_por_medico: {e}")
        return None
    finally:
        conn.close()


# ─────────────────────────────────────────
# FUNCIÓN ESCALAR
# ─────────────────────────────────────────

def ejecutar_funcion_total_citas_paciente(id_paciente: int):
    """
    Llama a la función escalar fn_total_citas_paciente(id_paciente).
    Devuelve el número total de citas del paciente.
    En PostgreSQL se llama directamente con SELECT función().
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT fn_total_citas_paciente(%s)", (id_paciente,))
        fila = cursor.fetchone()
        if fila:
            return fila[0]
        return 0
    except Exception as e:
        st.error(f"Error al ejecutar fn_total_citas_paciente: {e}")
        return None
    finally:
        conn.close()


# ─────────────────────────────────────────
# CONSULTAS AVANZADAS
# ─────────────────────────────────────────

def consultar_join_avanzado(nombre_consulta: str):
    """
    Ejecuta distintas consultas avanzadas con JOIN y GROUP BY
    según la selección del usuario.
    En PostgreSQL los nombres de tabla son en minúsculas.
    """
    conn = conectar_sqlserver()
    if conn is None:
        return None

    consultas = {

        # GROUP BY: cuántas citas hay de cada estado
        "Citas por estado (GROUP BY)": """
            SELECT
                estado          AS "Estado",
                COUNT(*)        AS "Total Citas"
            FROM cita
            GROUP BY estado
            ORDER BY "Total Citas" DESC
        """,

        # JOIN múltiple: pacientes con su historial y tratamiento
        "Pacientes con su historial y tratamiento (JOIN múltiple)": """
            SELECT
                p.nombre || ' ' || p.apellido  AS "Paciente",
                hm.diagnostico                 AS "Diagnóstico",
                t.nombre                       AS "Tratamiento",
                hm.fecha                       AS "Fecha"
            FROM historial_medico hm
            JOIN paciente    p ON p.id_paciente    = hm.id_paciente
            JOIN tratamiento t ON t.id_tratamiento = hm.id_tratamiento
            ORDER BY hm.fecha
        """,

        # GROUP BY + JOIN: médicos y cuántas citas atendieron
        "Médicos y cantidad de citas atendidas (GROUP BY + JOIN)": """
            SELECT
                m.nombre                  AS "Médico",
                e.nombre                  AS "Especialidad",
                COUNT(c.id_cita)          AS "Citas Atendidas"
            FROM medico m
            JOIN especialidad e ON e.id_especialidad = m.id_especialidad
            LEFT JOIN cita    c ON c.id_medico = m.id_medico
                               AND c.estado = 'Atendida'
            GROUP BY m.nombre, e.nombre
            ORDER BY "Citas Atendidas" DESC
        """,
    }

    try:
        sql = consultas.get(nombre_consulta, "SELECT 1")
        df = pd.read_sql(sql, conn)
        return df
    except Exception as e:
        st.error(f"Error al ejecutar la consulta avanzada: {e}")
        return None
    finally:
        conn.close()
