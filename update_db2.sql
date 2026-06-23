USE [Monolillo4to];
GO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_usuario_imagenes')
BEGIN
    CREATE TABLE [dbo].[tbl_usuario_imagenes] (
        [img_id] INT IDENTITY(1,1) PRIMARY KEY,
        [usu_id] INT NULL,
        [img_binario] VARBINARY(MAX) NULL,
        [img_tipo] VARCHAR(50) NULL,
        CONSTRAINT [FK_imagenes_usuario] FOREIGN KEY ([usu_id]) REFERENCES [dbo].[tbl_usuario] ([usu_id])
    );
END
GO
