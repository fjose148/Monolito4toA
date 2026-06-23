using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4toA.Mantenimientos
{
    public partial class nuevo_tbl_proveedor : Page
    {
        protected Literal litFormTitle;
        protected TextBox txtNombre;
        protected DropDownList ddlEstado;
        protected Literal litMsg;

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session["UsuarioLogueado"] as tbl_usuario;
            if (user == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx");
                return;
            }

            if (user.tusu_id != 1)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Request.QueryString["id"] != null)
                {
                    int id;
                    if (int.TryParse(Request.QueryString["id"], out id))
                    {
                        CargarProveedor(id);
                    }
                }
            }
        }

        private void CargarProveedor(int id)
        {
            try
            {
                var prov = CN_tbl_proveedor.ObtenerPorId(id);
                if (prov != null)
                {
                    litFormTitle.Text = "Editar Proveedor";
                    txtNombre.Text = prov.prov_nombre;
                    ddlEstado.SelectedValue = prov.prov_estado.ToString();
                }
                else
                {
                    ShowAlert("danger", "El proveedor especificado no existe.");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al recuperar proveedor: " + ex.Message);
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                string nombre = txtNombre.Text.Trim();
                if (string.IsNullOrEmpty(nombre))
                {
                    ShowAlert("danger", "Debe ingresar un nombre de proveedor válido.");
                    return;
                }

                bool isEdit = Request.QueryString["id"] != null;
                tbl_proveedor prov;

                if (isEdit)
                {
                    int id = int.Parse(Request.QueryString["id"]);
                    prov = new tbl_proveedor
                    {
                        prov_id = id,
                        prov_nombre = nombre,
                        prov_estado = ddlEstado.SelectedValue[0]
                    };
                    CN_tbl_proveedor.Actualizar(prov);
                }
                else
                {
                    prov = new tbl_proveedor
                    {
                        prov_nombre = nombre,
                        prov_estado = ddlEstado.SelectedValue[0]
                    };
                    CN_tbl_proveedor.Insertar(prov);
                }

                Response.Redirect("listar_tbl_proveedor.aspx");
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al guardar: " + ex.Message);
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
            string color = "#f87171";
            string bg = "rgba(239, 68, 68, 0.1)";
            string border = "rgba(239, 68, 68, 0.2)";

            litMsg.Text = $@"
                <div style='padding: 20px; border-radius: 16px; margin-bottom: 30px; color: {color}; background: {bg}; border: 1px solid {border}; font-weight: 700; display: flex; align-items: center; gap: 15px; font-size: 14px;'>
                    <i class='fa-solid fa-circle-info' style='font-size: 18px;'></i>
                    <span>{message}</span>
                </div>";
        }
    }
}
