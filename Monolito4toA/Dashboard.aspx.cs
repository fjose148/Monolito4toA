using System;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Security;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA
{
    // [DASHBOARD - PANEL PRINCIPAL]
    public partial class Dashboard : System.Web.UI.Page
    {
        private string ConnStr {
            get {
                return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Capa_Datos.Properties.Settings.Monolillo4toConnectionString"].ConnectionString;
            }
        }

        // [EVENTO - CARGA DE PÁGINA]
        protected void Page_Load(object sender, EventArgs e)
        {
            // [SEGURIDAD - ANTI-CACHÉ]
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.MinValue);

            // [AUTH - VERIFICAR SESIÓN]
            if (Session["UsuarioLogueado"] == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                // [DATOS - REFRESCAR SESIÓN]
                var current = (tbl_usuario)Session["UsuarioLogueado"];
                using (var dc = new DactaClasesDataContext())
                {
                    var fresh = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == current.usu_id);
                    if (fresh != null) Session["UsuarioLogueado"] = fresh;
                }
                
                CargarDashboard();
            }
        }

        // [LÓGICA - CARGAR UI SEGÚN ROL]
        private void CargarDashboard()
        {
            try {
                var user = (tbl_usuario)Session["UsuarioLogueado"];
                
                // [UI - PERFIL]
                string displayName = !string.IsNullOrEmpty(user.usu_nombres) 
                    ? $"{user.usu_nombres} {user.usu_apellidos}" 
                    : user.usu_nick;

                lblUserName.Text = displayName;
                lblRol.Text = user.tusu_id == 1 ? "Administrador" : "Usuario Estándar";
                litFirstName.Text = !string.IsNullOrEmpty(user.usu_nombres) ? user.usu_nombres.Split(' ')[0] : user.usu_nick;
                
                // [DATOS - IMAGEN BINARIA]
                string finalImg = ResolveClientUrl("~/Content/Images/default-avatar.png");
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT usu_imagen FROM tbl_usuario WHERE usu_id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", user.usu_id);
                        object val = cmd.ExecuteScalar();
                        if (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString())) finalImg = val.ToString();
                    }
                }
                imgAvatar.ImageUrl = finalImg;

                // [UI - VISIBILIDAD DE PANELES]
                bool isAdmin = (user.tusu_id == 1);
                phAdminNav.Visible = isAdmin;
                phUserNav.Visible = !isAdmin;
                phAdminDash.Visible = isAdmin;
                phAdminPanels.Visible = isAdmin;
                phAdminActions.Visible = isAdmin;
                phUserDash.Visible = !isAdmin;
                phUserPanels.Visible = !isAdmin;
                phUserActions.Visible = !isAdmin;

                if (isAdmin) CargarDatosAdmin();
                else CargarDatosUser(user.usu_id);
            } catch (Exception ex) {
                litDashMsg.Text = $"<div class='alert alert-error'>Error: {ex.Message}</div>";
            }
        }

        // [ADMIN - ESTADÍSTICAS GLOBALES]
        private void CargarDatosAdmin()
        {
            litPanelTitle.Text = "Usuarios del Sistema";
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // [SQL - CONTEOS]
                const string qStats = @"
                    SELECT COUNT(*) FROM tbl_usuario;
                    SELECT COUNT(*) FROM tbl_usuario WHERE usu_estado = 'I';
                    SELECT COUNT(*) FROM tbl_usuario WHERE CAST(usu_fecha_creacion AS DATE) = CAST(GETDATE() AS DATE);";
                
                using (var cmd = new SqlCommand(qStats, conn))
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read()) lblAdm1.Text = r[0].ToString();
                    if (r.NextResult() && r.Read()) lblAdm2.Text = r[0].ToString();
                    if (r.NextResult() && r.Read()) lblAdm3.Text = r[0].ToString();
                }

                // [UI - TABLA DE USUARIOS]
                const string qTable = @"
                    SELECT TOP 10 u.usu_nick, u.usu_correo, u.usu_estado, u.usu_fecha_creacion, t.tusu_nombre
                    FROM tbl_usuario u
                    JOIN tbl_tipo_usuario t ON u.tusu_id = t.tusu_id
                    ORDER BY u.usu_fecha_creacion DESC";
                
                var sb = new StringBuilder();
                using (var cmd = new SqlCommand(qTable, conn))
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string rol = r["tusu_nombre"].ToString();
                        string rolClass = rol.ToLower().Contains("admin") ? "badge-admin" : "badge-user";
                        string estado = r["usu_estado"].ToString() == "A" ? "Activo" : "Bloqueado";
                        string statusClass = r["usu_estado"].ToString() == "A" ? "badge-active" : "badge-blocked";

                        sb.Append($@"
                            <tr>
                                <td>
                                    <div style='font-weight:700;color:var(--primary)'>@{r["usu_nick"]}</div>
                                    <div style='font-size:12px;color:var(--text-muted)'>{r["usu_correo"]}</div>
                                </td>
                                <td><span class='badge {rolClass}'>{rol}</span></td>
                                <td><span class='badge {statusClass}'>{estado}</span></td>
                                <td>{Convert.ToDateTime(r["usu_fecha_creacion"]):dd MMM yyyy}</td>
                            </tr>");
                    }
                }
                litUsersTable.Text = sb.ToString();
            }
        }

        // [USER - RÉCORDS Y PUNTAJES]
        private void CargarDatosUser(int usuId)
        {
            litPanelTitle.Text = "Mis Mejores Records";
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // [SQL - PUNTAJES]
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(pts_puntaje),0) FROM tbl_puntajes WHERE usu_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", usuId);
                    lblUsr1.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM tbl_puntajes WHERE usu_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", usuId);
                    lblUsr2.Text = cmd.ExecuteScalar().ToString();
                }
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(pts_puntaje),0) FROM tbl_puntajes", conn))
                {
                    lblUsr3.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }

                // [UI - LISTA DE RÉCORDS]
                const string qScores = "SELECT TOP 5 pts_puntaje, pts_fecha FROM tbl_puntajes WHERE usu_id=@id ORDER BY pts_puntaje DESC";
                var sb = new StringBuilder();
                using (var cmd = new SqlCommand(qScores, conn))
                {
                    cmd.Parameters.AddWithValue("@id", usuId);
                    using (var r = cmd.ExecuteReader())
                    {
                        int rank = 1;
                        while (r.Read())
                        {
                            sb.Append($@"
                                <div class='record-item'>
                                    <div class='rank-badge'>#{rank}</div>
                                    <div class='pts-text'>{Convert.ToInt32(r["pts_puntaje"]):N0} pts</div>
                                    <div class='date-text'>{Convert.ToDateTime(r["pts_fecha"]):dd/MM/yy}</div>
                                </div>");
                            rank++;
                        }
                    }
                }
                litScores.Text = sb.Length > 0 ? sb.ToString() : "¡Aún no hay records!";
            }
        }

        // [AUTH - CERRAR SESIÓN]
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Clear();
            Session.Abandon();
            
            // [SEGURIDAD - BORRAR COOKIE]
            if (Request.Cookies["AuthToken"] != null)
            {
                var cookie = new HttpCookie("AuthToken") { Expires = DateTime.Now.AddDays(-1) };
                Response.Cookies.Add(cookie);
            }

            Response.Redirect("~/Seguridad/Login.aspx", false);
        }
    }
}

