using System;
using System.Web;
using System.Web.UI;
using System.Net;
using System.Net.Mail;
using Capa_Negocio;
using Capa_Datos;
using System.Web.Security;

namespace Monolito4toA.Seguridad
{
    // [AUTENTICACIÓN - LOGIN]
    public partial class Login : System.Web.UI.Page
    {
        // [EVENTO - CARGA]
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
            }
        }

        // [AUTH - LOGIN MANUAL]
        public void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string usuario = txtUsername.Text.Trim();
                string password = txtPassword.Text.Trim();

                if (string.IsNullOrEmpty(usuario) || string.IsNullOrEmpty(password))
                {
                    MostrarError("Ingresa tus credenciales.");
                    return;
                }

                // [NEGOCIO - VALIDAR]
                var user = CN_tbl_usuario.Autenticar(usuario, password);
                if (user != null)
                {
                    // Generate OTP and new QR key
                    string otp = new Random().Next(100000, 999999).ToString();
                    string newQR = Guid.NewGuid().ToString();

                    CN_tbl_usuario.ActualizarOTP(user.usu_id, otp);
                    CN_tbl_usuario.ActualizarQRKey(user.usu_id, newQR);

                    // Send email with OTP and new QR
                    CN_tbl_usuario.EnviarCorreo2FA(user.usu_correo, user.usu_nombres, otp, newQR);

                    // Show OTP panel
                    Session["TempUserId"] = user.usu_id;
                    pnlLogin.Visible = false;
                    pnlOTP.Visible = true;
                    MostrarError("Código de verificación 2FA enviado a tu correo.", true);
                }
            }
            catch (Exception ex)
            {
                MostrarError(ex.Message);
            }
        }

        // [AUTH - VERIFICAR OTP 2FA]
        protected void btnVerifyOTP_Click(object sender, EventArgs e)
        {
            try
            {
                if (Session["TempUserId"] == null)
                {
                    MostrarError("Sesión de verificación expirada. Ingresa de nuevo.");
                    pnlLogin.Visible = true;
                    pnlOTP.Visible = false;
                    return;
                }

                int userId = (int)Session["TempUserId"];
                string otpInput = txtOTP.Text.Trim();

                if (string.IsNullOrEmpty(otpInput))
                {
                    MostrarError("Ingresa el código OTP.");
                    return;
                }

                var user = CN_tbl_usuario.ObtenerPorId(userId);
                if (user != null)
                {
                    if (user.usu_codigo_OTP == otpInput)
                    {
                        // Limpiar OTP en DB
                        CN_tbl_usuario.ActualizarOTP(user.usu_id, null);
                        
                        Session["UsuarioLogueado"] = user;
                        Session.Remove("TempUserId");
                        Response.Redirect("~/Dashboard.aspx", false);
                    }
                    else
                    {
                        MostrarError("Código OTP incorrecto.");
                    }
                }
                else
                {
                    MostrarError("Usuario no encontrado.");
                }
            }
            catch (Exception ex)
            {
                MostrarError(ex.Message);
            }
        }

        // [AUTH - CANCELAR OTP]
        protected void lnkCancelOTP_Click(object sender, EventArgs e)
        {
            Session.Remove("TempUserId");
            pnlLogin.Visible = true;
            pnlOTP.Visible = false;
            pnlMessage.Visible = false;
            txtOTP.Text = "";
        }

        // [AUTH - LOGIN QR]
        public void btnQRLogin_Click(object sender, EventArgs e)
        {
            try {
                string token = hfQRToken.Value; // [DOM - HIDDEN FIELD]
                var user = CN_tbl_usuario.AutenticarConQR(token);
                if (user != null) {
                    // Rotate QR key for next login
                    string newQR = Guid.NewGuid().ToString();
                    CN_tbl_usuario.ActualizarQRKey(user.usu_id, newQR);

                    // Send email with the new rotated QR key
                    CN_tbl_usuario.EnviarCorreo2FA(user.usu_correo, user.usu_nombres, "ACCESO DIRECTO QR", newQR);

                    Session["UsuarioLogueado"] = user;
                    Response.Redirect("~/Dashboard.aspx", false);
                } else {
                    MostrarError("Llave QR no válida o expirada.");
                }
            } catch (Exception ex) { MostrarError(ex.Message); }
        }

        // [GESTIÓN - VISTAS RECUPERACIÓN]
        public void lnkForgotPassword_Click(object sender, EventArgs e)
        {
            pnlLogin.Visible = false;
            pnlForgotEmail.Visible = true;
            pnlMessage.Visible = false;
        }

        public void lnkBackToLogin_Click(object sender, EventArgs e)
        {
            pnlLogin.Visible = true;
            pnlForgotEmail.Visible = false;
            pnlMessage.Visible = false;
        }

        // [NEGOCIO - RECUPERACIÓN DE CLAVE]
        public void btnSendTempPass_Click(object sender, EventArgs e)
        {
            try {
                string email = txtForgotEmail.Text.Trim();
                if (string.IsNullOrEmpty(email)) { MostrarError("Por favor, ingresa tu correo."); return; }

                var user = CN_tbl_usuario.ObtenerPorCorreo(email);
                if (user != null) {
                    // [SEGURIDAD - GENERAR TEMPORAL]
                    string tempPass = Guid.NewGuid().ToString().Substring(0, 8);
                    CN_tbl_usuario.ActualizarPassword(user.usu_id, tempPass);
                    
                    bool wsSent = false;
                    string wsError = "";

                    // [NOTIFICACIÓN - WHATSAPP RECOVERY]
                    try {
                        if (!string.IsNullOrEmpty(user.usu_celular)) {
                            CN_WhatsApp.EnviarCodigoSeguridad(user.usu_celular, tempPass, user.usu_nombres);
                            wsSent = true;
                        } else {
                            wsError = " (Sin celular)";
                        }
                    } catch(Exception ex) { 
                        wsError = $" (Error API: {ex.Message})";
                        CN_Logger.LogError("Fallo WhatsApp Recovery", "Auth", ex);
                    }

                    // [NOTIFICACIÓN - SMTP EMAIL RECOVERY]
                    try {
                        CN_tbl_usuario.EnviarCorreoRecuperacion(user.usu_correo, user.usu_nombres, tempPass, user.usu_qr_key);
                    } catch(Exception ex) {
                        CN_Logger.LogError("Fallo Correo Recovery", "Auth", ex);
                    }
                    
                    MostrarError($"¡Éxito! Clave temporal enviada vía Correo y WhatsApp.", true);
                    pnlLogin.Visible = true;
                    pnlForgotEmail.Visible = false;
                } else {
                    MostrarError("Correo no vinculado.");
                }
            } catch (Exception ex) { 
                MostrarError("Error: " + ex.Message);
                CN_Logger.LogError("Error en recovery", "Auth", ex);
            }
        }

        // [NAVEGACIÓN - REGISTRO]
        public void lnkRegistrar_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Seguridad/Registrar.aspx", false);
        }

        // [AUTH - OAUTH GOOGLE]
        public void btnGoogle_Click(object sender, EventArgs e)
        {
            string clientId = "763913841788-era6ne66n6ue4djf0au48v6al74ilh1u.apps.googleusercontent.com";
            string redirectUri = Request.Url.Scheme + "://" + Request.Url.Authority + "/Seguridad/OAuthCallback.aspx";
            string authUrl = $"https://accounts.google.com/o/oauth2/v2/auth?client_id={clientId}&redirect_uri={redirectUri}&response_type=code&scope=email profile&state=google";
            Response.Redirect(authUrl, false);
        }

        // [AUTH - OAUTH GITHUB]
        public void btnGithub_Click(object sender, EventArgs e)
        {
            string clientId = "Ov23lio7L1tzTL9Mvm6N";
            string redirectUri = Request.Url.Scheme + "://" + Request.Url.Authority + "/Seguridad/OAuthCallback.aspx";
            string authUrl = $"https://github.com/login/oauth/authorize?client_id={clientId}&redirect_uri={redirectUri}&scope=user:email&state=github";
            Response.Redirect(authUrl, false);
        }

        // [UI - ALERTAS]
        private void MostrarError(string mensaje, bool isSuccess = false)
        {
            pnlMessage.Visible = true;
            litMessage.Text = mensaje;
            divAlert.Attributes["class"] = isSuccess ? "alert alert-success" : "alert alert-error";
            divAlert.InnerHtml = isSuccess 
                ? $"<i class='fa-solid fa-circle-check'></i> {mensaje}" 
                : $"<i class='fa-solid fa-triangle-exclamation'></i> {mensaje}";
        }
    }
}