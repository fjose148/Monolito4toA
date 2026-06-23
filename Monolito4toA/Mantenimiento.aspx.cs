using System;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA
{
    public partial class Mantenimiento : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session["UsuarioLogueado"] as tbl_usuario;
            if (user == null || user.tusu_id != 1)
            {
                Response.Redirect("~/Dashboard.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                ActualizarUI();
            }
        }

        private void ActualizarUI()
        {
            bool activo = CN_GlobalSettings.MantenimientoActivo;
            litStatus.Text = activo ? "MANTENIMIENTO ACTIVO" : "SISTEMA OPERATIVO";
            divStatus.Attributes["class"] = activo ? "status-box status-on" : "status-box status-off";
            btnToggle.Text = activo ? "Desactivar Mantenimiento" : "Activar Mantenimiento";
        }

        protected void btnToggle_Click(object sender, EventArgs e)
        {
            CN_GlobalSettings.MantenimientoActivo = !CN_GlobalSettings.MantenimientoActivo;
            ActualizarUI();
        }
    }
}
