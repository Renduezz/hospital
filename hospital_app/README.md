# Sistema Hospitalario — Proyecto Final Bases de Datos II

## ¿Qué es esto?
Aplicación en Python/Streamlit que conecta con **SQL Server** y **MongoDB** para
mostrar información del sistema hospitalario.

---

## Archivos del proyecto

| Archivo | Descripción |
|---|---|
| `app.py` | Aplicación principal de Streamlit |
| `conexion_sqlserver.py` | Módulo de conexión y consultas a SQL Server |
| `conexion_mongodb.py` | Módulo de conexión y consultas a MongoDB |
| `script_sqlserver.sql` | Script completo para crear la BD en SQL Server |
| `pacientes_mongodb.json` | Datos de pacientes para importar a MongoDB |
| `requirements.txt` | Librerías Python necesarias |

---

## Pasos para ejecutar

### 1. Instalar librerías
```
pip install -r requirements.txt
```

### 2. Completar credenciales

**SQL Server** → abre `conexion_sqlserver.py` y rellena:
- `"servidor"` → IP o nombre del servidor SQL Server
- `"usuario"` → usuario de SQL Server
- `"contrasena"` → contraseña

**MongoDB** → abre `conexion_mongodb.py` y rellena:
- `MONGO_USUARIO` → usuario de MongoDB Atlas
- `MONGO_CONTRASENA` → contraseña de MongoDB Atlas
- `MONGO_BASE_DATOS` → nombre de la base de datos en MongoDB

### 3. Preparar SQL Server
Ejecuta `script_sqlserver.sql` completo en SQL Server Management Studio (SSMS).

### 4. Importar datos a MongoDB
En MongoDB Compass o Mongo Atlas, importa el archivo `pacientes_mongodb.json`
a la colección `pacientes` de tu base de datos.

### 5. Ejecutar la aplicación
```
streamlit run app.py
```

---

## Qué cubre el proyecto

### SQL Server
- ✅ 10 tablas relacionadas con llaves primarias y foráneas
- ✅ 3 Vistas (`vw_Citas_Detalle`, `vw_Medicos_Especialidad_Sede`, `vw_Pacientes_Habitaciones`)
- ✅ 1 Función escalar (`fn_TotalCitasPaciente`)
- ✅ 2 Procedimientos almacenados (`sp_CitasPorMedico`, `sp_HistorialPaciente`)
- ✅ Consultas avanzadas con JOIN, GROUP BY

### MongoDB
- ✅ Colección `pacientes` con documentos embebidos (historial médico anidado)
- ✅ 15 documentos con historial médico
- ✅ Búsqueda por nombre, rango de IDs y lista de nombres

### Aplicación
- ✅ Conexión a SQL Server y MongoDB
- ✅ Consulta de vistas
- ✅ Ejecución de procedimiento almacenado con parámetro
- ✅ Uso de función escalar
- ✅ Consultas avanzadas (JOIN, GROUP BY)
- ✅ Consultas a MongoDB con filtros
- ✅ Muestra información de ambas bases de datos
