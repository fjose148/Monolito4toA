USE [Monolillo4to];
GO

-- Drop tables if they exist to start fresh with IDENTITY and Primary Keys
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_path') DROP TABLE [dbo].[tbl_path];
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_producto') DROP TABLE [dbo].[tbl_producto];
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_proveedor') DROP TABLE [dbo].[tbl_proveedor];
GO

-- 1) Create tbl_proveedor with IDENTITY
CREATE TABLE [dbo].[tbl_proveedor] (
    [prov_id] INT IDENTITY(1,1) PRIMARY KEY,
    [prov_nombre] VARCHAR(50) NULL,
    [prov_estado] CHAR(1) NULL
);
GO

-- 2) Create tbl_producto with IDENTITY and Foreign Key (ON DELETE CASCADE)
CREATE TABLE [dbo].[tbl_producto] (
    [pro_id] INT IDENTITY(1,1) PRIMARY KEY,
    [pro_nombre] VARCHAR(50) NULL,
    [pro_cantidad] INT NULL,
    [pro_precio] DECIMAL(9,2) NULL,
    [pro_estado] CHAR(1) NULL,
    [prov_id] INT NULL,
    [pro_categoria] VARCHAR(50) NULL,
    [pro_prov_id_backup] INT NULL,
    CONSTRAINT [FK_tbl_producto_tbl_proveedor] FOREIGN KEY ([prov_id]) REFERENCES [dbo].[tbl_proveedor] ([prov_id]) ON DELETE CASCADE
);
GO

-- 3) Create tbl_path with IDENTITY and Foreign Key (ON DELETE CASCADE)
CREATE TABLE [dbo].[tbl_path] (
    [path_id] INT IDENTITY(1,1) PRIMARY KEY,
    [pro_id] INT NOT NULL,
    [path_ruta] VARCHAR(500) NOT NULL,
    CONSTRAINT [FK_tbl_path_tbl_producto] FOREIGN KEY ([pro_id]) REFERENCES [dbo].[tbl_producto] ([pro_id]) ON DELETE CASCADE
);
GO

-- 4) Create stored procedure to clear and reseed tbl_path
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_reiniciar_tabla_path')
BEGIN
    DROP PROCEDURE sp_reiniciar_tabla_path;
END
GO

CREATE PROCEDURE sp_reiniciar_tabla_path
AS
BEGIN
    DELETE FROM tbl_path;
    DBCC CHECKIDENT ('tbl_path', RESEED, 0);
END
GO
