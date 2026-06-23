using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_usuario
    {
        private const int MAX_INTENTOS = 3; // [CONFIG]
        private const int HORAS_BLOQUEO = 24;

        // [SEGURIDAD - ENCRIPTACIÓN SQL]
        private static byte[] EncriptarPassword(string password, DactaClasesDataContext dc)
        {
            using (var cmd = dc.Connection.CreateCommand())
            {
                cmd.CommandText = "SELECT dbo.encriptacon(@pass)";
                var p = cmd.CreateParameter();
                p.ParameterName = "@pass";
                p.Value = password;
                cmd.Parameters.Add(p);
                bool closed = dc.Connection.State == System.Data.ConnectionState.Closed;
                if (closed) dc.Connection.Open();
                byte[] result = (byte[])cmd.ExecuteScalar();
                if (closed) dc.Connection.Close();
                return result;
            }
        }

        // [VALIDACIÓN - CÉDULA ECUADOR]
        public static bool ValidarCedulaEcuador(string cedula)
        {
            if (string.IsNullOrEmpty(cedula) || cedula.Length != 10 || !cedula.All(char.IsDigit)) return false;
            int provincia = int.Parse(cedula.Substring(0, 2));
            if (provincia < 1 || provincia > 24) return false;
            int[] coef = { 2, 1, 2, 1, 2, 1, 2, 1, 2 };
            int suma = 0;
            for (int i = 0; i < 9; i++) {
                int val = int.Parse(cedula[i].ToString()) * coef[i];
                if (val >= 10) val -= 9;
                suma += val;
            }
            int digitoVerificador = int.Parse(cedula[9].ToString());
            int residuo = suma % 10;
            int calculado = residuo == 0 ? 0 : 10 - residuo;
            return calculado == digitoVerificador;
        }

        // [VALIDACIÓN - CELULAR]
        public static bool ValidarCelularEcuador(string celular)
        {
            if (string.IsNullOrEmpty(celular)) return true;
            string clean = celular.Replace(" ", "").Replace("-", "").Replace("+593", "0");
            return clean.Length == 10 && clean.StartsWith("09") && clean.All(char.IsDigit);
        }

        // [VALIDACIÓN - PASSWORD COMPLEXITY]
        public static bool ValidarPassword(string password, out string mensaje)
        {
            mensaje = string.Empty;
            if (string.IsNullOrEmpty(password) || password.Length < 8) { mensaje = "Mínimo 8 caracteres."; return false; }
            if (!password.Any(char.IsUpper)) { mensaje = "Falta mayúscula."; return false; }
            if (!password.Any(char.IsDigit)) { mensaje = "Falta número."; return false; }
            return true;
        }

        // [DATOS - INSERTAR]
        public static int Insertar(tbl_usuario usuario, string plainPassword)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.InsertarUsuario(usuario, plainPassword);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var encrypted = EncriptarPassword(plainPassword, dc);
                usuario.usu_contraseña = new System.Data.Linq.Binary(encrypted);
                dc.tbl_usuario.InsertOnSubmit(usuario);
                dc.SubmitChanges();
                return usuario.usu_id;
            }
        }

        // [AUTH - LOGIN ESTÁNDAR]
        public static tbl_usuario Autenticar(string nickOrEmail, string password)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.AutenticarUsuario(nickOrEmail, password);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var user = dc.tbl_usuario.FirstOrDefault(u => u.usu_nick == nickOrEmail || u.usu_correo == nickOrEmail);
                if (user == null) return null;
                if (user.usu_estado == 'I') throw new Exception("Cuenta bloqueada.");

                // [SEGURIDAD - DESENCRIPTACIÓN]
                string passDecrypted = dc.ExecuteQuery<string>("SELECT dbo.desencriptacon(usu_contraseña) FROM tbl_usuario WHERE usu_id = {0}", user.usu_id).FirstOrDefault();
                if (passDecrypted == password) {
                    user.usu_intentos = 0;
                    dc.SubmitChanges();
                    return user;
                } else {
                    user.usu_intentos = (user.usu_intentos ?? 0) + 1;
                    if (user.usu_intentos >= MAX_INTENTOS) user.usu_estado = 'I';
                    dc.SubmitChanges();
                    throw new Exception("Incorrecto. Intentos: " + user.usu_intentos);
                }
            }
        }

        // [AUTH - LOGIN QR]
        public static tbl_usuario AutenticarConQR(string qrKey)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.AutenticarConQR(qrKey);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var user = dc.tbl_usuario.FirstOrDefault(u => u.usu_qr_key == qrKey);
                if (user != null && user.usu_estado != 'I') {
                    user.usu_intentos = 0;
                    dc.SubmitChanges();
                    return user;
                }
                return null;
            }
        }

        // [AUTH - OAUTH REDES SOCIALES]
        public static tbl_usuario AutenticarRedSocial(string correo, string nombres, string apellidos)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.AutenticarRedSocial(correo, nombres, apellidos);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var userDb = dc.tbl_usuario.FirstOrDefault(u => u.usu_correo == correo);
                if (userDb != null) return userDb;
                var nuevo = new tbl_usuario {
                    usu_correo = correo, usu_nombres = nombres ?? "Usuario", usu_nick = correo.Split('@')[0],
                    usu_estado = 'A', usu_fecha_creacion = DateTime.Now, usu_intentos = 0,
                    tusu_id = 2, usu_qr_key = Guid.NewGuid().ToString()
                };
                dc.tbl_usuario.InsertOnSubmit(nuevo);
                dc.SubmitChanges();
                return nuevo;
            }
        }

        // [DATOS - CONSULTAS]
        public static tbl_usuario ObtenerPorId(int id) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerUsuarioPorId(id);
            }
            using (var dc = new DactaClasesDataContext()) return dc.tbl_usuario.FirstOrDefault(u => u.usu_id == id);
        }

        public static tbl_usuario ObtenerPorCorreo(string correo) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerUsuarioPorCorreo(correo);
            }
            using (var dc = new DactaClasesDataContext()) return dc.tbl_usuario.FirstOrDefault(u => u.usu_correo == correo);
        }

        public static tbl_usuario ObtenerPorNick(string nick) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerUsuarioPorNick(nick);
            }
            using (var dc = new DactaClasesDataContext()) return dc.tbl_usuario.FirstOrDefault(u => u.usu_nick == nick);
        }

        public static List<tbl_usuario> ObtenerTodos() {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerTodosUsuarios();
            }
            using (var dc = new DactaClasesDataContext()) return dc.tbl_usuario.ToList();
        }

        public static List<tbl_usuario> ObtenerBloqueados() {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerUsuariosBloqueados();
            }
            using (var dc = new DactaClasesDataContext()) return dc.tbl_usuario.Where(u => u.usu_estado == 'I').ToList();
        }

        // [ADMIN - DESBLOQUEO]
        public static void DesbloquearUsuario(int usuId) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.DesbloquearUsuario(usuId);
                return;
            }
            using (var dc = new DactaClasesDataContext()) {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usuId);
                if (u == null) return;
                u.usu_estado = 'A'; u.usu_intentos = 0; dc.SubmitChanges();
            }
        }

        // [SEGURIDAD - ACTUALIZAR PASS]
        public static void ActualizarPassword(int usuId, string newPassword) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ActualizarPassword(usuId, newPassword);
                return;
            }
            using (var dc = new DactaClasesDataContext()) {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usuId);
                if (u == null) return;
                u.usu_contraseña = new System.Data.Linq.Binary(EncriptarPassword(newPassword, dc));
                dc.SubmitChanges();
            }
        }

        // [NOTIFICACIÓN - CORREO]
        public static void EnviarCorreoBienvenida(tbl_usuario user) {
            try {
                MailMessage mail = new MailMessage("monolitosecure@gmail.com", user.usu_correo, "Bienvenido", $"Tu QR: {user.usu_qr_key}");
                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587) { EnableSsl = true, Credentials = new NetworkCredential("user", "pass") };
                smtp.Send(mail);
            } catch { }
        }

        // [SEGURIDAD - ACTUALIZAR OTP]
        public static void ActualizarOTP(int usuId, string otp) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ActualizarOTP(usuId, otp);
                return;
            }
            using (var dc = new DactaClasesDataContext()) {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usuId);
                if (u != null) {
                    u.usu_codigo_OTP = otp;
                    dc.SubmitChanges();
                }
            }
        }

        // [SEGURIDAD - ACTUALIZAR QR KEY]
        public static void ActualizarQRKey(int usuId, string newQRKey) {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ActualizarQRKey(usuId, newQRKey);
                return;
            }
            using (var dc = new DactaClasesDataContext()) {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usuId);
                if (u != null) {
                    u.usu_qr_key = newQRKey;
                    dc.SubmitChanges();
                }
            }
        }

        // [NOTIFICACIÓN - CORREO 2FA]
        public static void EnviarCorreo2FA(string destino, string nombre, string otp, string qrKey) {
            try {
                string remitente = "jmfr148@gmail.com";
                string passwordApp = "xotz wjlz czob kwxg";
                string qrUrl = $"https://api.qrserver.com/v1/create-qr-code/?size=250x250&data={qrKey}";

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(remitente, "Monolito Secure — Autenticación");
                mail.To.Add(destino);
                mail.Subject = "Código de Verificación 2FA - Monolito Secure";
                mail.Body = $@"
                    <div style='font-family:sans-serif; max-width:500px; padding:20px; border:1px solid #e2e8f0; border-radius:16px;'>
                        <h2 style='color:#6366f1;'>Monolito Secure</h2>
                        <p>Hola <b>{nombre}</b>,</p>
                        <p>Para completar tu acceso al sistema, utiliza el siguiente código de verificación de un solo uso (OTP):</p>
                        <div style='background:#f1f5f9; padding:15px; border-radius:12px; text-align:center; font-size:28px; font-weight:bold; letter-spacing:4px; color:#4f46e5; margin:20px 0;'>
                            {otp}
                        </div>
                        <p>Adicionalmente, se ha regenerado tu llave QR personal de acceso. Escanéala en tu próximo ingreso:</p>
                        <div style='text-align:center; margin:20px 0;'>
                            <img src='{qrUrl}' alt='Código QR' style='border: 1px solid #e2e8f0; padding:10px; border-radius:12px;' />
                        </div>
                        <p style='font-size:12px; color:#94a3b8;'>Si no has intentado acceder al sistema, por favor ignora este correo.</p>
                    </div>";
                mail.IsBodyHtml = true;

                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587)) {
                    smtp.Credentials = new NetworkCredential(remitente, passwordApp);
                    smtp.EnableSsl = true;
                    smtp.Send(mail);
                }
            } catch { }
        }

        // [NOTIFICACIÓN - CORREO RECUPERACIÓN]
        public static void EnviarCorreoRecuperacion(string destino, string nombre, string tempPass, string qrKey) {
            try {
                string remitente = "jmfr148@gmail.com";
                string passwordApp = "xotz wjlz czob kwxg";
                string qrUrl = $"https://api.qrserver.com/v1/create-qr-code/?size=250x250&data={qrKey}";

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(remitente, "Monolito Secure — Soporte");
                mail.To.Add(destino);
                mail.Subject = "Restauración de Acceso - Monolito Secure";
                mail.Body = $@"
                    <div style='font-family:sans-serif; max-width:500px; padding:20px; border:1px solid #e2e8f0; border-radius:16px;'>
                        <h2 style='color:#ec4899;'>Restauración de Acceso</h2>
                        <p>Hola <b>{nombre}</b>,</p>
                        <p>Hemos recibido una solicitud para restablecer tu contraseña. A continuación se encuentra tu contraseña temporal:</p>
                        <div style='background:#fdf2f8; padding:15px; border-radius:12px; text-align:center; font-size:22px; font-weight:bold; color:#be185d; margin:20px 0;'>
                            {tempPass}
                        </div>
                        <p><b>Importante:</b> Por razones de seguridad, te recomendamos cambiar esta contraseña desde tu perfil una vez hayas ingresado.</p>
                        <p>También adjuntamos tu código QR de seguridad para el inicio de sesión biométrico:</p>
                        <div style='text-align:center; margin:20px 0;'>
                            <img src='{qrUrl}' alt='Código QR' style='border: 1px solid #e2e8f0; padding:10px; border-radius:12px;' />
                        </div>
                        <p style='font-size:12px; color:#94a3b8;'>Si tú no solicitaste este cambio, puedes seguir usando tu contraseña habitual.</p>
                    </div>";
                mail.IsBodyHtml = true;

                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587)) {
                    smtp.Credentials = new NetworkCredential(remitente, passwordApp);
                    smtp.EnableSsl = true;
                    smtp.Send(mail);
                }
            } catch { }
        }
    }
}
