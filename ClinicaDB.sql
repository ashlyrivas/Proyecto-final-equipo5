-- ==============================================
-- Script seguro T-SQL: borra en orden correcto y crea la BD y tablas
-- ==============================================

-- 1) Crear la base de datos si no existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ClinicaDB')
BEGIN
    CREATE DATABASE ClinicaDB;
END
GO

USE ClinicaDB;
GO

-- 2) BORRAR tablas en ORDEN: tablas que referencian (hijas) primero
-- Orden recomendado: Cita, Usuario, Medico, Paciente, CentroMedico, Especialidad

IF OBJECT_ID('dbo.Cita', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Cita;
END
GO

IF OBJECT_ID('dbo.Usuario', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Usuario;
END
GO

IF OBJECT_ID('dbo.Medico', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Medico;
END
GO

IF OBJECT_ID('dbo.Paciente', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Paciente;
END
GO

IF OBJECT_ID('dbo.CentroMedico', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.CentroMedico;
END
GO

IF OBJECT_ID('dbo.Especialidad', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Especialidad;
END
GO

-- 3) CREAR tablas (padres primero)

-- Especialidad
CREATE TABLE Especialidad (
    id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(MAX) NULL
);
GO

-- CentroMedico
CREATE TABLE CentroMedico (
    id_centro INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL UNIQUE,
    direccion NVARCHAR(255) NULL,
    telefono NVARCHAR(30) NULL
);
GO

-- Paciente
CREATE TABLE Paciente (
    id_paciente INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NULL,
    direccion NVARCHAR(255) NULL,
    telefono NVARCHAR(30) NULL,
    correo NVARCHAR(255) NULL
);
GO

-- Medico  (referencia a Especialidad y CentroMedico)
CREATE TABLE Medico (
    id_medico INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    especialidad_id INT NULL,
    centro_id INT NULL,
    telefono NVARCHAR(30) NULL,
    correo NVARCHAR(255) NULL
);
GO

-- Agregar FKs de Medico después para evitar problemas si tablas no estaban aún listas
ALTER TABLE Medico
    ADD CONSTRAINT FK_Medico_Especialidad FOREIGN KEY (especialidad_id)
        REFERENCES Especialidad(id_especialidad)
        ON DELETE SET NULL;
GO

ALTER TABLE Medico
    ADD CONSTRAINT FK_Medico_Centro FOREIGN KEY (centro_id)
        REFERENCES CentroMedico(id_centro)
        ON DELETE SET NULL;
GO

-- Cita (referencia a Paciente y Medico)
CREATE TABLE Cita (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    motivo NVARCHAR(MAX) NULL,
    paciente_id INT NOT NULL,
    medico_id INT NOT NULL,
    creado_en DATETIME DEFAULT GETDATE()
);
GO

ALTER TABLE Cita
    ADD CONSTRAINT FK_Cita_Paciente FOREIGN KEY (paciente_id)
        REFERENCES Paciente(id_paciente)
        ON DELETE CASCADE;
GO

ALTER TABLE Cita
    ADD CONSTRAINT FK_Cita_Medico FOREIGN KEY (medico_id)
        REFERENCES Medico(id_medico)
        ON DELETE CASCADE;
GO

-- Usuario (opcionalmente enlaza a Paciente o Medico)
CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(150) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    correo NVARCHAR(255) NULL UNIQUE,
    rol NVARCHAR(20) NOT NULL DEFAULT 'paciente',
    paciente_id INT NULL,
    medico_id INT NULL,
    creado_en DATETIME DEFAULT GETDATE()
);
GO

ALTER TABLE Usuario
    ADD CONSTRAINT FK_Usuario_Paciente FOREIGN KEY (paciente_id)
        REFERENCES Paciente(id_paciente)
        ON DELETE SET NULL;
GO

ALTER TABLE Usuario
    ADD CONSTRAINT FK_Usuario_Medico FOREIGN KEY (medico_id)
        REFERENCES Medico(id_medico)
        ON DELETE SET NULL;
GO

-- 4) Índices útiles (opcionales)
CREATE INDEX IDX_Paciente_Nombre ON Paciente(nombre);
CREATE INDEX IDX_Paciente_Apellido ON Paciente(apellido);
CREATE INDEX IDX_Medico_Nombre ON Medico(nombre);
CREATE INDEX IDX_Cita_Fecha ON Cita(fecha);
GO

-- Script finalizado
PRINT 'Tablas creadas correctamente en ClinicaDB';
GO
