using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito4toA.Mantenimientos
{
    public partial class listar_tbl_proveedor : Page
    {
        protected Literal litMsg;
        protected GridView gvProveedores;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Session & Role Authorization Check
            var user = Session["UsuarioLogueado"] as Capa_Datos.tbl_usuario;
            if (user == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx");
                return;
            }

            if (user.tusu_id != 1) // Only Admins allowed here
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            try
            {
                gvProveedores.DataSource = CN_tbl_proveedor.ObtenerTodos();
                gvProveedores.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al cargar proveedores: " + ex.Message);
            }
        }

        protected void gvProveedores_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProveedores.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvProveedores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "LogicalDelete")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    CN_tbl_proveedor.EliminarLogico(id);
                    ShowAlert("warning", "Proveedor desactivado. Sus productos asociados han sido desvinculados (cambiados a Sin Proveedor).");
                    BindGrid();
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", "Error en desactivación lógica: " + ex.Message);
                }
            }
            else if (e.CommandName == "RestoreLogical")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    CN_tbl_proveedor.Restaurar(id);
                    ShowAlert("success", "Proveedor restaurado. Los productos asociados originales han sido reconectados.");
                    BindGrid();
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", "Error al restaurar proveedor: " + ex.Message);
                }
            }
            else if (e.CommandName == "PhysicalDelete")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    CN_tbl_proveedor.EliminarFisico(id);
                    ShowAlert("danger", "Proveedor eliminado físicamente. Sus productos asociados han sido cambiados a Sin Proveedor.");
                    BindGrid();
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", "Error en borrado físico en cascada: " + ex.Message);
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            System.Web.Security.FormsAuthentication.SignOut();
            Response.Redirect("~/Seguridad/Login.aspx");
        }

        private void ShowAlert(string type, string message)
        {
            string color = "#34d399"; // default accent green
            string bg = "rgba(16, 185, 129, 0.1)";
            string border = "rgba(16, 185, 129, 0.2)";

            if (type == "danger")
            {
                color = "#f87171";
                bg = "rgba(239, 68, 68, 0.1)";
                border = "rgba(239, 68, 68, 0.2)";
            }
            else if (type == "warning")
            {
                color = "#fbbf24";
                bg = "rgba(245, 158, 11, 0.1)";
                border = "rgba(245, 158, 11, 0.2)";
            }

            litMsg.Text = $@"
                <div style='padding: 20px; border-radius: 16px; margin-bottom: 30px; color: {color}; background: {bg}; border: 1px solid {border}; font-weight: 700; display: flex; align-items: center; gap: 15px; font-size: 14px;'>
                    <i class='fa-solid fa-circle-info' style='font-size: 18px;'></i>
                    <span>{message}</span>
                </div>";
        }
    }
}
