using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA.Seguridad
{
    // [REGISTRO - GESTIÓN DE USUARIOS NUEVOS]
    public partial class Registrar : System.Web.UI.Page
    {
        private string ConnStr {
            get {
                return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Capa_Datos.Properties.Settings.Monolillo4toConnectionString"].ConnectionString;
            }
        }

        private static readonly string[] AllowedExts = { ".jpg", ".jpeg", ".png", ".gif", ".webp" }; // [CONFIG]

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                // [DATOS - LIMPIAR TEMPORALES]
                Session.Remove("TempImages");
                Session.Remove("TempImageTypes");
                Session.Remove("ProfileImageIndex");
            }
        }

        // [EVENTO - PROCESO DE REGISTRO]
        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            try
            {
                string cedula = txtCedula.Text.Trim();
                string nombres = txtNombres.Text.Trim();
                string apellidos = txtApellidos.Text.Trim();
                string email = txtCorreo.Text.Trim();
                string celular = txtCelular.Text.Trim();
                string nick = txtNick.Text.Trim();
                string password = txtPassword.Text.Trim();
                string confirmPass = txtConfirmPassword.Text.Trim();

                // [VALIDACIÓN - REGLAS DE NEGOCIO]
                if (string.IsNullOrEmpty(cedula) || string.IsNullOrEmpty(nombres) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(nick) || string.IsNullOrEmpty(password))
                {
                    MostrarMensaje("Campos obligatorios vacíos.", false); return;
                }

                if (!CN_tbl_usuario.ValidarCedulaEcuador(cedula)) { MostrarMensaje("Cédula inválida.", false); return; }
                if (!string.IsNullOrEmpty(celular) && !CN_tbl_usuario.ValidarCelularEcuador(celular)) { MostrarMensaje("Celular inválido.", false); return; }
                if (password != confirmPass) { MostrarMensaje("Contraseñas no coinciden.", false); return; }

                string msgPass;
                if (!CN_tbl_usuario.ValidarPassword(password, out msgPass)) { MostrarMensaje(msgPass, false); return; }

                // [DATOS - VERIFICAR EXISTENCIA]
                if (CN_tbl_usuario.ObtenerPorCorreo(email) != null) { MostrarMensaje("Correo ya registrado.", false); return; }
                if (CN_tbl_usuario.ObtenerPorNick(nick) != null) { MostrarMensaje("Nick ya en uso.", false); return; }

                // [NEGOCIO - CREAR ENTIDAD]
                string qrKey = Guid.NewGuid().ToString();
                int tusuId = CN_tbl_tipo_usuario.ObtenerIdUsuarioNormal();

                tbl_usuario nuevoUsuario = new tbl_usuario
                {
                    usu_cedula = cedula, usu_nombres = nombres, usu_apellidos = apellidos,
                    usu_correo = email, usu_celular = celular, usu_nick = nick, 
                    usu_estado = 'A', usu_fecha_creacion = DateTime.Now,
                    usu_intentos = 0, tusu_id = tusuId, usu_qr_key = qrKey
                };

                int nuevoId = CN_tbl_usuario.Insertar(nuevoUsuario, password);

                // [DATOS - PROCESAR IMÁGENES BINARIAS]
                int profileIdx = 0;
                int.TryParse(hfSelectedIndex.Value, out profileIdx);

                var tempImages = Session["TempImages"] as List<byte[]>;
                var tempImageTypes = Session["TempImageTypes"] as List<string>;

                if (tempImages != null && tempImages.Count > 0)
                {
                    using (SqlConnection conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        for (int i = 0; i < tempImages.Count; i++)
                        {
                            byte[] bin = tempImages[i];
                            string contentType = tempImageTypes[i];

                            bool esPerfil = (i == profileIdx);
                            string qInsert = "INSERT INTO tbl_usuario_imagenes (usu_id, img_binario, img_tipo, img_es_perfil) VALUES (@id, @bin, @tipo, @perfil)";
                            using (var cmd = new SqlCommand(qInsert, conn))
                            {
                                cmd.Parameters.AddWithValue("@id", nuevoId);
                                cmd.Parameters.AddWithValue("@bin", bin);
                                cmd.Parameters.AddWithValue("@tipo", contentType);
                                cmd.Parameters.AddWithValue("@perfil", esPerfil ? 1 : 0);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        
                        // [OPTIMIZACIÓN - AVATAR BASE64]
                        if (profileIdx >= 0 && profileIdx < tempImages.Count)
                        {
                            byte[] bin = tempImages[profileIdx];
                            byte[] optimized = ResizeImage(bin, 400, 400); // [RESIZE]
                            string base64 = "data:image/jpeg;base64," + Convert.ToBase64String(optimized);
                            
                            using (var cmd = new SqlCommand("UPDATE tbl_usuario SET usu_imagen=@base64 WHERE usu_id=@id", conn))
                            {
                                cmd.Parameters.AddWithValue("@base64", base64);
                                cmd.Parameters.AddWithValue("@id", nuevoId);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                }

                // [NOTIFICACIÓN - BIENVENIDA MULTICANAL]
                EnviarCorreoBienvenida(email, nombres, qrKey);
                if (!string.IsNullOrEmpty(celular)) CN_WhatsApp.EnviarBienvenida(celular, nombres, qrKey);

                Session.Remove("TempImages");
                Session.Remove("TempImageTypes");
                MostrarMensaje($"¡Registro exitoso! Revisa tu correo/WhatsApp.", true);
                LimpiarCampos();
            }
            catch (Exception ex)
            {
                CN_Logger.LogError("Fallo registro", "Registro", ex);
                MostrarMensaje("Error: " + ex.Message, false);
            }
        }

        // [NOTIFICACIÓN - SMTP GMAIL]
        private void EnviarCorreoBienvenida(string destino, string nombre, string qrKey)
        {
            try
            {
                string remitente = "jmfr148@gmail.com";
                string passwordApp = "xotz wjlz czob kwxg"; // [CREDENTIALS]
                string qrUrl = $"https://api.qrserver.com/v1/create-qr-code/?size=250x250&data={qrKey}";

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(remitente, "Monolito — Seguridad");
                mail.To.Add(destino);
                mail.Subject = "Bienvenido - Tu QR de Acceso";
                mail.Body = $"<h2>Hola {nombre}</h2><p>Tu llave QR: <b>{qrKey}</b></p><img src='{qrUrl}' />";
                mail.IsBodyHtml = true;

                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587) { Credentials = new NetworkCredential(remitente, passwordApp), EnableSsl = true };
                smtp.Send(mail);
            }
            catch (Exception ex) { CN_Logger.LogError("Error correo bienvenida", "Correo", ex); }
        }

        // [OAUTH - EXTERNOS]
        protected void btnGoogleRegister_Click(object sender, EventArgs e) { Response.Redirect("GoogleLogin.aspx"); }
        protected void btnGithubRegister_Click(object sender, EventArgs e) { Response.Redirect("GitHubLogin.aspx"); }

        protected void lnkLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }

        protected void btnSubirImagen_Click(object sender, EventArgs e)
        {
            if (fuImagen.HasFiles)
            {
                try
                {
                    var tempImages = Session["TempImages"] as List<byte[]>;
                    var tempImageTypes = Session["TempImageTypes"] as List<string>;

                    if (tempImages == null) tempImages = new List<byte[]>();
                    if (tempImageTypes == null) tempImageTypes = new List<string>();

                    foreach (var file in fuImagen.PostedFiles)
                    {
                        string ext = Path.GetExtension(file.FileName).ToLower();
                        if (!AllowedExts.Contains(ext))
                        {
                            MostrarMensaje("Extensión de archivo no permitida. Use JPG, PNG, GIF o WEBP.", false);
                            return;
                        }

                        byte[] bytes;
                        using (var br = new BinaryReader(file.InputStream))
                        {
                            bytes = br.ReadBytes(file.ContentLength);
                        }

                        tempImages.Add(bytes);
                        tempImageTypes.Add(file.ContentType);
                    }

                    Session["TempImages"] = tempImages;
                    Session["TempImageTypes"] = tempImageTypes;

                    // Default selection to first image if nothing selected yet
                    if (string.IsNullOrEmpty(hfSelectedIndex.Value) || hfSelectedIndex.Value == "0")
                    {
                        hfSelectedIndex.Value = "0";
                    }

                    BindPreviews();
                }
                catch (Exception ex)
                {
                    MostrarMensaje("Error al procesar la imagen: " + ex.Message, false);
                }
            }
        }

        private void BindPreviews()
        {
            var tempImages = Session["TempImages"] as List<byte[]>;
            if (tempImages != null && tempImages.Count > 0)
            {
                repPreviews.DataSource = tempImages.Select((img, index) => new { Index = index }).ToList();
                repPreviews.DataBind();
                divPreviewsContainer.Visible = true;
            }
            else
            {
                divPreviewsContainer.Visible = false;
            }
        }

        protected void repPreviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectProfile")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                hfSelectedIndex.Value = index.ToString();
                BindPreviews();
            }
        }

        // [UI - HELPERS]
        private void MostrarMensaje(string mensaje, bool esExito)
        {
            pnlMessage.Visible = true;
            litMessage.Text = mensaje;
            divAlert.Attributes["class"] = esExito ? "alert alert-success" : "alert alert-error";
        }

        private void LimpiarCampos()
        {
            txtCedula.Text = txtNombres.Text = txtApellidos.Text = txtCorreo.Text = txtCelular.Text = txtNick.Text = txtPassword.Text = txtConfirmPassword.Text = "";
        }

        // [GRÁFICOS - REDIMENSIONAR]
        private byte[] ResizeImage(byte[] imageBytes, int maxWidth, int maxHeight)
        {
            using (MemoryStream ms = new MemoryStream(imageBytes))
            {
                using (var img = System.Drawing.Image.FromStream(ms))
                {
                    int newWidth, newHeight;
                    double ratio = Math.Min((double)maxWidth / img.Width, (double)maxHeight / img.Height);
                    newWidth = ratio < 1 ? (int)(img.Width * ratio) : img.Width;
                    newHeight = ratio < 1 ? (int)(img.Height * ratio) : img.Height;
                    
                    using (var res = new System.Drawing.Bitmap(newWidth, newHeight))
                    {
                        using (var g = System.Drawing.Graphics.FromImage(res))
                        {
                            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                            g.DrawImage(img, 0, 0, newWidth, newHeight);
                        }
                        using (var outMs = new MemoryStream()) { res.Save(outMs, System.Drawing.Imaging.ImageFormat.Jpeg); return outMs.ToArray(); }
                    }
                }
            }
        }
    }
}

