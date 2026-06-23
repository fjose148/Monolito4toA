using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4toA
{
    public partial class Catalogo : Page
    {
        protected PlaceHolder phAdminNav;
        protected PlaceHolder phUserNav;
        protected TextBox txtBuscar;
        protected DropDownList ddlProveedor;
        protected LinkButton btnCatAll;
        protected Repeater repCategories;
        protected Repeater repCatalog;
        protected Panel pnlCatalog;
        protected Panel pnlEmpty;
        protected Literal litMsg;

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session["UsuarioLogueado"] as tbl_usuario;
            if (user == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx");
                return;
            }

            // Expose sidebar blocks based on role
            bool isAdmin = (user.tusu_id == 1);
            phAdminNav.Visible = isAdmin;
            phUserNav.Visible = !isAdmin;

            if (!IsPostBack)
            {
                ViewState["SelectedCategory"] = "TODAS";
                ViewState["SelectedProviderId"] = 0;
                ViewState["Keyword"] = "";

                CargarFiltros();
                BindCatalog();
            }
        }

        private void CargarFiltros()
        {
            try
            {
                // 1. Categories Chips
                var categories = CN_tbl_producto.ObtenerCategorias();
                repCategories.DataSource = categories;
                repCategories.DataBind();

                // 2. Providers Dropdown
                var providers = CN_tbl_proveedor.ObtenerTodos()
                                               .Where(p => p.prov_estado == 'A')
                                               .ToList();
                ddlProveedor.DataSource = providers;
                ddlProveedor.DataTextField = "prov_nombre";
                ddlProveedor.DataValueField = "prov_id";
                ddlProveedor.DataBind();
                ddlProveedor.Items.Insert(0, new ListItem("Todos los Proveedores", "0"));
            }
            catch (Exception ex)
            {
                litMsg.Text = $"<div class='stock-indicator stock-out'>Error al inicializar filtros: {ex.Message}</div>";
            }
        }

        private void BindCatalog()
        {
            try
            {
                string keyword = ViewState["Keyword"] as string ?? "";
                string category = ViewState["SelectedCategory"] as string ?? "TODAS";
                int provId = (int)(ViewState["SelectedProviderId"] ?? 0);

                int? provIdFilter = (provId > 0) ? (int?)provId : null;

                var products = CN_tbl_producto.ObtenerConFiltros(keyword, category, provIdFilter);

                if (products != null && products.Count > 0)
                {
                    repCatalog.DataSource = products;
                    repCatalog.DataBind();
                    pnlCatalog.Visible = true;
                    pnlEmpty.Visible = false;
                }
                else
                {
                    pnlCatalog.Visible = false;
                    pnlEmpty.Visible = true;
                }
            }
            catch (Exception ex)
            {
                litMsg.Text = $"<div class='stock-indicator stock-out'>Error al buscar productos: {ex.Message}</div>";
            }
        }

        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            ViewState["Keyword"] = txtBuscar.Text.Trim();
            BindCatalog();
        }

        protected void ddlProveedor_SelectedIndexChanged(object sender, EventArgs e)
        {
            int provId = 0;
            int.TryParse(ddlProveedor.SelectedValue, out provId);
            ViewState["SelectedProviderId"] = provId;
            BindCatalog();
        }

        protected void btnCategory_Click(object sender, EventArgs e)
        {
            var btn = (LinkButton)sender;
            string category = btn.CommandArgument;
            ViewState["SelectedCategory"] = category;
            
            BindCatalog();
            HighlightActiveCategory(category);
        }

        private void HighlightActiveCategory(string selectedCategory)
        {
            btnCatAll.CssClass = (selectedCategory == "TODAS") ? "chip active" : "chip";
            foreach (RepeaterItem item in repCategories.Items)
            {
                var btn = item.FindControl("btnCat") as LinkButton;
                if (btn != null)
                {
                    btn.CssClass = (btn.CommandArgument == selectedCategory) ? "chip active" : "chip";
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
                // ignore
            }
            return ResolveUrl("~/Imagenes/default.jpg");
        }

        protected List<string> GetProductImagesSrcs(object proIdObj)
        {
            var defaultList = new List<string> { ResolveUrl("~/Imagenes/default.jpg") };
            if (proIdObj == null) return defaultList;
            
            int proId = Convert.ToInt32(proIdObj);
            try
            {
                var prod = CN_tbl_producto.ObtenerPorId(proId);
                if (prod != null && prod.tbl_path != null && prod.tbl_path.Count > 0)
                {
                    var urlList = new List<string>();
                    foreach (var path in prod.tbl_path)
                    {
                        urlList.Add(ResolveUrl($"~/ImageHandler.ashx?path_id={path.path_id}"));
                    }
                    return urlList;
                }
                return defaultList;
            }
            catch
            {
                return defaultList;
            }
        }

        protected string GetStockText(object qtyObj)
        {
            if (qtyObj == null) return "Sin stock";
            int qty = Convert.ToInt32(qtyObj);
            if (qty == 0) return "Agotado";
            if (qty < 5) return $"¡Últimas {qty} unidades!";
            return $"Disponible: {qty} uds";
        }

        protected string GetStockClass(object qtyObj)
        {
            if (qtyObj == null) return "stock-indicator stock-out";
            int qty = Convert.ToInt32(qtyObj);
            if (qty == 0) return "stock-indicator stock-out";
            if (qty < 5) return "stock-indicator stock-low";
            return "stock-indicator stock-ok";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            System.Web.Security.FormsAuthentication.SignOut();
            Response.Redirect("~/Seguridad/Login.aspx");
        }
    }
}
