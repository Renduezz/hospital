"""
=============================================================
MÓDULO: CONEXIÓN Y CONSULTAS A MONGODB ATLAS
=============================================================
Este archivo maneja toda la comunicación con MongoDB Atlas.
La base de datos guarda pacientes como documentos con el
historial médico embebido (anidado dentro del mismo documento).

Base de datos: hospitalDB
Colección: pacientes

Cada documento tiene:
  - _id: número del paciente
  - nombre: nombre del paciente
  - apellido: apellido del paciente
  - historial_medico: lista de diagnósticos y tratamientos
=============================================================
"""

from pymongo import MongoClient
import streamlit as st


# ─────────────────────────────────────────
# DATOS DE CONEXIÓN — MONGODB ATLAS
# ─────────────────────────────────────────
# URI completa de conexión al cluster del proyecto.

MONGO_URL = (
    "mongodb+srv://nesp:nesp1234"
    "@clusterdbhospitalario.nifcbm9.mongodb.net/"
    "?appName=ClusterDBhospitalario"
)

# Nombre de la base de datos en MongoDB Atlas
MONGO_BASE_DATOS = "hospitalDB"

# Nombre de la colección donde están los pacientes
MONGO_COLECCION_PACIENTES = "pacientes"


# ─────────────────────────────────────────
# FUNCIÓN: CONECTAR A MONGODB
# ─────────────────────────────────────────
def conectar_mongodb():
    """
    Crea y devuelve una conexión al cliente de MongoDB Atlas.
    Devuelve el cliente si tiene éxito, o None si falla.
    Recuerda llamar a client.close() cuando termines de usarlo.
    """
    try:
        client = MongoClient(MONGO_URL, serverSelectionTimeoutMS=5000)
        # Forzamos un ping para verificar que realmente conectó
        client.admin.command("ping")
        return client
    except Exception as e:
        st.error(f"Error de conexión a MongoDB Atlas: {e}")
        return None


def _obtener_coleccion():
    """
    Función interna que devuelve la colección de pacientes.
    Retorna (cliente, colección) o (None, None) si falla.
    """
    client = conectar_mongodb()
    if client is None:
        return None, None
    db = client[MONGO_BASE_DATOS]
    coleccion = db[MONGO_COLECCION_PACIENTES]
    return client, coleccion


# ─────────────────────────────────────────
# CONSULTAS MONGODB
# ─────────────────────────────────────────

def obtener_todos_los_pacientes():
    """
    Devuelve todos los documentos de la colección pacientes.
    Equivale a: db.pacientes.find({})
    """
    client, coleccion = _obtener_coleccion()
    if coleccion is None:
        return None
    try:
        resultados = list(coleccion.find({}))
        return resultados
    except Exception as e:
        st.error(f"Error al obtener pacientes de MongoDB: {e}")
        return None
    finally:
        client.close()


def buscar_paciente_por_nombre(nombre: str):
    """
    Busca pacientes por nombre exacto.
    Equivale a: db.pacientes.find({ "nombre": nombre })
    """
    client, coleccion = _obtener_coleccion()
    if coleccion is None:
        return None
    try:
        resultados = list(coleccion.find({"nombre": nombre}))
        return resultados
    except Exception as e:
        st.error(f"Error al buscar paciente por nombre: {e}")
        return None
    finally:
        client.close()


def buscar_pacientes_por_rango_id(id_min: int, id_max: int):
    """
    Busca pacientes cuyo _id esté entre id_min e id_max (inclusive).
    Equivale a: db.pacientes.find({ "_id": { "$gte": id_min, "$lte": id_max } })
    """
    client, coleccion = _obtener_coleccion()
    if coleccion is None:
        return None
    try:
        filtro = {"_id": {"$gte": id_min, "$lte": id_max}}
        resultados = list(coleccion.find(filtro))
        return resultados
    except Exception as e:
        st.error(f"Error al buscar pacientes por rango de ID: {e}")
        return None
    finally:
        client.close()


def buscar_pacientes_por_nombres(nombres: list):
    """
    Busca varios pacientes a la vez usando una lista de nombres.
    Equivale a: db.pacientes.find({ "nombre": { "$in": nombres } })
    """
    client, coleccion = _obtener_coleccion()
    if coleccion is None:
        return None
    try:
        filtro = {"nombre": {"$in": nombres}}
        resultados = list(coleccion.find(filtro))
        return resultados
    except Exception as e:
        st.error(f"Error al buscar pacientes por lista de nombres: {e}")
        return None
    finally:
        client.close()
