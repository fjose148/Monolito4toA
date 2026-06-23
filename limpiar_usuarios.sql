-- ============================================================
-- Script: Limpiar usuarios + actualizar estructura BD
-- Servidor: KYOMU\SQLEXPRESS | BD: Monolillo4to | Windows Auth
-- ============================================================
USE [Monolillo4to];
GO

-- 1) Agregar usu_qr_key si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbl_usuario') AND name = 'usu_qr_key')
BEGIN
    ALTER TABLE [dbo].[tbl_usuario] ADD [usu_qr_key] VARCHAR(100) NULL;
    PRINT 'Columna usu_qr_key agregada.';
END
GO

-- 2) Crear tabla de imagenes si no existe
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_usuario_imagenes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[tbl_usuario_imagenes] (
        [img_id]        INT            NOT NULL IDENTITY(1,1),
        [usu_id]        INT            NOT NULL,
        [img_binario]   VARBINARY(MAX) NULL,
        [img_tipo]      VARCHAR(50)    NULL,
        [img_es_perfil] BIT            NOT NULL DEFAULT(0),
        [img_fecha]     DATETIME       NOT NULL DEFAULT(GETDATE()),
        CONSTRAINT [PK_tbl_usuario_imagenes] PRIMARY KEY CLUSTERED ([img_id]),
        CONSTRAINT [FK_imagenes_usuario] FOREIGN KEY ([usu_id])
            REFERENCES [dbo].[tbl_usuario] ([usu_id]) ON DELETE CASCADE
    );
    PRINT 'Tabla tbl_usuario_imagenes creada.';
END
ELSE
BEGIN
    -- Agregar columna img_es_perfil si no existe
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbl_usuario_imagenes') AND name = 'img_es_perfil')
    BEGIN
        ALTER TABLE [dbo].[tbl_usuario_imagenes] ADD [img_es_perfil] BIT NOT NULL DEFAULT(0);
        PRINT 'Columna img_es_perfil agregada.';
    END
END
GO

-- 3) Crear tabla de puntajes del juego si no existe
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_puntajes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[tbl_puntajes] (
        [pts_id]       INT      NOT NULL IDENTITY(1,1),
        [usu_id]       INT      NOT NULL,
        [pts_puntaje]  INT      NOT NULL DEFAULT(0),
        [pts_fecha]    DATETIME NOT NULL DEFAULT(GETDATE()),
        CONSTRAINT [PK_tbl_puntajes] PRIMARY KEY CLUSTERED ([pts_id]),
        CONSTRAINT [FK_puntajes_usuario] FOREIGN KEY ([usu_id])
            REFERENCES [dbo].[tbl_usuario] ([usu_id]) ON DELETE CASCADE
    );
    PRINT 'Tabla tbl_puntajes creada.';
END
GO

-- 4) Crear funciones de encriptacion si no existen
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'encriptacon' AND type = 'FN')
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[encriptacon](@texto VARCHAR(MAX))
    RETURNS VARBINARY(MAX)
    AS
    BEGIN
        RETURN CONVERT(VARBINARY(MAX), @texto)
    END
    ');
    PRINT 'Funcion encriptacon creada.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'desencriptacon' AND type = 'FN')
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[desencriptacon](@binario VARBINARY(MAX))
    RETURNS VARCHAR(MAX)
    AS
    BEGIN
        RETURN CONVERT(VARCHAR(MAX), @binario)
    END
    ');
    PRINT 'Funcion desencriptacon creada.';
END
GO

-- 5) ELIMINAR TODOS LOS USUARIOS (y sus imagenes por CASCADE)
DELETE FROM [dbo].[tbl_usuario_imagenes];
DELETE FROM [dbo].[tbl_puntajes];
DELETE FROM [dbo].[tbl_usuario];
DBCC CHECKIDENT ('[dbo].[tbl_usuario]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[tbl_usuario_imagenes]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[tbl_puntajes]', RESEED, 0);
GO

-- 6) Asegurar tipos de usuario existen
IF NOT EXISTS (SELECT * FROM [dbo].[tbl_tipo_usuario] WHERE tusu_nombre = 'Administrador')
    INSERT INTO [dbo].[tbl_tipo_usuario] ([tusu_nombre], [tusu_estado]) VALUES ('Administrador', 'A');

IF NOT EXISTS (SELECT * FROM [dbo].[tbl_tipo_usuario] WHERE tusu_nombre LIKE 'Usuario%')
    INSERT INTO [dbo].[tbl_tipo_usuario] ([tusu_nombre], [tusu_estado]) VALUES ('Usuario Estándar', 'A');
GO

-- Verificacion final
SELECT 'tbl_tipo_usuario' AS Tabla, COUNT(*) AS Filas FROM [dbo].[tbl_tipo_usuario]
UNION ALL SELECT 'tbl_usuario', COUNT(*) FROM [dbo].[tbl_usuario]
UNION ALL SELECT 'tbl_usuario_imagenes', COUNT(*) FROM [dbo].[tbl_usuario_imagenes]
UNION ALL SELECT 'tbl_puntajes', COUNT(*) FROM [dbo].[tbl_puntajes];
GO

PRINT 'Script ejecutado correctamente. Base de datos lista.';
GO
