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
    public partial class DetalleProducto : Page
    {
        protected PlaceHolder phAdminNav;
        protected PlaceHolder phUserNav;
        protected Panel pnlContent;
        protected Repeater repCarousel;
        protected Panel pnlNoImages;
        protected Literal litCategoria;
        protected Literal litNombre;
        protected Literal litProveedor;
        protected Literal litPrecio;
        protected Literal litStock;
        protected Literal litStockBadge;
        protected Literal litMsg;

        // Properties exposed to client script for Chart.js binding
        protected string ChartLabelsJson = "['Este Producto', 'Promedio Categoría', 'Máximo Categoría', 'Mínimo Categoría']";
        protected string ChartPriceDataJson = "[0, 0, 0, 0]";
        protected string StockCurrent = "0";
        protected string StockRemaining = "100";

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
                if (Request.QueryString["id"] != null)
                {
                    int id;
                    if (int.TryParse(Request.QueryString["id"], out id))
                    {
                        CargarDetalle(id);
                    }
                    else
                    {
                        ShowError("ID de producto inválido.");
                    }
                }
                else
                {
                    ShowError("No se especificó ningún ID de producto.");
                }
            }
        }

        private void CargarDetalle(int id)
        {
            try
            {
                var prod = CN_tbl_producto.ObtenerPorId(id);
                if (prod != null)
                {
                    // 1. Basic properties
                    litNombre.Text = prod.pro_nombre;
                    litCategoria.Text = prod.pro_categoria ?? "General";
                    litProveedor.Text = prod.tbl_proveedor != null ? prod.tbl_proveedor.prov_nombre : "Ninguno";
                    litPrecio.Text = string.Format(System.Globalization.CultureInfo.GetCultureInfo("en-US"), "${0:N2}", prod.pro_precio);
                    litStock.Text = prod.pro_cantidad.ToString();

                    // Stock badge
                    if (prod.pro_cantidad == 0)
                    {
                        litStockBadge.Text = "<span class='stock-tag stock-tag-out'>Agotado</span>";
                    }
                    else if (prod.pro_cantidad < 5)
                    {
                        litStockBadge.Text = $"<span class='stock-tag stock-tag-low'>¡Últimas {prod.pro_cantidad} unidades!</span>";
                    }
                    else
                    {
                        litStockBadge.Text = "<span class='stock-tag stock-tag-ok'>Stock Disponible</span>";
                    }

                    // 2. Carousel images
                    if (prod.tbl_path != null && prod.tbl_path.Count > 0)
                    {
                        repCarousel.DataSource = prod.tbl_path;
                        repCarousel.DataBind();
                        pnlNoImages.Visible = false;
                    }
                    else
                    {
                        pnlNoImages.Visible = true;
                    }

                    // 3. Category statistics calculation
                    using (var dc = new DactaClasesDataContext())
                    {
                        string cat = prod.pro_categoria;
                        var sisterProds = dc.tbl_producto
                                            .Where(p => p.pro_categoria == cat && p.pro_estado == 'A')
                                            .ToList();

                        decimal currentPrice = prod.pro_precio ?? 0;
                        decimal avgPrice = sisterProds.Count > 0 ? (sisterProds.Average(p => p.pro_precio) ?? 0) : currentPrice;
                        decimal maxPrice = sisterProds.Count > 0 ? (sisterProds.Max(p => p.pro_precio) ?? 0) : currentPrice;
                        decimal minPrice = sisterProds.Count > 0 ? (sisterProds.Min(p => p.pro_precio) ?? 0) : currentPrice;

                        ChartPriceDataJson = string.Format(System.Globalization.CultureInfo.InvariantCulture,
                            "[{0:F2}, {1:F2}, {2:F2}, {3:F2}]", currentPrice, avgPrice, maxPrice, minPrice);
                    }

                    // 4. Inventory chart stats (Target of 100 units)
                    int currentStock = prod.pro_cantidad ?? 0;
                    StockCurrent = currentStock.ToString();
                    StockRemaining = Math.Max(0, 100 - currentStock).ToString();
                    
                    pnlContent.Visible = true;
                }
                else
                {
                    ShowError("El producto solicitado no existe.");
                }
            }
            catch (Exception ex)
            {
                ShowError("Error al cargar detalles de producto: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            litMsg.Text = $@"
                <div style='padding: 25px; border-radius: 20px; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); color: #f87171; text-align: center;'>
                    <i class='fa-solid fa-circle-exclamation' style='font-size: 30px; margin-bottom: 15px; display:block;'></i>
                    <strong style='font-size:16px;'>Error:</strong> {msg}
                    <div style='margin-top: 20px;'>
                        <a href='Catalogo.aspx' class='btn-back' style='display:inline-flex; width:auto; padding: 12px 25px;'>Volver al Catálogo</a>
                    </div>
                </div>";
            pnlContent.Visible = false;
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
