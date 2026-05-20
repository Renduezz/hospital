-- =============================================================
-- SCRIPT COMPLETO - SISTEMA HOSPITALARIO
-- Base de datos: PostgreSQL en Supabase
-- =============================================================
-- Este script crea todo lo necesario:
--   1. Tablas con llaves primarias y foráneas
--   2. Datos de prueba (inserts)
--   3. Vistas
--   4. Función escalar
--   5. Función tipo procedimiento (retorna tabla)
-- =============================================================
-- INSTRUCCIONES: Abre el editor SQL de Supabase
-- (https://supabase.com → tu proyecto → SQL Editor)
-- y ejecuta este script completo.
-- NOTA: En PostgreSQL los nombres de tabla van en minúsculas.
-- =============================================================


-- =========================================
-- 1. TABLAS PRINCIPALES (sin dependencias)
-- =========================================

CREATE TABLE IF NOT EXISTS sede (
    id_sede  INT PRIMARY KEY,
    nombre   VARCHAR(100),
    ciudad   VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS especialidad (
    id_especialidad INT PRIMARY KEY,
    nombre          VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS tratamiento (
    id_tratamiento INT PRIMARY KEY,
    nombre         VARCHAR(100),
    descripcion    TEXT
);

CREATE TABLE IF NOT EXISTS paciente (
    id_paciente      INT PRIMARY KEY,
    nombre           VARCHAR(100),
    apellido         VARCHAR(100),
    fecha_nacimiento DATE,
    telefono         VARCHAR(20),
    direccion        TEXT
);

CREATE TABLE IF NOT EXISTS medicamento (
    id_medicamento INT PRIMARY KEY,
    nombre         VARCHAR(100),
    descripcion    TEXT
);


-- =========================================
-- 2. TABLAS DEPENDIENTES (con llaves foráneas)
-- =========================================

CREATE TABLE IF NOT EXISTS medico (
    id_medico       INT PRIMARY KEY,
    nombre          VARCHAR(100),
    telefono        VARCHAR(20),
    id_especialidad INT,
    id_sede         INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad),
    FOREIGN KEY (id_sede)         REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS enfermera (
    id_enfermera INT PRIMARY KEY,
    nombre       VARCHAR(100),
    telefono     VARCHAR(20),
    id_sede      INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS habitacion (
    id_habitacion INT PRIMARY KEY,
    numero        INT,
    estado        VARCHAR(50),
    id_sede       INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS cita (
    id_cita     INT PRIMARY KEY,
    fecha       TIMESTAMP,
    id_paciente INT,
    id_medico   INT,
    estado      VARCHAR(50),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico)   REFERENCES medico(id_medico)
);

CREATE TABLE IF NOT EXISTS historial_medico (
    id_historial   INT PRIMARY KEY,
    id_paciente    INT,
    id_tratamiento INT,
    diagnostico    TEXT,
    fecha          DATE,
    FOREIGN KEY (id_paciente)    REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_tratamiento) REFERENCES tratamiento(id_tratamiento)
);

CREATE TABLE IF NOT EXISTS receta (
    id_receta   INT PRIMARY KEY,
    id_cita     INT,
    descripcion TEXT,
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
);

CREATE TABLE IF NOT EXISTS receta_medicamento (
    id_receta      INT,
    id_medicamento INT,
    dosis          VARCHAR(50),
    PRIMARY KEY (id_receta, id_medicamento),
    FOREIGN KEY (id_receta)      REFERENCES receta(id_receta),
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

CREATE TABLE IF NOT EXISTS asignacion_habitacion (
    id_asignacion INT PRIMARY KEY,
    id_paciente   INT,
    id_habitacion INT,
    fecha_ingreso DATE,
    fecha_salida  DATE,
    FOREIGN KEY (id_paciente)   REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_habitacion) REFERENCES habitacion(id_habitacion)
);


-- =========================================
-- 3. DATOS DE PRUEBA
-- =========================================

INSERT INTO sede VALUES
(1, 'Hospital Central', 'Medellín'),
(2, 'Hospital Norte',   'Bogotá'),
(3, 'Hospital Sur',     'Cali')
ON CONFLICT (id_sede) DO NOTHING;

INSERT INTO especialidad VALUES
(1, 'Cardiología'),
(2, 'Pediatría'),
(3, 'Neurología'),
(4, 'Ortopedia')
ON CONFLICT (id_especialidad) DO NOTHING;

INSERT INTO tratamiento VALUES
(1, 'Fisioterapia',   'Recuperación física'),
(2, 'Quimioterapia',  'Tratamiento contra el cáncer'),
(3, 'Rehabilitación', 'Recuperación funcional')
ON CONFLICT (id_tratamiento) DO NOTHING;

INSERT INTO medicamento VALUES
(1, 'Paracetamol', 'Analgésico'),
(2, 'Ibuprofeno',  'Antiinflamatorio'),
(3, 'Amoxicilina', 'Antibiótico')
ON CONFLICT (id_medicamento) DO NOTHING;

INSERT INTO habitacion VALUES
(1,  101, 'Disponible', 1),
(2,  102, 'Disponible', 1),
(3,  103, 'Disponible', 1),
(4,  101, 'Disponible', 2),
(5,  102, 'Disponible', 2),
(6,  103, 'Disponible', 2),
(7,  101, 'Disponible', 3),
(8,  102, 'Disponible', 3),
(9,  103, 'Disponible', 3),
(10, 104, 'Disponible', 3)
ON CONFLICT (id_habitacion) DO NOTHING;

INSERT INTO paciente VALUES
(1,  'Juan',    'Perez',    '1990-05-10', '3001111111', 'Medellín'),
(2,  'Ana',     'Gomez',    '1985-03-22', '3002222222', 'Bogotá'),
(3,  'Luis',    'Martinez', '2000-07-15', '3003333333', 'Cali'),
(4,  'Sofia',   'Lopez',    '1998-01-30', '3004444444', 'Medellín'),
(5,  'Carlos',  'Ramirez',  '1975-11-12', '3005555555', 'Bogotá'),
(6,  'Laura',   'Torres',   '1992-06-18', '3006666666', 'Cali'),
(7,  'Pedro',   'Castro',   '1988-09-09', '3007777777', 'Medellín'),
(8,  'Maria',   'Diaz',     '1995-12-25', '3008888888', 'Bogotá'),
(9,  'Jorge',   'Vargas',   '1982-04-14', '3009999999', 'Cali'),
(10, 'Elena',   'Rojas',    '1999-02-02', '3010000000', 'Medellín'),
(11, 'Andres',  'Mora',     '1991-08-20', '3011111111', 'Bogotá'),
(12, 'Diana',   'Cruz',     '1987-10-05', '3012222222', 'Cali'),
(13, 'Miguel',  'Ortiz',    '1979-03-11', '3013333333', 'Medellín'),
(14, 'Paula',   'Herrera',  '2001-07-07', '3014444444', 'Bogotá'),
(15, 'Ricardo', 'Suarez',   '1993-09-19', '3015555555', 'Cali')
ON CONFLICT (id_paciente) DO NOTHING;

INSERT INTO medico VALUES
(1,  'Dr. Alvarez', '3101111111', 1, 1),
(2,  'Dr. Castro',  '3102222222', 2, 2),
(3,  'Dr. Ruiz',    '3103333333', 3, 3),
(4,  'Dr. Peña',    '3104444444', 4, 1),
(5,  'Dr. Gil',     '3105555555', 1, 2),
(6,  'Dr. Vega',    '3106666666', 2, 3),
(7,  'Dr. Rios',    '3107777777', 3, 1),
(8,  'Dr. Leon',    '3108888888', 4, 2),
(9,  'Dr. Pardo',   '3109999999', 1, 3),
(10, 'Dr. Silva',   '3110000000', 2, 1),
(11, 'Dr. Diaz',    '3111111111', 3, 2),
(12, 'Dr. Lara',    '3112222222', 4, 3),
(13, 'Dr. Torres',  '3113333333', 1, 1),
(14, 'Dr. Mejia',   '3114444444', 2, 2),
(15, 'Dr. Rangel',  '3115555555', 3, 3)
ON CONFLICT (id_medico) DO NOTHING;

INSERT INTO enfermera VALUES
(1,  'Enf. Lopez',   '3201111111', 1),
(2,  'Enf. Diaz',    '3202222222', 2),
(3,  'Enf. Ruiz',    '3203333333', 3),
(4,  'Enf. Mora',    '3204444444', 1),
(5,  'Enf. Gil',     '3205555555', 2),
(6,  'Enf. Rios',    '3206666666', 3),
(7,  'Enf. Leon',    '3207777777', 1),
(8,  'Enf. Cruz',    '3208888888', 2),
(9,  'Enf. Vega',    '3209999999', 3),
(10, 'Enf. Lara',    '3210000000', 1),
(11, 'Enf. Ortiz',   '3211111111', 2),
(12, 'Enf. Castro',  '3212222222', 3),
(13, 'Enf. Peña',    '3213333333', 1),
(14, 'Enf. Herrera', '3214444444', 2),
(15, 'Enf. Suarez',  '3215555555', 3)
ON CONFLICT (id_enfermera) DO NOTHING;

INSERT INTO cita VALUES
(1,  '2025-06-01 08:00', 1,  1,  'Programada'),
(2,  '2025-06-01 09:00', 2,  2,  'Atendida'),
(3,  '2025-06-01 10:00', 3,  3,  'Cancelada'),
(4,  '2025-06-02 08:00', 4,  4,  'Programada'),
(5,  '2025-06-02 09:00', 5,  5,  'Atendida'),
(6,  '2025-06-02 10:00', 6,  6,  'Programada'),
(7,  '2025-06-03 08:00', 7,  7,  'Atendida'),
(8,  '2025-06-03 09:00', 8,  8,  'Programada'),
(9,  '2025-06-03 10:00', 9,  9,  'Cancelada'),
(10, '2025-06-04 08:00', 10, 10, 'Programada'),
(11, '2025-06-04 09:00', 11, 11, 'Atendida'),
(12, '2025-06-04 10:00', 12, 12, 'Programada'),
(13, '2025-06-05 08:00', 13, 13, 'Programada'),
(14, '2025-06-05 09:00', 14, 14, 'Cancelada'),
(15, '2025-06-05 10:00', 15, 15, 'Atendida')
ON CONFLICT (id_cita) DO NOTHING;

INSERT INTO historial_medico VALUES
(1,  1,  1, 'Dolor muscular',         '2025-06-01'),
(2,  2,  2, 'Cáncer en tratamiento',  '2025-06-01'),
(3,  3,  3, 'Lesión física',          '2025-06-01'),
(4,  4,  1, 'Rehabilitación rodilla', '2025-06-02'),
(5,  5,  2, 'Tratamiento oncológico', '2025-06-02'),
(6,  6,  3, 'Recuperación',           '2025-06-02'),
(7,  7,  1, 'Dolor lumbar',           '2025-06-03'),
(8,  8,  2, 'Quimioterapia',          '2025-06-03'),
(9,  9,  3, 'Rehabilitación',         '2025-06-03'),
(10, 10, 1, 'Terapia física',         '2025-06-04'),
(11, 11, 2, 'Cáncer leve',            '2025-06-04'),
(12, 12, 3, 'Fractura',               '2025-06-04'),
(13, 13, 1, 'Dolor cervical',         '2025-06-05'),
(14, 14, 2, 'Quimioterapia',          '2025-06-05'),
(15, 15, 3, 'Rehabilitación',         '2025-06-05')
ON CONFLICT (id_historial) DO NOTHING;

INSERT INTO receta VALUES
(1,  1,  'Tomar medicamento A'),
(2,  2,  'Tomar medicamento B'),
(3,  3,  'Tomar medicamento C'),
(4,  4,  'Tratamiento leve'),
(5,  5,  'Reposo'),
(6,  6,  'Control'),
(7,  7,  'Medicamento diario'),
(8,  8,  'Antibiótico'),
(9,  9,  'Analgésico'),
(10, 10, 'Seguimiento'),
(11, 11, 'Tratamiento continuo'),
(12, 12, 'Reposo'),
(13, 13, 'Medicamento'),
(14, 14, 'Control médico'),
(15, 15, 'Alta médica')
ON CONFLICT (id_receta) DO NOTHING;

INSERT INTO receta_medicamento VALUES
(1,1,'500mg'),(2,2,'400mg'),(3,3,'250mg'),
(4,1,'500mg'),(5,2,'400mg'),(6,3,'250mg'),
(7,1,'500mg'),(8,2,'400mg'),(9,3,'250mg'),
(10,1,'500mg'),(11,2,'400mg'),(12,3,'250mg'),
(13,1,'500mg'),(14,2,'400mg'),(15,3,'250mg')
ON CONFLICT (id_receta, id_medicamento) DO NOTHING;

INSERT INTO asignacion_habitacion VALUES
(1,1,1,'2025-06-01','2025-06-03'),
(2,2,2,'2025-06-01','2025-06-04'),
(3,3,3,'2025-06-01','2025-06-02'),
(4,4,4,'2025-06-02','2025-06-05'),
(5,5,5,'2025-06-02','2025-06-06'),
(6,6,6,'2025-06-02','2025-06-03'),
(7,7,7,'2025-06-03','2025-06-04'),
(8,8,8,'2025-06-03','2025-06-05'),
(9,9,9,'2025-06-03','2025-06-04'),
(10,10,10,'2025-06-04','2025-06-06'),
(11,11,1,'2025-06-04','2025-06-05'),
(12,12,2,'2025-06-04','2025-06-06'),
(13,13,3,'2025-06-05','2025-06-07'),
(14,14,4,'2025-06-05','2025-06-06'),
(15,15,5,'2025-06-05','2025-06-07')
ON CONFLICT (id_asignacion) DO NOTHING;


-- =========================================
-- 4. VISTAS
-- =========================================

-- VISTA 1: Detalle de cada cita (paciente + médico)
CREATE OR REPLACE VIEW vw_citas_detalle AS
    SELECT
        c.id_cita                           AS id_cita,
        c.fecha::TEXT                       AS fecha_hora,
        p.nombre || ' ' || p.apellido       AS paciente,
        m.nombre                            AS medico,
        c.estado                            AS estado
    FROM cita c
    JOIN paciente p ON p.id_paciente = c.id_paciente
    JOIN medico   m ON m.id_medico   = c.id_medico;

-- VISTA 2: Médicos con especialidad y sede
CREATE OR REPLACE VIEW vw_medicos_especialidad_sede AS
    SELECT
        m.id_medico     AS id_medico,
        m.nombre        AS medico,
        e.nombre        AS especialidad,
        s.nombre        AS sede,
        s.ciudad        AS ciudad,
        m.telefono      AS telefono
    FROM medico       m
    JOIN especialidad e ON e.id_especialidad = m.id_especialidad
    JOIN sede         s ON s.id_sede         = m.id_sede;

-- VISTA 3: Pacientes con habitación asignada
CREATE OR REPLACE VIEW vw_pacientes_habitaciones AS
    SELECT
        p.nombre || ' ' || p.apellido  AS paciente,
        h.numero                       AS numero_habitacion,
        s.nombre                       AS sede,
        ah.fecha_ingreso               AS fecha_ingreso,
        ah.fecha_salida                AS fecha_salida
    FROM asignacion_habitacion ah
    JOIN paciente   p ON p.id_paciente   = ah.id_paciente
    JOIN habitacion h ON h.id_habitacion = ah.id_habitacion
    JOIN sede       s ON s.id_sede       = h.id_sede;


-- =========================================
-- 5. FUNCIÓN ESCALAR
-- =========================================
-- Cuenta el total de citas de un paciente.
-- Uso: SELECT fn_total_citas_paciente(1);

CREATE OR REPLACE FUNCTION fn_total_citas_paciente(p_id_paciente INT)
RETURNS INT AS $$
    SELECT COUNT(*)::INT
    FROM cita
    WHERE id_paciente = p_id_paciente;
$$ LANGUAGE sql;


-- =========================================
-- 6. PROCEDIMIENTO ALMACENADO
-- (en PostgreSQL se implementa como función que retorna tabla)
-- =========================================
-- Devuelve todas las citas de un médico con el nombre del paciente.
-- Uso: SELECT * FROM sp_citas_por_medico(1);

CREATE OR REPLACE FUNCTION sp_citas_por_medico(p_id_medico INT)
RETURNS TABLE(
    id_cita   INT,
    fecha_hora TEXT,
    paciente  TEXT,
    estado    VARCHAR
) AS $$
    SELECT
        c.id_cita,
        c.fecha::TEXT,
        p.nombre || ' ' || p.apellido,
        c.estado
    FROM cita     c
    JOIN paciente p ON p.id_paciente = c.id_paciente
    WHERE c.id_medico = p_id_medico
    ORDER BY c.fecha;
$$ LANGUAGE sql;

-- Prueba rápida (puedes ejecutar para verificar):
-- SELECT fn_total_citas_paciente(1);
-- SELECT * FROM sp_citas_por_medico(1);
