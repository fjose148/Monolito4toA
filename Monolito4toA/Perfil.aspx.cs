using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Security;
using System.Data.SqlClient;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA
{
    // [PERFIL - GESTIÓN DE DATOS PERSONALES]
    public partial class Perfil : System.Web.UI.Page
    {
        private string ConnStr {
            get {
                return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Capa_Datos.Properties.Settings.Monolillo4toConnectionString"].ConnectionString;
            }
        }

        // [EVENTO - CARGA]
        protected void Page_Load(object sender, EventArgs e)
        {
            // [SEGURIDAD - ANTI-CACHÉ]
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.MinValue);

            if (Session["UsuarioLogueado"] == null) { Response.Redirect("~/Seguridad/Login.aspx", false); return; }

            if (!IsPostBack)
            {
                Session.Remove("TempPerfilImage");
                Session.Remove("TempPerfilImageType");

                // [DATOS - REFRESCAR SESIÓN]
                var current = (tbl_usuario)Session["UsuarioLogueado"];
                using (var dc = new DactaClasesDataContext())
                {
                    var fresh = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == current.usu_id);
                    if (fresh != null) Session["UsuarioLogueado"] = fresh;
                }
                
                CargarPerfil();
            }
        }

        // [UI - CARGAR DATOS EN VISTA]
        private void CargarPerfil()
        {
            try
            {
                tbl_usuario user;
                // [MODO - EDICIÓN ADMIN]
                if (Request.QueryString["edit_id"] != null)
                {
                    int id = Convert.ToInt32(Request.QueryString["edit_id"]);
                    user = CN_tbl_usuario.ObtenerPorId(id);
                    btnEditar.Visible = false;
                    mvPerfil.ActiveViewIndex = 1;
                    PrellenarCampos(user);
                }
                else user = (tbl_usuario)Session["UsuarioLogueado"];

                if (user == null) return;

                lblFullNombre.Text = $"{user.usu_nombres} {user.usu_apellidos}";
                lblRol.Text = user.tusu_id == 1 ? "Administrador" : "Usuario Estándar";
                lblCedula.Text = user.usu_cedula;
                lblNick.Text = user.usu_nick;
                lblCorreo.Text = user.usu_correo;
                
                // [DATOS - IMAGEN PERFIL]
                string picUrl = ResolveClientUrl("~/Content/Images/default-avatar.png");
                if (Session["TempPerfilImage"] != null)
                {
                    picUrl = ResolveUrl("~/ImageHandler.ashx?previewPerfil=true");
                }
                else
                {
                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (var cmd = new SqlCommand("SELECT usu_imagen FROM tbl_usuario WHERE usu_id = @id", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", user.usu_id);
                            object val = cmd.ExecuteScalar();
                            if (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString())) picUrl = val.ToString();
                        }
                    }
                }
                imgPerfil.ImageUrl = picUrl;

                // [SEGURIDAD - QR ACCESS]
                if (string.IsNullOrEmpty(user.usu_qr_key)) {
                    string newKey = Guid.NewGuid().ToString("N");
                    using (var dc = new DactaClasesDataContext()) {
                        var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == user.usu_id);
                        if (u != null) { u.usu_qr_key = newKey; dc.SubmitChanges(); user.usu_qr_key = newKey; }
                    }
                }
                imgQR.ImageUrl = $"https://api.qrserver.com/v1/create-qr-code/?size=200x200&data={user.usu_qr_key}";
            }
            catch { }
        }

        private void PrellenarCampos(tbl_usuario user)
        {
            txtEditNombres.Text = user.usu_nombres;
            txtEditApellidos.Text = user.usu_apellidos;
            txtEditCelular.Text = user.usu_celular;
            txtEditDireccion.Text = user.usu_direcciones;
        }

        protected void btnEditar_Click(object sender, EventArgs e)
        {
            mvPerfil.ActiveViewIndex = 1;
            PrellenarCampos((tbl_usuario)Session["UsuarioLogueado"]);
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["edit_id"] != null) Response.Redirect("AdminDesbloqueo.aspx", false);
            else mvPerfil.ActiveViewIndex = 0;
        }

        // [NEGOCIO - ACTUALIZAR PERFIL]
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                int targetId;
                if (Request.QueryString["edit_id"] != null) targetId = Convert.ToInt32(Request.QueryString["edit_id"]);
                else targetId = ((tbl_usuario)Session["UsuarioLogueado"]).usu_id;

                using (var dc = new DactaClasesDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == targetId);
                    if (u != null)
                    {
                        u.usu_nombres = txtEditNombres.Text.Trim();
                        u.usu_apellidos = txtEditApellidos.Text.Trim();
                        u.usu_celular = txtEditCelular.Text.Trim();
                        u.usu_direcciones = txtEditDireccion.Text.Trim();

                        // [DATOS - PROCESAR NUEVA IMAGEN DESDE SESIÓN]
                        var tempImg = Session["TempPerfilImage"] as byte[];
                        var tempImgType = Session["TempPerfilImageType"] as string;

                        if (tempImg != null)
                        {
                            byte[] optimizedBin = tempImg;

                            using (SqlConnection conn = new SqlConnection(ConnStr))
                            {
                                conn.Open();
                                // [SQL - RESET PERFIL]
                                using (SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario_imagenes SET img_es_perfil = 0 WHERE usu_id = @id", conn))
                                {
                                    cmd.Parameters.AddWithValue("@id", targetId);
                                    cmd.ExecuteNonQuery();
                                }
                                // [SQL - INSERTAR NUEVA]
                                string q = "INSERT INTO tbl_usuario_imagenes (usu_id, img_binario, img_tipo, img_es_perfil) VALUES (@id, @bin, @tipo, 1)";
                                using (SqlCommand cmd = new SqlCommand(q, conn))
                                {
                                    cmd.Parameters.AddWithValue("@id", targetId);
                                    cmd.Parameters.AddWithValue("@bin", optimizedBin);
                                    cmd.Parameters.AddWithValue("@tipo", tempImgType ?? "image/jpeg");
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            // [OPTIMIZACIÓN - SYNC BASE64]
                            u.usu_imagen = "data:image/jpeg;base64," + Convert.ToBase64String(optimizedBin);
                        }
                        
                        dc.SubmitChanges();
                        Session.Remove("TempPerfilImage");
                        Session.Remove("TempPerfilImageType");
                        Response.Redirect("Perfil.aspx?update=success", false);
                    }
                }
            }
            catch (Exception ex) { CN_Logger.LogError("Error Guardar Perfil", "Perfil", ex); }
        }

        protected void btnSubirPerfil_Click(object sender, EventArgs e)
        {
            if (fuPerfil.HasFile)
            {
                try
                {
                    string ext = Path.GetExtension(fuPerfil.FileName).ToLower();
                    string[] allowedExts = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                    if (!allowedExts.Contains(ext))
                    {
                        lblImgStatus.Text = "Extensión no permitida. Use JPG, PNG, GIF o WEBP.";
                        lblImgStatus.ForeColor = System.Drawing.Color.Red;
                        return;
                    }

                    byte[] rawBin = fuPerfil.FileBytes;
                    byte[] optimized = ResizeImage(rawBin, 400, 400);

                    Session["TempPerfilImage"] = optimized;
                    Session["TempPerfilImageType"] = fuPerfil.PostedFile.ContentType;

                    imgPerfil.ImageUrl = ResolveUrl("~/ImageHandler.ashx?previewPerfil=true&t=" + DateTime.Now.Ticks);
                    lblImgStatus.Text = "Imagen cargada temporalmente. Guarde los cambios para aplicar.";
                    lblImgStatus.ForeColor = System.Drawing.Color.Green;
                }
                catch (Exception ex)
                {
                    lblImgStatus.Text = "Error: " + ex.Message;
                    lblImgStatus.ForeColor = System.Drawing.Color.Red;
                }
            }
        }

        // [SEGURIDAD - REGENERAR QR]
        protected void btnRegenQR_Click(object sender, EventArgs e)
        {
            try {
                var user = (tbl_usuario)Session["UsuarioLogueado"];
                string newKey = Guid.NewGuid().ToString("N");
                using (var dc = new DactaClasesDataContext()) {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == user.usu_id);
                    if (u != null) { u.usu_qr_key = newKey; dc.SubmitChanges(); user.usu_qr_key = newKey; }
                }
                CargarPerfil();
            } catch { }
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
