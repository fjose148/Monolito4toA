<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="nuevo_tbl_proveedor.aspx.cs" Inherits="Monolito4toA.Mantenimientos.nuevo_tbl_proveedor" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Formulario de Proveedor — Monolito Secure</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --warning: #f59e0b; --danger: #ef4444; --bg-dark: #030712; --card-bg: rgba(15, 23, 42, 0.7); --border: rgba(255, 255, 255, 0.1); --text-main: #f8fafc; --text-dim: #94a3b8; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; overflow: hidden; position: relative; }
        form#form1 { display: flex; height: 100vh; width: 100vw; position: relative; z-index: 1; }
        
        /* Blobs */
        .blobs { position: fixed; inset: 0; z-index: 0; filter: blur(100px); opacity: 0.3; pointer-events: none; }
        .blob { position: absolute; border-radius: 50%; }
        .blob-1 { width: 500px; height: 500px; background: var(--primary); top: -150px; right: -50px; }
        .blob-2 { width: 400px; height: 400px; background: var(--secondary); bottom: -100px; left: -100px; }

        /* Sidebar */
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
        .main-content { flex: 1; padding: 40px 60px; overflow-y: auto; scrollbar-width: none; display: flex; flex-direction: column; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px; }
        .title-area h1 { font-family: 'Outfit'; font-size: 38px; font-weight: 900; letter-spacing: -1px; }
        .title-area p { color: var(--text-dim); margin-top: 5px; }

        /* Form Card */
        .form-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 50px; max-width: 600px; backdrop-filter: blur(20px); align-self: flex-start; width: 100%; }
        
        .form-group { margin-bottom: 25px; display: flex; flex-direction: column; gap: 8px; }
        .form-label { font-size: 13px; font-weight: 800; color: var(--text-dim); text-transform: uppercase; letter-spacing: 1px; }
        
        .input-control { background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 16px; padding: 16px 20px; color: white; font-size: 15px; font-weight: 600; outline: none; transition: 0.3s; width: 100%; }
        .input-control:focus { border-color: var(--primary); background: rgba(255,255,255,0.06); box-shadow: 0 0 15px rgba(99, 102, 241, 0.25); }

        select.input-control { appearance: none; -webkit-appearance: none; background-image: url("data:image/svg+xml;utf8,<svg fill='white' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/><path d='M0 0h24v24H0z' fill='none'/></svg>"); background-repeat: no-repeat; background-position: right 20px center; padding-right: 50px; }

        .btn-group { display: flex; gap: 15px; margin-top: 35px; }
        .btn-submit { background: linear-gradient(135deg, var(--primary), #4f46e5); color: white; border: none; padding: 16px 30px; border-radius: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; flex: 1; text-align: center; }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4); }
        .btn-cancel { background: rgba(255,255,255,0.03); color: var(--text-dim); border: 1px solid var(--border); padding: 16px 30px; border-radius: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; text-decoration: none; text-align: center; }
        .btn-cancel:hover { background: rgba(255,255,255,0.08); color: white; }
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
                <a href="listar_tbl_proveedor.aspx" class="nav-link active"><i class="fa-solid fa-truck-ramp-box"></i> Gestión de Proveedores</a>
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
                    <h1><asp:Literal ID="litFormTitle" runat="server" Text="Registrar Proveedor" /></h1>
                    <p>Completa la información necesaria del proveedor de inventario.</p>
                </div>
            </header>

            <asp:Literal ID="litMsg" runat="server" />

            <div class="form-card">
                <div class="form-group">
                    <label class="form-label" for="txtNombre">Nombre del Proveedor</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="input-control" placeholder="Ej. Amazon Services, Inc." MaxLength="50" Required="true" />
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="ddlEstado">Estado Operativo</label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="input-control">
                        <asp:ListItem Value="A" Text="Activo / Habilitado" Selected="True" />
                        <asp:ListItem Value="I" Text="Inactivo / Deshabilitado" />
                    </asp:DropDownList>
                </div>

                <div class="btn-group">
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Proveedor" CssClass="btn-submit" OnClick="btnGuardar_Click" />
                    <a href="listar_tbl_proveedor.aspx" class="btn-cancel">Cancelar</a>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
