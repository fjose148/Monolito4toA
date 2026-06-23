USE [Monolillo4to];

DECLARE @idAdmin INT;
SELECT @idAdmin = tusu_id FROM tbl_tipo_usuario WHERE tusu_nombre LIKE 'Admin%';

IF @idAdmin IS NULL
BEGIN
    INSERT INTO tbl_tipo_usuario (tusu_nombre, tusu_estado) VALUES ('Administrador', 'A');
    SET @idAdmin = SCOPE_IDENTITY();
END

IF NOT EXISTS (SELECT 1 FROM tbl_usuario WHERE usu_correo = 'admin@monolito4to.com')
BEGIN
    DECLARE @qr VARCHAR(100) = CAST(NEWID() AS VARCHAR(100));
    DECLARE @pass VARBINARY(MAX) = dbo.encriptacon('Admin@2024!');

    INSERT INTO tbl_usuario (
        usu_cedula, usu_nombres, usu_apellidos, usu_nick,
        usu_correo, usu_celular, usu_direcciones,
        [usu_contraseña], usu_estado, usu_intentos,
        usu_fecha_creacion, tusu_id, usu_qr_key, usu_imagen
    ) VALUES (
        '1700000001', 'Administrador', 'Sistema', 'admin',
        'admin@monolito4to.com', '0962244827', 'Quito, Ecuador',
        @pass, 'A', 0,
        GETDATE(), @idAdmin, @qr, NULL
    );
    PRINT 'Admin creado OK. Pass: Admin@2024! QR: ' + @qr;
END
ELSE
BEGIN
    PRINT 'Admin ya existe.';
END
