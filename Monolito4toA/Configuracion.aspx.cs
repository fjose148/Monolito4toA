using System;
using System.Web.UI;
using Capa_Datos;

namespace Monolito4toA
{
    public partial class Configuracion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UsuarioLogueado"] == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx");
                return;
            }

            tbl_usuario user = (tbl_usuario)Session["UsuarioLogueado"];
            if (user.tusu_id != 1) // Only Admins can access (tusu_id = 1)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ActualizarUI();
            }
        }

        protected void btnToggleMantenimiento_Click(object sender, EventArgs e)
        {
            bool isMaintenance = Application["MaintenanceMode"] != null && (bool)Application["MaintenanceMode"];
            Application["MaintenanceMode"] = !isMaintenance;
            ActualizarUI();
        }

        private void ActualizarUI()
        {
            bool isMaintenance = Application["MaintenanceMode"] != null && (bool)Application["MaintenanceMode"];
            if (isMaintenance)
            {
                btnToggleMantenimiento.Text = "Desactivar";
                btnToggleMantenimiento.CssClass = "btn-toggle btn-disable";
                lblStatus.Text = "El sistema está actualmente EN MANTENIMIENTO.";
                lblStatus.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ef4444");
            }
            else
            {
                btnToggleMantenimiento.Text = "Activar";
                btnToggleMantenimiento.CssClass = "btn-toggle btn-enable";
                lblStatus.Text = "El sistema está OPERATIVO.";
                lblStatus.ForeColor = System.Drawing.ColorTranslator.FromHtml("#22c55e");
            }
        }
    }
}
