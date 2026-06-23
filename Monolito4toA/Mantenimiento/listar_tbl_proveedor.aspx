<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="listar_tbl_proveedor.aspx.cs" Inherits="Monolito4toA.Mantenimientos.listar_tbl_proveedor" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gestión de Proveedores — Monolito Secure</title>
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

        /* Sidebar styling matching Dashboard */
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
        .panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 40px; backdrop-filter: blur(20px); }
        
        /* Modern buttons */
        .btn-modern { background: linear-gradient(135deg, var(--primary), #4f46e5); color: white; border: none; padding: 14px 28px; border-radius: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; display: inline-flex; align-items: center; gap: 10px; text-decoration: none; }
        .btn-modern:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4); }

        /* Modern GridView styling */
        .grid-container { margin-top: 30px; overflow-x: auto; }
        .grid-table { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .grid-table th { padding: 15px; color: var(--text-dim); font-size: 11px; text-transform: uppercase; font-weight: 800; border: none; text-align: left; }
        .grid-table td { padding: 18px 15px; background: rgba(255,255,255,0.02); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); font-weight: 600; color: #e2e8f0; }
        .grid-table td:first-child { border-left: 1px solid var(--border); border-radius: 16px 0 0 16px; }
        .grid-table td:last-child { border-right: 1px solid var(--border); border-radius: 0 16px 16px 0; }
        .grid-table tr:hover td { background: rgba(255,255,255,0.05); }

        /* Badges */
        .badge { padding: 6px 14px; border-radius: 12px; font-size: 11px; font-weight: 800; text-transform: uppercase; display: inline-block; }
        .badge-active { background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-inactive { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }

        /* Grid paging */
        .grid-pager td { background: transparent !important; border: none !important; padding: 5px !important; }
        .grid-pager a, .grid-pager span { display: inline-block; padding: 8px 16px; border-radius: 10px; background: rgba(255,255,255,0.03); color: var(--text-dim); text-decoration: none; font-weight: bold; margin-right: 5px; border: 1px solid var(--border); transition: 0.3s; }
        .grid-pager span { background: var(--primary); color: white; border-color: var(--primary); }
        .grid-pager a:hover { background: rgba(99, 102, 241, 0.2); color: white; border-color: var(--primary); }

        /* Action icons */
        .action-link { color: var(--text-dim); font-size: 16px; margin-right: 15px; transition: 0.2s; text-decoration: none; cursor: pointer; }
        .action-link:hover { transform: scale(1.15); }
        .action-edit { color: var(--primary); }
        .action-delete-logical { color: var(--warning); }
        .action-delete-physical { color: var(--danger); }
        .action-restore { color: var(--accent); }
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
                    <h1>Mantenimiento de Proveedores</h1>
                    <p>Administra la relación de proveedores y gestiona eliminaciones en cascada o lógicas.</p>
                </div>
                <div>
                    <a href="nuevo_tbl_proveedor.aspx" class="btn-modern"><i class="fa-solid fa-plus"></i> Registrar Proveedor</a>
                </div>
            </header>

            <asp:Literal ID="litMsg" runat="server" />

            <div class="panel">
                <div class="grid-container">
                    <asp:GridView ID="gvProveedores" runat="server" AutoGenerateColumns="False" 
                        CssClass="grid-table" GridLines="None" AllowPaging="True" PageSize="5"
                        OnPageIndexChanging="gvProveedores_PageIndexChanging" OnRowCommand="gvProveedores_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="prov_id" HeaderText="ID" ItemStyle-Width="60px" />
                            <asp:BoundField DataField="prov_nombre" HeaderText="Nombre del Proveedor" />
                            <asp:TemplateField HeaderText="Estado" ItemStyle-Width="120px">
                                <ItemTemplate>
                                    <span class='<%# Eval("prov_estado").ToString() == "A" ? "badge badge-active" : "badge badge-inactive" %>'>
                                        <%# Eval("prov_estado").ToString() == "A" ? "Activo" : "Inactivo" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Acciones Tácticas" ItemStyle-Width="200px">
                                <ItemTemplate>
                                    <!-- Edit Link -->
                                    <a href='nuevo_tbl_proveedor.aspx?id=<%# Eval("prov_id") %>' class="action-link action-edit" title="Editar">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    
                                    <!-- Logical Delete (Backup & Detach) -->
                                    <asp:LinkButton ID="btnDeleteLogical" runat="server" CommandName="LogicalDelete" CommandArgument='<%# Eval("prov_id") %>' 
                                        CssClass="action-link action-delete-logical" title="Desactivar/Desasociar Productos" 
                                        Visible='<%# Eval("prov_estado").ToString() == "A" %>'
                                        OnClientClick="return confirm('¿Desea desactivar lógicamente este proveedor? Sus productos asociados serán desasociados y guardados en un backup.');">
                                        <i class="fa-solid fa-eye-slash"></i>
                                    </asp:LinkButton>

                                    <!-- Undo Logical Delete (Restore & Reconnect) -->
                                    <asp:LinkButton ID="btnRestore" runat="server" CommandName="RestoreLogical" CommandArgument='<%# Eval("prov_id") %>' 
                                        CssClass="action-link action-restore" title="Restaurar y Reconectar Productos" 
                                        Visible='<%# Eval("prov_estado").ToString() != "A" %>'
                                        OnClientClick="return confirm('¿Desea restaurar este proveedor? Sus productos originales serán reconectados automáticamente.');">
                                        <i class="fa-solid fa-rotate-left"></i>
                                    </asp:LinkButton>

                                    <!-- Physical Delete (Cascade) -->
                                    <asp:LinkButton ID="btnDeletePhysical" runat="server" CommandName="PhysicalDelete" CommandArgument='<%# Eval("prov_id") %>' 
                                        CssClass="action-link action-delete-physical" title="Eliminación Física (Cascada)" 
                                        OnClientClick="return confirm('¡ADVERTENCIA CRÍTICA! Esto eliminará físicamente el proveedor y TODOS sus productos asociados debido al borrado en cascada. ¿Desea continuar?');">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="grid-pager" />
                    </asp:GridView>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
