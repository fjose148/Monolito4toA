-- ============================================================
-- Script para eliminar y recrear la base de datos Monolillo4to
-- Servidor: KYOMU\SQLEXPRESS  |  Autenticación: Windows
-- ============================================================

USE master;
GO

-- 1) Cerrar conexiones activas y eliminar la DB si existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Monolillo4to')
BEGIN
    ALTER DATABASE [Monolillo4to] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Monolillo4to];
END
GO

-- 2) Crear la base de datos
CREATE DATABASE [Monolillo4to];
GO

USE [Monolillo4to];
GO

-- ============================================================
-- TABLA: tbl_tipo_usuario
-- ============================================================
CREATE TABLE [dbo].[tbl_tipo_usuario] (
    [tusu_id]     INT          NOT NULL IDENTITY(1,1),
    [tusu_nombre] VARCHAR(50)  NULL,
    [tusu_estado] CHAR(1)      NULL,
    CONSTRAINT [PK_tbl_tipo_usuario] PRIMARY KEY CLUSTERED ([tusu_id])
);
GO

-- ============================================================
-- TABLA: tbl_usuario
-- ============================================================
CREATE TABLE [dbo].[tbl_usuario] (
    [usu_id]                 INT           NOT NULL IDENTITY(1,1),
    [usu_cedula]             VARCHAR(10)   NULL,
    [usu_nombres]            VARCHAR(50)   NULL,
    [usu_apellidos]          VARCHAR(50)   NULL,
    [usu_direcciones]        VARCHAR(50)   NULL,
    [usu_celular]            VARCHAR(10)   NULL,
    [usu_correo]             VARCHAR(150)  NULL,
    [usu_fecha_creacion]     DATETIME      NULL,
    [usu_fecha_cumple]       DATE          NULL,
    [usu_nick]               VARCHAR(50)   NULL,
    [usu_contraseña]         VARBINARY(MAX) NULL,
    [usu_intentos]           INT           NULL,
    [usu_codigo_OTP]         VARCHAR(10)   NULL,
    [usu_estado]             CHAR(1)       NULL,
    [tusu_id]                INT           NULL,
    [usu_fecha_ultimo_intento] DATETIME    NULL,
    [usu_imagen]             VARCHAR(250)  NULL,
    CONSTRAINT [PK_tbl_usuario] PRIMARY KEY CLUSTERED ([usu_id]),
    CONSTRAINT [FK_usuario_tipo_usuario] FOREIGN KEY ([tusu_id])
        REFERENCES [dbo].[tbl_tipo_usuario] ([tusu_id])
);
GO

-- ============================================================
-- DATOS INICIALES: Tipos de usuario
-- ============================================================
INSERT INTO [dbo].[tbl_tipo_usuario] ([tusu_nombre], [tusu_estado]) VALUES ('Administrador', 'A');
INSERT INTO [dbo].[tbl_tipo_usuario] ([tusu_nombre], [tusu_estado]) VALUES ('Usuario Estándar', 'A');
GO

-- ============================================================
-- Verificación
-- ============================================================
SELECT 'tbl_tipo_usuario' AS Tabla, COUNT(*) AS Filas FROM [dbo].[tbl_tipo_usuario]
UNION ALL
SELECT 'tbl_usuario', COUNT(*) FROM [dbo].[tbl_usuario];
GO

PRINT '✔ Base de datos Monolillo4to creada correctamente.';
GO
