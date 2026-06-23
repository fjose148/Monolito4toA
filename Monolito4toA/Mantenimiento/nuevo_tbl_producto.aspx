<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="nuevo_tbl_producto.aspx.cs" Inherits="Monolito4toA.Mantenimientos.nuevo_tbl_producto" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Formulario de Producto — Monolito Secure</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --warning: #f59e0b; --danger: #ef4444; --bg-dark: #030712; --card-bg: rgba(15, 23, 42, 0.7); --border: rgba(255, 255, 255, 0.1); --text-main: #f8fafc; --text-dim: #94a3b8; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; overflow: hidden; position: relative; }
        form#form1 { display: flex; height: 100vh; width: 100vw; position: relative; z-index: 1; }
        
        /* Blobs background */
        .blobs { position: fixed; inset: 0; z-index: 0; filter: blur(100px); opacity: 0.3; pointer-events: none; }
        .blob { position: absolute; border-radius: 50%; }
        .blob-1 { width: 500px; height: 500px; background: var(--primary); top: -150px; right: -50px; }
        .blob-2 { width: 400px; height: 400px; background: var(--secondary); bottom: -100px; left: -100px; }

        /* Sidebar styling */
        .sidebar { width: 280px; background: rgba(7, 10, 20, 0.85); backdrop-filter: blur(30px); border-right: 1px solid var(--border); padding: 40px 20px; display: flex; flex-direction: column; flex-shrink: 0; }
        .logo-box { display: flex; align-items: center; gap: 15px; margin-bottom: 50px; padding-left: 10px; }
        .logo-icon { width: 48px; height: 48px; background: linear-gradient(135deg, var(--primary), var(--secondary)); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 22px; color: white; box-shadow: 0 10px 20px rgba(99, 102, 241, 0.4); }
        .nav-link { display: flex; align-items: center; gap: 15px; padding: 18px 20px; color: var(--text-dim); text-decoration: none; border-radius: 20px; font-weight: 700; transition: 0.4s; margin-bottom: 10px; }
        .nav-link i { font-size: 18px; }
        .nav-link:hover { background: rgba(255,255,255,0.05); color: white; transform: translateX(5px); }
        .nav-link.active { background: linear-gradient(90deg, rgba(99,102,241,0.15) 0%, transparent 100%); color: white; border-left: 4px solid var(--primary); }
        .nav-link.active i { color: var(--primary); }
        .logout-btn { margin-top: auto; color: var(--danger); text-decoration: none; font-weight: 800; display: flex; align-items: center; gap: 12px; padding: 18px 20px; border-radius: 20px; transition: 0.3s; border: 1px solid transparent; }
        .logout-btn:hover { background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.2); }

        /* Content area */
        .main-content { flex: 1; padding: 40px 60px; overflow-y: auto; scrollbar-width: none; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px; }
        .title-area h1 { font-family: 'Outfit'; font-size: 38px; font-weight: 900; letter-spacing: -1px; }
        .title-area p { color: var(--text-dim); margin-top: 5px; }

        /* Form Card */
        .panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 45px; backdrop-filter: blur(20px); max-width: 900px; margin: 0 auto; }
        
        /* Form fields */
        .form-group { margin-bottom: 25px; }
        .form-group label { display: block; margin-bottom: 10px; font-weight: 700; color: #e2e8f0; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        .form-control { width: 100%; padding: 16px 20px; background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border); border-radius: 16px; color: white; font-size: 15px; font-weight: 600; transition: 0.3s; }
        .form-control:focus { outline: none; border-color: var(--primary); background: rgba(255, 255, 255, 0.07); box-shadow: 0 0 15px rgba(99, 102, 241, 0.15); }
        select.form-control { appearance: none; -webkit-appearance: none; }
        
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }

        /* Image upload area */
        .upload-section { background: rgba(255, 255, 255, 0.01); border: 2px dashed var(--border); border-radius: 20px; padding: 30px; text-align: center; margin-bottom: 30px; transition: 0.3s; }
        .upload-section:hover { border-color: var(--primary); background: rgba(99, 102, 241, 0.02); }
        .upload-btn-container { display: flex; align-items: center; justify-content: center; gap: 15px; margin-top: 15px; }
        
        /* Previews list */
        .previews-title { margin-top: 25px; margin-bottom: 15px; font-weight: 800; color: white; font-size: 14px; }
        .previews-grid { display: flex; flex-wrap: wrap; gap: 15px; }
        .preview-card { position: relative; width: 110px; height: 110px; border-radius: 16px; overflow: hidden; border: 1px solid var(--border); background: #070a13; }
        .preview-card img { width: 100%; height: 100%; object-fit: cover; }
        .preview-remove-btn { position: absolute; top: 6px; right: 6px; background: var(--danger); border: none; color: white; border-radius: 50%; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; font-size: 12px; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 10px rgba(239, 68, 68, 0.4); }
        .preview-remove-btn:hover { transform: scale(1.1); background: #dc2626; }

        /* Action buttons */
        .form-actions { display: flex; justify-content: flex-end; gap: 20px; margin-top: 40px; }
        .btn-modern { background: linear-gradient(135deg, var(--primary), #4f46e5); color: white; border: none; padding: 16px 36px; border-radius: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; display: inline-flex; align-items: center; gap: 10px; text-decoration: none; font-size: 15px; }
        .btn-modern:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4); }
        .btn-secondary { background: rgba(255, 255, 255, 0.05); color: #f8fafc; border: 1px solid var(--border); }
        .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); transform: translateY(-2px); }
        .btn-upload { background: rgba(99, 102, 241, 0.15); color: #c7d2fe; border: 1px solid rgba(99, 102, 241, 0.25); padding: 10px 20px; font-weight: 700; border-radius: 12px; cursor: pointer; font-size: 13px; transition: 0.2s; }
        .btn-upload:hover { background: rgba(99, 102, 241, 0.25); color: white; }
    </style>
</head>
<body>
    <div class="blobs"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>
    <form id="form1" runat="server">
        <aside class="sidebar">
            <div class="logo-box">
                <div class="logo-icon"><i class="fa-solid fa-shield-halved"></i></div>
                <div style="font-family:'Outfit'; font-size:26px; font-weight:900; letter-spacing:-1px;">Monolito</div>
            </div>
            <nav>
                <a href="../Dashboard.aspx" class="nav-link"><i class="fa-solid fa-layer-group"></i> Panel Principal</a>
                <a href="../Perfil.aspx" class="nav-link"><i class="fa-solid fa-id-card-clip"></i> Mi Perfil</a>
                
                <div style="margin:30px 20px 15px; font-size:11px; color:var(--text-dim); text-transform:uppercase; font-weight:900; letter-spacing:2px;">Centro de Mando</div>
                <a href="../AdminDesbloqueo.aspx" class="nav-link"><i class="fa-solid fa-user-gear"></i> Gestión de Usuarios</a>
                <a href="listar_tbl_producto.aspx" class="nav-link active"><i class="fa-solid fa-box-open"></i> Gestión de Productos</a>
                <a href="listar_tbl_proveedor.aspx" class="nav-link"><i class="fa-solid fa-truck-ramp-box"></i> Gestión de Proveedores</a>
                <a href="importar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-file-excel"></i> Importar/Exportar Excel</a>
                <a href="../Catalogo.aspx" class="nav-link"><i class="fa-solid fa-store"></i> Vitrina de Catálogo</a>
            </nav>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="logout-btn">
                <i class="fa-solid fa-power-off"></i> <span>Cerrar Sesión</span>
            </asp:LinkButton>
        </aside>

        <main class="main-content">
            <header class="top-bar">
                <div class="title-area">
                    <h1><asp:Literal ID="litFormTitle" runat="server">Registrar Producto</asp:Literal></h1>
                    <p>Completa la ficha técnica del producto e incluye imágenes para la vitrina del catálogo.</p>
                </div>
            </header>

            <asp:Literal ID="litMsg" runat="server" />

            <div class="panel">
                <div class="form-group">
                    <label for="txtNombre">Nombre del Producto</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej. Camiseta Deportiva Pro" MaxLength="100" />
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="txtCategoria">Categoría</label>
                        <asp:TextBox ID="txtCategoria" runat="server" CssClass="form-control" placeholder="Ej. Ropa, Deportes, Hogar" MaxLength="50" />
                    </div>
                    <div class="form-group">
                        <label for="ddlProveedor">Proveedor Asociado</label>
                        <asp:DropDownList ID="ddlProveedor" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="txtCantidad">Cantidad en Inventario (Stock)</label>
                        <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" min="0" placeholder="0" />
                    </div>
                    <div class="form-group">
                        <label for="txtPrecio">Precio Unitario ($ USD)</label>
                        <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" placeholder="0.00" />
                    </div>
                </div>

                <div class="form-group">
                    <label for="ddlEstado">Estado Operativo</label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-control">
                        <asp:ListItem Value="A">Activo (Visible en Catálogo)</asp:ListItem>
                        <asp:ListItem Value="I">Inactivo (Oculto)</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div style="margin-top: 35px; border-top: 1px solid var(--border); padding-top: 30px;">
                    <h3 style="font-family:'Outfit'; font-size: 20px; font-weight:800; margin-bottom: 20px; color: white;">Catálogo Fotográfico</h3>
                    
                    <div class="upload-section">
                        <i class="fa-solid fa-cloud-arrow-up" style="font-size: 36px; color: var(--primary); margin-bottom: 15px;"></i>
                        <p style="font-weight: 600; font-size: 14px; color: var(--text-dim);">Selecciona una imagen en formato JPG, PNG, GIF o WEBP.</p>
                        
                        <div class="upload-btn-container">
                            <asp:FileUpload ID="fuImagen" runat="server" AllowMultiple="true" CssClass="form-control" style="max-width: 400px; display: inline-block; padding: 8px 12px; font-size: 13px;" />
                            <asp:Button ID="btnSubirImagen" runat="server" Text="Subir Imagen" CssClass="btn-upload" OnClick="btnSubirImagen_Click" UseSubmitBehavior="false" />
                        </div>
                    </div>

                    <asp:Panel ID="divPreviewsContainer" runat="server" Visible="false">
                        <div class="previews-title">Imágenes subidas (Previsualización):</div>
                        <div class="previews-grid">
                            <asp:Repeater ID="repPreviews" runat="server" OnItemCommand="repPreviews_ItemCommand">
                                <ItemTemplate>
                                    <div class="preview-card">
                                        <img src='<%# ResolveUrl("~/ImageHandler.ashx?preview=true&idx=" + Eval("Index")) %>' alt="Preview" />
                                        <asp:LinkButton ID="btnRemove" runat="server" CommandName="RemoveImage" CommandArgument='<%# Eval("Index") %>' CssClass="preview-remove-btn" title="Quitar Imagen">
                                            <i class="fa-solid fa-xmark"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>
                </div>

                <div class="form-actions">
                    <a href="listar_tbl_producto.aspx" class="btn-modern btn-secondary"><i class="fa-solid fa-arrow-left"></i> Cancelar</a>
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Producto" CssClass="btn-modern" OnClick="btnGuardar_Click" />
                </div>
            </div>
        </main>
    </form>
</body>
</html>
