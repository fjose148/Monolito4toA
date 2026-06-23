<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="importar_tbl_producto.aspx.cs" Inherits="Monolito4toA.Mantenimientos.importar_tbl_producto" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Carga Masiva — Monolito Secure</title>
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

        /* Panel Card */
        .panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 40px; backdrop-filter: blur(20px); margin-bottom: 40px; }
        
        .panel-title { font-family: 'Outfit'; font-size: 22px; font-weight: 800; margin-bottom: 20px; display: flex; align-items: center; gap: 12px; }

        /* Modern buttons */
        .btn-modern { background: linear-gradient(135deg, var(--primary), #4f46e5); color: white; border: none; padding: 14px 28px; border-radius: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; display: inline-flex; align-items: center; gap: 10px; text-decoration: none; font-size: 14px; }
        .btn-modern:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4); }
        .btn-secondary { background: rgba(255, 255, 255, 0.05); color: #f8fafc; border: 1px solid var(--border); }
        .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); }
        .btn-danger { background: linear-gradient(135deg, var(--danger), #b91c1c); }
        .btn-danger:hover { box-shadow: 0 8px 20px rgba(239, 68, 68, 0.4); }
        .btn-accent { background: linear-gradient(135deg, var(--accent), #047857); }
        .btn-accent:hover { box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4); }

        /* File input */
        .file-upload-box { background: rgba(255, 255, 255, 0.02); border: 2px dashed var(--border); border-radius: 20px; padding: 40px; text-align: center; margin-bottom: 30px; }
        .file-control { max-width: 500px; display: inline-block; padding: 10px 15px; background: rgba(255, 255, 255, 0.05); border: 1px solid var(--border); border-radius: 12px; color: white; margin-bottom: 20px; width: 100%; }

        /* Template instructions table */
        .format-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .format-table th { color: var(--text-dim); font-size: 11px; text-transform: uppercase; font-weight: 800; padding: 10px; text-align: left; border-bottom: 2px solid var(--border); }
        .format-table td { padding: 12px 10px; border-bottom: 1px solid var(--border); font-size: 13px; font-weight: 600; color: #e2e8f0; }

        /* Preview Grid */
        .preview-container { margin-top: 30px; max-height: 400px; overflow-y: auto; border: 1px solid var(--border); border-radius: 16px; background: rgba(0, 0, 0, 0.2); }
        .grid-table { width: 100%; border-collapse: collapse; }
        .grid-table th { padding: 12px 15px; color: var(--text-dim); font-size: 11px; text-transform: uppercase; font-weight: 800; background: rgba(255,255,255,0.02); position: sticky; top: 0; text-align: left; z-index: 10; border-bottom: 1px solid var(--border); }
        .grid-table td { padding: 12px 15px; border-bottom: 1px solid var(--border); font-size: 13px; font-weight: 600; color: #e2e8f0; }
        .grid-table tr:hover td { background: rgba(255,255,255,0.03); }
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
                <a href="listar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-box-open"></i> Gestión de Productos</a>
                <a href="listar_tbl_proveedor.aspx" class="nav-link"><i class="fa-solid fa-truck-ramp-box"></i> Gestión de Proveedores</a>
                <a href="importar_tbl_producto.aspx" class="nav-link active"><i class="fa-solid fa-file-excel"></i> Importar/Exportar Excel</a>
                <a href="../Catalogo.aspx" class="nav-link"><i class="fa-solid fa-store"></i> Vitrina de Catálogo</a>
            </nav>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="logout-btn">
                <i class="fa-solid fa-power-off"></i> <span>Cerrar Sesión</span>
            </asp:LinkButton>
        </aside>

        <main class="main-content">
            <header class="top-bar">
                <div class="title-area">
                    <h1>Carga Masiva e Integración</h1>
                    <p>Sube archivos planos CSV o planillas Excel para dar de alta productos y proveedores de forma simultánea.</p>
                </div>
            </header>

            <asp:Literal ID="litMsg" runat="server" />

            <!-- PRE-UPLOAD IMAGES SECTION -->
            <div class="panel">
                <div class="panel-title"><i class="fa-solid fa-images" style="color:var(--primary);"></i> Pre-cargar Imágenes de Productos al Servidor</div>
                <p style="color: var(--text-dim); font-size:14px; margin-bottom:15px;">Suba las imágenes de sus productos al servidor antes de procesar el archivo CSV/Excel para que coincidan con sus registros.</p>
                <div class="file-upload-box">
                    <asp:FileUpload ID="fuImagenes" runat="server" CssClass="file-control" AllowMultiple="true" />
                    <div style="margin-top: 10px;">
                        <asp:Button ID="btnUploadImages" runat="server" Text="Subir Imágenes al Servidor" CssClass="btn-modern" OnClick="btnUploadImages_Click" />
                    </div>
                </div>
            </div>

            <!-- STEP 1: IMPORT SECTION -->
            <div class="panel">
                <div class="panel-title"><i class="fa-solid fa-file-arrow-up" style="color:var(--primary);"></i> Subir CSV o Excel (.xlsx, .xls)</div>
                
                <div class="file-upload-box">
                    <asp:FileUpload ID="fuExcel" runat="server" CssClass="file-control" />
                    <div style="margin-top: 10px;">
                        <asp:Button ID="btnPreview" runat="server" Text="Previsualizar Datos" CssClass="btn-modern" OnClick="btnPreview_Click" />
                        <asp:Button ID="btnImportar" runat="server" Text="Confirmar Importación" CssClass="btn-modern btn-accent" OnClick="btnImportar_Click" Visible="false" style="margin-left:15px;" />
                    </div>
                </div>

                <asp:Panel ID="pnlPreview" runat="server" Visible="false">
                    <div class="panel-title" style="margin-top: 30px;"><i class="fa-solid fa-list-check" style="color:var(--accent);"></i> Vista Previa de la Planilla</div>
                    <div class="preview-container">
                        <asp:GridView ID="gvPreview" runat="server" AutoGenerateColumns="true" CssClass="grid-table" GridLines="None" />
                    </div>
                </asp:Panel>
            </div>

            <!-- STEP 2: TEMPLATE FORMAT INSTRUCTIONS -->
            <div class="panel">
                <div class="panel-title"><i class="fa-solid fa-circle-info" style="color:var(--warning);"></i> Estructura de la Planilla Requerida</div>
                <p style="color: var(--text-dim); font-size:14px; margin-bottom:15px;">Para garantizar el éxito de la integración masiva, la primera fila de su planilla (cabecera) debe coincidir exactamente con los nombres de las siguientes columnas:</p>
                
                <table class="format-table">
                    <thead>
                        <tr>
                            <th>Columna</th>
                            <th>Tipo</th>
                            <th>Descripción / Regla</th>
                            <th>Ejemplo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>proveedor_nombre</strong></td>
                            <td>Texto (100)</td>
                            <td>Nombre del proveedor. Si no existe en BD, se creará automáticamente.</td>
                            <td>Apple Inc.</td>
                        </tr>
                        <tr>
                            <td><strong>producto_nombre</strong></td>
                            <td>Texto (100)</td>
                            <td>Nombre único del producto a registrar o actualizar.</td>
                            <td>iPhone 15 Pro Max</td>
                        </tr>
                        <tr>
                            <td><strong>producto_cantidad</strong></td>
                            <td>Entero</td>
                            <td>Stock inicial disponible. Mayor o igual a cero.</td>
                            <td>50</td>
                        </tr>
                        <tr>
                            <td><strong>producto_precio</strong></td>
                            <td>Decimal</td>
                            <td>Precio unitario (Formato numérico sin símbolos de moneda).</td>
                            <td>1199.99</td>
                        </tr>
                        <tr>
                            <td><strong>producto_estado</strong></td>
                            <td>Carácter (1)</td>
                            <td>'A' para Activo / 'I' para Inactivo.</td>
                            <td>A</td>
                        </tr>
                        <tr>
                            <td><strong>producto_categoria</strong></td>
                            <td>Texto (50)</td>
                            <td>Categoría del producto para filtrado y navegación.</td>
                            <td>Tecnología</td>
                        </tr>
                        <tr>
                            <td><strong>imagenes</strong></td>
                            <td>Texto (Largo)</td>
                            <td>Nombres de archivos de imagen separados por punto y coma (;) o comas (,).</td>
                            <td>iphone15.jpg;iphone15_side.png</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- STEP 3: EXPORT & RESTORE UTILITIES -->
            <div class="panel" style="display:grid; grid-template-columns: 1fr 1fr; gap:30px;">
                <div>
                    <div class="panel-title"><i class="fa-solid fa-file-arrow-down" style="color:var(--primary);"></i> Descargar Respaldo de Base de Datos</div>
                    <p style="color: var(--text-dim); font-size:14px; margin-bottom:20px;">Exporte el inventario completo de productos actual en formato CSV compatible con Excel.</p>
                    <asp:LinkButton ID="btnExportar" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnExportar_Click">
                        <i class="fa-solid fa-download"></i> Descargar Inventario (.csv)
                    </asp:LinkButton>
                </div>
                <div>
                    <div class="panel-title" style="color: var(--danger);"><i class="fa-solid fa-circle-exclamation"></i> Herramientas de Mantenimiento Crítico</div>
                    <p style="color: var(--text-dim); font-size:14px; margin-bottom:20px;">Procedimiento para reiniciar la tabla de rutas de imágenes y reindexar los contadores del catálogo fotográfico.</p>
                    <asp:LinkButton ID="btnResetPath" runat="server" CssClass="btn-modern btn-danger" OnClick="btnResetPath_Click"
                        OnClientClick="return confirm('¿Está seguro de restablecer por completo la tabla de imágenes (tbl_path)? Esto borrará todos los enlaces de imágenes y reiniciará el identificador incremental a cero.');">
                        <i class="fa-solid fa-trash-arrow-up"></i> Reiniciar Tabla Path
                    </asp:LinkButton>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
