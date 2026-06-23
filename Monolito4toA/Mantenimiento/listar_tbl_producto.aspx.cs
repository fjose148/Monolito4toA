using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA.Mantenimientos
{
    public partial class listar_tbl_producto : Page
    {
        protected Literal litMsg;
        protected GridView gvProductos;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Session & Role Authorization Check
            var user = Session["UsuarioLogueado"] as tbl_usuario;
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
                gvProductos.DataSource = CN_tbl_producto.ObtenerTodos();
                gvProductos.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al cargar productos: " + ex.Message);
            }
        }

        protected void gvProductos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProductos.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteProduct")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                try
                {
                    CN_tbl_producto.Eliminar(id);
                    ShowAlert("success", "Producto eliminado correctamente.");
                    BindGrid();
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", "Error al eliminar producto: " + ex.Message);
                }
            }
        }

        protected string GetProductImageSrc(object proIdObj)
        {
            if (proIdObj == null) return ResolveUrl("~/Imagenes/default.jpg");
            int proId = Convert.ToInt32(proIdObj);
            try
            {
                var prod = CN_tbl_producto.ObtenerPorId(proId);
                if (prod != null && prod.tbl_path != null && prod.tbl_path.Count > 0)
                {
                    var firstPath = prod.tbl_path.FirstOrDefault();
                    if (firstPath != null)
                    {
                        return ResolveUrl($"~/ImageHandler.ashx?path_id={firstPath.path_id}");
                    }
                }
            }
            catch
            {
                // ignore and fallback
            }
            return ResolveUrl("~/Imagenes/default.jpg");
        }

        protected string GetProviderName(object prodObj)
        {
            var prod = prodObj as tbl_producto;
            if (prod == null) return "N/A";
            if (prod.tbl_proveedor != null)
            {
                return prod.tbl_proveedor.prov_nombre;
            }
            if (prod.pro_prov_id_backup.HasValue)
            {
                return $"[Inactivo] ID Backup: {prod.pro_prov_id_backup}";
            }
            return "Ninguno";
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
            string color = "#34d399";
            string bg = "rgba(16, 185, 129, 0.1)";
            string border = "rgba(16, 185, 129, 0.2)";

            if (type == "danger")
            {
                color = "#f87171";
                bg = "rgba(239, 68, 68, 0.1)";
                border = "rgba(239, 68, 68, 0.2)";
            }

            litMsg.Text = $@"
                <div style='padding: 20px; border-radius: 16px; margin-bottom: 30px; color: {color}; background: {bg}; border: 1px solid {border}; font-weight: 700; display: flex; align-items: center; gap: 15px; font-size: 14px;'>
                    <i class='fa-solid fa-circle-info' style='font-size: 18px;'></i>
                    <span>{message}</span>
                </div>";
        }
    }
}
