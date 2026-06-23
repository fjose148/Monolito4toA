using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4toA.Mantenimientos
{
    public partial class nuevo_tbl_producto : Page
    {
        protected Literal litFormTitle;
        protected TextBox txtNombre;
        protected TextBox txtCategoria;
        protected DropDownList ddlProveedor;
        protected TextBox txtCantidad;
        protected TextBox txtPrecio;
        protected DropDownList ddlEstado;
        protected FileUpload fuImagen;
        protected Panel divPreviewsContainer;
        protected Repeater repPreviews;
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
                // Clear session images on fresh load
                Session["TempImages"] = null;
                Session["TempImageTypes"] = null;
                Session["TempImageNames"] = null;

                CargarProveedores();

                if (Request.QueryString["id"] != null)
                {
                    int id;
                    if (int.TryParse(Request.QueryString["id"], out id))
                    {
                        CargarProducto(id);
                    }
                }
            }
        }

        private void CargarProveedores()
        {
            try
            {
                var provs = CN_tbl_proveedor.ObtenerTodos()
                                           .Where(p => p.prov_estado == 'A')
                                           .ToList();
                ddlProveedor.DataSource = provs;
                ddlProveedor.DataTextField = "prov_nombre";
                ddlProveedor.DataValueField = "prov_id";
                ddlProveedor.DataBind();

                ddlProveedor.Items.Insert(0, new ListItem("-- Seleccione Proveedor --", ""));
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al cargar proveedores: " + ex.Message);
            }
        }

        private void CargarProducto(int id)
        {
            try
            {
                var prod = CN_tbl_producto.ObtenerPorId(id);
                if (prod != null)
                {
                    litFormTitle.Text = "Editar Producto";
                    txtNombre.Text = prod.pro_nombre;
                    txtCategoria.Text = prod.pro_categoria;
                    txtCantidad.Text = prod.pro_cantidad.ToString();
                    txtPrecio.Text = prod.pro_precio?.ToString("F2", System.Globalization.CultureInfo.InvariantCulture);
                    
                    if (prod.prov_id.HasValue)
                    {
                        ddlProveedor.SelectedValue = prod.prov_id.Value.ToString();
                    }
                    ddlEstado.SelectedValue = prod.pro_estado.ToString();

                    // Load existing images into session bytes to allow editing/removal
                    var tempImages = new List<byte[]>();
                    var tempImageTypes = new List<string>();
                    var tempImageNames = new List<string>();

                    foreach (var img in prod.tbl_path)
                    {
                        string filePath = img.path_ruta;
                        if (!File.Exists(filePath))
                        {
                            string fileName = Path.GetFileName(filePath);
                            string fallback = Server.MapPath("~/Imagenes/" + fileName);
                            if (File.Exists(fallback))
                            {
                                filePath = fallback;
                            }
                        }

                        if (File.Exists(filePath))
                        {
                            byte[] bytes = File.ReadAllBytes(filePath);
                            string ext = Path.GetExtension(filePath).ToLower();
                            string type = "image/jpeg";
                            if (ext == ".png") type = "image/png";
                            else if (ext == ".gif") type = "image/gif";
                            else if (ext == ".webp") type = "image/webp";

                            tempImages.Add(bytes);
                            tempImageTypes.Add(type);
                            tempImageNames.Add(Path.GetFileName(filePath));
                        }
                    }

                    Session["TempImages"] = tempImages;
                    Session["TempImageTypes"] = tempImageTypes;
                    Session["TempImageNames"] = tempImageNames;

                    BindPreviews();
                }
                else
                {
                    ShowAlert("danger", "El producto especificado no existe.");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al recuperar producto: " + ex.Message);
            }
        }

        protected void btnSubirImagen_Click(object sender, EventArgs e)
        {
            if (fuImagen.HasFiles)
            {
                try
                {
                    var tempImages = Session["TempImages"] as List<byte[]>;
                    var tempImageTypes = Session["TempImageTypes"] as List<string>;
                    var tempImageNames = Session["TempImageNames"] as List<string>;
                    
                    if (tempImages == null) tempImages = new List<byte[]>();
                    if (tempImageTypes == null) tempImageTypes = new List<string>();
                    if (tempImageNames == null) tempImageNames = new List<string>();

                    string[] validExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                    bool hasInvalid = false;

                    foreach (HttpPostedFile file in fuImagen.PostedFiles)
                    {
                        string ext = Path.GetExtension(file.FileName).ToLower();
                        if (!validExtensions.Contains(ext))
                        {
                            hasInvalid = true;
                            continue;
                        }

                        byte[] bytes;
                        using (var ms = new MemoryStream())
                        {
                            file.InputStream.CopyTo(ms);
                            bytes = ms.ToArray();
                        }
                        string type = file.ContentType;
                        string name = Guid.NewGuid().ToString() + ext;

                        tempImages.Add(bytes);
                        tempImageTypes.Add(type);
                        tempImageNames.Add(name);
                    }

                    Session["TempImages"] = tempImages;
                    Session["TempImageTypes"] = tempImageTypes;
                    Session["TempImageNames"] = tempImageNames;

                    BindPreviews();
                    
                    if (hasInvalid)
                    {
                        ShowAlert("warning", "Algunos archivos no se subieron porque no son imágenes permitidas (JPG, PNG, GIF, WEBP).");
                    }
                    else
                    {
                        litMsg.Text = ""; // clear messages on successful upload
                    }
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", "Error al procesar las imágenes: " + ex.Message);
                }
            }
        }

        private void BindPreviews()
        {
            var tempNames = Session["TempImageNames"] as List<string>;
            if (tempNames != null && tempNames.Count > 0)
            {
                repPreviews.DataSource = tempNames.Select((name, index) => new { Index = index, Name = name }).ToList();
                repPreviews.DataBind();
                divPreviewsContainer.Visible = true;
            }
            else
            {
                divPreviewsContainer.Visible = false;
            }
        }

        protected void repPreviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "RemoveImage")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                var tempImages = Session["TempImages"] as List<byte[]>;
                var tempImageTypes = Session["TempImageTypes"] as List<string>;
                var tempImageNames = Session["TempImageNames"] as List<string>;

                if (tempImages != null && index < tempImages.Count)
                {
                    tempImages.RemoveAt(index);
                    tempImageTypes.RemoveAt(index);
                    tempImageNames.RemoveAt(index);

                    Session["TempImages"] = tempImages;
                    Session["TempImageTypes"] = tempImageTypes;
                    Session["TempImageNames"] = tempImageNames;

                    BindPreviews();
                }
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                // Field Validations
                string nombre = txtNombre.Text.Trim();
                string categoria = txtCategoria.Text.Trim();
                if (string.IsNullOrEmpty(nombre))
                {
                    ShowAlert("danger", "Debe ingresar el nombre del producto.");
                    return;
                }
                if (string.IsNullOrEmpty(categoria))
                {
                    ShowAlert("danger", "Debe ingresar una categoría.");
                    return;
                }

                int cantidad;
                if (!int.TryParse(txtCantidad.Text, out cantidad) || cantidad < 0)
                {
                    ShowAlert("danger", "Ingrese una cantidad en inventario válida (mayor o igual a cero).");
                    return;
                }

                decimal precio;
                if (!decimal.TryParse(txtPrecio.Text, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out precio) || precio < 0)
                {
                    if (!decimal.TryParse(txtPrecio.Text, out precio) || precio < 0)
                    {
                        ShowAlert("danger", "Ingrese un precio unitario válido.");
                        return;
                    }
                }

                int? provId = null;
                if (!string.IsNullOrEmpty(ddlProveedor.SelectedValue))
                {
                    provId = int.Parse(ddlProveedor.SelectedValue);
                }
                else
                {
                    ShowAlert("danger", "Debe seleccionar un proveedor válido.");
                    return;
                }

                // A. Save/Rewrite images from Session to physical directory
                string baseFolder = Server.MapPath("~/Imagenes");
                if (!Directory.Exists(baseFolder))
                {
                    Directory.CreateDirectory(baseFolder);
                }

                var tempImages = Session["TempImages"] as List<byte[]>;
                var tempNames = Session["TempImageNames"] as List<string>;
                List<string> savedPaths = new List<string>();

                if (tempImages != null && tempNames != null)
                {
                    for (int i = 0; i < tempImages.Count; i++)
                    {
                        string filename = tempNames[i];
                        string fullPath = Path.Combine(baseFolder, filename);
                        
                        // Only write if it doesn't already exist or to ensure freshness
                        if (!File.Exists(fullPath))
                        {
                            File.WriteAllBytes(fullPath, tempImages[i]);
                        }
                        // Use relative path for cloud hosting compatibility
                        savedPaths.Add("~/Imagenes/" + filename);
                    }
                }

                bool isEdit = Request.QueryString["id"] != null;
                if (isEdit)
                {
                    int id = int.Parse(Request.QueryString["id"]);
                    tbl_producto prod = new tbl_producto
                    {
                        pro_id = id,
                        pro_nombre = nombre,
                        pro_categoria = categoria,
                        pro_cantidad = cantidad,
                        pro_precio = precio,
                        prov_id = provId,
                        pro_estado = ddlEstado.SelectedValue[0]
                    };
                    CN_tbl_producto.Actualizar(prod, savedPaths);
                }
                else
                {
                    tbl_producto prod = new tbl_producto
                    {
                        pro_nombre = nombre,
                        pro_categoria = categoria,
                        pro_cantidad = cantidad,
                        pro_precio = precio,
                        prov_id = provId,
                        pro_estado = 'A' // default active
                    };
                    CN_tbl_producto.Insertar(prod, savedPaths);
                }

                // Clear session uploader variables
                Session["TempImages"] = null;
                Session["TempImageTypes"] = null;
                Session["TempImageNames"] = null;

                Response.Redirect("listar_tbl_producto.aspx");
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al guardar el producto: " + ex.Message);
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
