using System;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito4toA
{
    public partial class UserJuego : System.Web.UI.Page
    {
        private string ConnStr {
            get {
                return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Capa_Datos.Properties.Settings.Monolillo4toConnectionString"].ConnectionString;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UsuarioLogueado"] == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx", false);
                return;
            }

            var user = (Capa_Datos.tbl_usuario)Session["UsuarioLogueado"];
            if (user.tusu_id == 1)
            {
                Response.Redirect("~/Dashboard.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                CargarLeaderboard(user.usu_id);
            }
        }

        private void CargarLeaderboard(int usuId)
        {
            // Best personal score for HUD
            int best = 0;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(pts_puntaje),0) FROM tbl_puntajes WHERE usu_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", usuId);
                    best = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            litBestScore.Text = best.ToString();

            // Top 5 leaderboard
            var sb = new StringBuilder();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string q = @"SELECT TOP 5 u.usu_nick, p.pts_puntaje, p.pts_fecha
                                   FROM tbl_puntajes p JOIN tbl_usuario u ON p.usu_id=u.usu_id
                                   ORDER BY p.pts_puntaje DESC";
                using (var cmd = new SqlCommand(q, conn))
                using (var r = cmd.ExecuteReader())
                {
                    int rank = 1;
                    string[] medals = { "🥇", "🥈", "🥉", "4️⃣", "5️⃣" };
                    while (r.Read())
                    {
                        string fecha = Convert.ToDateTime(r["pts_fecha"]).ToString("dd/MM/yy");
                        sb.Append($@"<div class='score-row-ov'>
                            <div class='sr-rank'>{medals[rank - 1]}</div>
                            <div class='sr-pts'>{Convert.ToInt32(r["pts_puntaje"]):N0} pts</div>
                            <div style='flex:1;font-size:13px;color:#94a3b8'>@{r["usu_nick"]}</div>
                            <div class='sr-date'>{fecha}</div>
                        </div>");
                        rank++;
                    }
                }
            }
            if (sb.Length == 0)
                sb.Append("<div style='text-align:center;color:#64748b;padding:16px'>¡Sé el primero en el leaderboard!</div>");
            litScoresList.Text = sb.ToString();
        }

        protected void btnSaveScore_Click(object sender, EventArgs e)
        {
            if (Session["UsuarioLogueado"] == null) return;
            var user = (Capa_Datos.tbl_usuario)Session["UsuarioLogueado"];

            int pts;
            if (!int.TryParse(hfScoreSave.Value, out pts) || pts <= 0) return;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string q = "INSERT INTO tbl_puntajes (usu_id, pts_puntaje, pts_fecha) VALUES (@uid, @pts, GETDATE())";
                using (var cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", user.usu_id);
                    cmd.Parameters.AddWithValue("@pts", pts);
                    cmd.ExecuteNonQuery();
                }
            }

            Capa_Negocio.CN_Logger.LogInfo($"Puntaje guardado: {user.usu_nick} → {pts} pts", "Juego");
        }
    }
}
