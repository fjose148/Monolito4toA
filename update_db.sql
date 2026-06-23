USE [Monolillo4to];
GO

ALTER TABLE tbl_usuario ADD usu_qr_key VARCHAR(100);
GO

CREATE FUNCTION encriptacon (@clave VARCHAR(50)) 
RETURNS VARBINARY(MAX) 
AS 
BEGIN 
    DECLARE @pass VARBINARY(MAX); 
    SET @pass = ENCRYPTBYPASSPHRASE('cl@ve', @clave); 
    RETURN @pass; 
END;
GO

CREATE FUNCTION desencriptacon (@clave VARBINARY(MAX)) 
RETURNS VARCHAR(50) 
AS 
BEGIN 
    DECLARE @pass VARCHAR(50); 
    SET @pass = CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('cl@ve', @clave)); 
    RETURN @pass; 
END;
GO
