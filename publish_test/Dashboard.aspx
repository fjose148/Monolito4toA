<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Monolito4toA.Dashboard" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Panel de Control — Monolito Secure</title>
    <link rel="shortcut icon" href="favicon.ico?v=2" type="image/x-icon" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --warning: #f59e0b; --danger: #ef4444; --bg-dark: #030712; --card-bg: rgba(15, 23, 42, 0.7); --border: rgba(255, 255, 255, 0.1); --text-main: #f8fafc; --text-dim: #94a3b8; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; overflow: hidden; position: relative; }
        form#form1 { display: flex; height: 100vh; width: 100vw; position: relative; z-index: 1; }

        /* Animated Blobs */
        .blobs { position: fixed; inset: 0; z-index: 0; filter: blur(100px); opacity: 0.4; pointer-events: none; }
        .blob { position: absolute; border-radius: 50%; animation: move 25s infinite alternate; }
        .blob-1 { width: 600px; height: 600px; background: var(--primary); top: -200px; right: -100px; }
        .blob-2 { width: 500px; height: 500px; background: var(--secondary); bottom: -100px; left: -100px; animation-delay: -5s; }
        @keyframes move { from { transform: translate(0, 0) scale(1); } to { transform: translate(150px, 150px) scale(1.3); } }

        /* Sidebar Modernizada */
        .sidebar { width: 280px; background: rgba(7, 10, 20, 0.85); backdrop-filter: blur(30px); border-right: 1px solid var(--border); padding: 40px 20px; display: flex; flex-direction: column; flex-shrink: 0; animation: slideRight 0.8s ease; }
        @keyframes slideRight { from { transform: translateX(-100%); } to { transform: translateX(0); } }

        .logo-box { display: flex; align-items: center; gap: 15px; margin-bottom: 50px; padding-left: 10px; }
        .logo-icon { width: 48px; height: 48px; background: linear-gradient(135deg, var(--primary), var(--secondary)); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 22px; color: white; box-shadow: 0 10px 20px rgba(99, 102, 241, 0.4); }
        
        .nav-link { display: flex; align-items: center; gap: 15px; padding: 18px 20px; color: var(--text-dim); text-decoration: none; border-radius: 20px; font-weight: 700; transition: 0.4s; margin-bottom: 10px; }
        .nav-link i { font-size: 18px; transition: 0.3s; }
        .nav-link:hover { background: rgba(255,255,255,0.05); color: white; transform: translateX(5px); }
        .nav-link.active { background: linear-gradient(90deg, rgba(99,102,241,0.15) 0%, transparent 100%); color: white; border-left: 4px solid var(--primary); }
        .nav-link.active i { color: var(--primary); transform: scale(1.2); }

        /* Main Content */
        .main-content { flex: 1; padding: 40px 60px; overflow-y: auto; scrollbar-width: none; animation: fadeIn 1s ease; }
        .main-content::-webkit-scrollbar { display: none; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 50px; }
        .welcome-text h1 { font-family: 'Outfit'; font-size: 42px; font-weight: 900; letter-spacing: -1.5px; }
        .welcome-text p { color: var(--text-dim); font-size: 16px; font-weight: 500; margin-top: 5px; }

        .user-pill { display: flex; align-items: center; gap: 15px; background: var(--card-bg); padding: 8px 25px 8px 8px; border-radius: 60px; border: 1px solid var(--border); backdrop-filter: blur(10px); transition: 0.3s; cursor: pointer; }
        .user-pill:hover { border-color: var(--primary); transform: translateY(-2px); }
        .user-avatar { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 2px solid var(--primary); box-shadow: 0 0 15px rgba(99, 102, 241, 0.3); }

        /* Stats Section */
        .dashboard-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 50px; }
        .stat-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 32px; padding: 35px; position: relative; overflow: hidden; transition: 0.4s; }
        .stat-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--primary); opacity: 0; transition: 0.3s; }
        .stat-card:hover { transform: translateY(-10px); border-color: var(--primary); }
        .stat-card:hover::before { opacity: 1; }
        .stat-card h3 { font-family: 'Outfit'; font-size: 38px; font-weight: 900; margin-bottom: 8px; background: linear-gradient(to right, white, var(--text-dim)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .stat-card p { color: var(--text-dim); font-weight: 700; text-transform: uppercase; letter-spacing: 1px; font-size: 12px; }
        .stat-icon { position: absolute; right: 30px; top: 35px; font-size: 40px; opacity: 0.1; color: var(--primary); }

        /* Panels */
        .panels-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 35px; }
        .panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 35px; padding: 40px; position: relative; }
        .panel h3 { font-family: 'Outfit'; font-size: 24px; font-weight: 800; margin-bottom: 30px; display: flex; align-items: center; gap: 15px; }
        .panel h3::after { content: ''; height: 2px; flex: 1; background: var(--border); }

        /* Custom Table Modern */
        .table-container { width: 100%; }
        .custom-table { width: 100%; border-collapse: separate; border-spacing: 0 12px; }
        .custom-table th { text-align: left; padding: 0 15px; color: var(--text-dim); font-size: 11px; text-transform: uppercase; font-weight: 800; }
        .custom-table td { padding: 20px 15px; background: rgba(255,255,255,0.02); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); font-weight: 600; }
        .custom-table td:first-child { border-left: 1px solid var(--border); border-radius: 18px 0 0 18px; }
        .custom-table td:last-child { border-right: 1px solid var(--border); border-radius: 0 18px 18px 0; }
        .custom-table tr:hover td { background: rgba(255,255,255,0.05); }

        .badge { padding: 6px 14px; border-radius: 12px; font-size: 11px; font-weight: 800; text-transform: uppercase; }
        .badge-admin { background: rgba(99,102,241,0.15); color: #818cf8; border: 1px solid rgba(99,102,241,0.2); }
        .badge-user { background: rgba(16,185,129,0.15); color: #34d399; border: 1px solid rgba(16,185,129,0.2); }

        /* Widgets Right */
        .widget { background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 25px; padding: 25px; margin-bottom: 25px; transition: 0.3s; }
        .widget:hover { border-color: var(--secondary); background: rgba(255,255,255,0.05); }
        .widget-title { font-size: 13px; font-weight: 800; color: var(--text-dim); margin-bottom: 15px; display: block; }
        
        .clock-box { text-align: center; }
        #clock { font-family: 'Outfit'; font-size: 32px; font-weight: 900; color: white; }
        #date { font-size: 14px; color: var(--text-dim); font-weight: 600; margin-top: 5px; }

        .health-bar { height: 6px; background: rgba(255,255,255,0.1); border-radius: 10px; margin-top: 10px; overflow: hidden; }
        .health-fill { height: 100%; background: linear-gradient(to right, var(--accent), var(--primary)); width: 98%; }

        .logout-btn { margin-top: auto; color: var(--danger); text-decoration: none; font-weight: 800; display: flex; align-items: center; gap: 12px; padding: 18px 20px; border-radius: 20px; transition: 0.3s; border: 1px solid transparent; }
        .logout-btn:hover { background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.2); transform: scale(1.02); }
    </style>
    <script type="text/javascript">
        // Evitar que el usuario retroceda después de cerrar sesión
        function preventBack() { window.history.forward(); }
        setTimeout("preventBack()", 0);
        window.onunload = function () { null };

        function updateClock() {
            const now = new Date();
            const time = now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            const date = now.toLocaleDateString('es-ES', { weekday: 'long', day: 'numeric', month: 'long' });
            document.getElementById('clock').innerText = time;
            document.getElementById('date').innerText = date;
        }
        setInterval(updateClock, 1000);
    </script>
</head>
<body onload="updateClock(); preventBack();">
    <div class="blobs"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>
    <form id="form1" runat="server">
        <aside class="sidebar">
            <div class="logo-box">
                <div class="logo-icon"><i class="fa-solid fa-shield-halved"></i></div>
                <div style="font-family:'Outfit'; font-size:26px; font-weight:900; letter-spacing:-1px;">Monolito</div>
            </div>
            
            <nav>
                <a href="Dashboard.aspx" class="nav-link active"><i class="fa-solid fa-layer-group"></i> Panel Principal</a>
                <a href="Perfil.aspx" class="nav-link"><i class="fa-solid fa-id-card-clip"></i> Mi Perfil</a>
                
                <asp:PlaceHolder ID="phUserNav" runat="server">
                    <a href="UserJuego.aspx" class="nav-link"><i class="fa-solid fa-terminal"></i> Terminal de Juego</a>
                    <a href="UserRombo.aspx" class="nav-link"><i class="fa-solid fa-diamond"></i> Rombo Espiral</a>
                </asp:PlaceHolder>
                
                <asp:PlaceHolder ID="phAdminNav" runat="server">
                    <div style="margin:30px 20px 15px; font-size:11px; color:var(--text-dim); text-transform:uppercase; font-weight:900; letter-spacing:2px;">Centro de Mando</div>
                    <a href="AdminDesbloqueo.aspx" class="nav-link"><i class="fa-solid fa-user-gear"></i> Gestión de Usuarios</a>
                    <a href="Mantenimiento/listar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-box-open"></i> Gestión de Productos</a>
                    <a href="Mantenimiento/listar_tbl_proveedor.aspx" class="nav-link"><i class="fa-solid fa-truck-ramp-box"></i> Gestión de Proveedores</a>
                    <a href="Mantenimiento/importar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-file-excel"></i> Importar/Exportar Excel</a>
                </asp:PlaceHolder>
                
                <a href="Catalogo.aspx" class="nav-link"><i class="fa-solid fa-store"></i> Vitrina de Catálogo</a>
            </nav>

            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="logout-btn">
                <i class="fa-solid fa-power-off"></i> <span>Finalizar Operación</span>
            </asp:LinkButton>
        </aside>

        <main class="main-content">
            <header class="top-bar">
                <div class="welcome-text">
                    <h1>Hola, <span style="color:var(--primary);"><asp:Literal ID="litFirstName" runat="server" /></span> 👋</h1>
                    <p>Bienvenido al centro de operaciones tácticas de Monolito Secure.</p>
                </div>
                <div class="user-pill" onclick="location.href='Perfil.aspx'">
                    <asp:Image ID="imgAvatar" runat="server" CssClass="user-avatar" onerror="this.src='Content/Images/default-avatar.png'" />
                    <div style="display:flex; flex-direction:column;">
                        <span style="font-weight:900; font-size:14px;"><asp:Label ID="lblUserName" runat="server" /></span>
                        <span style="font-size:11px; color:var(--primary); font-weight:800; text-transform:uppercase;"><asp:Label ID="lblRol" runat="server" /></span>
                    </div>
                </div>
            </header>

            <asp:Literal ID="litDashMsg" runat="server" />

            <asp:PlaceHolder ID="phAdminDash" runat="server">
                <div class="dashboard-grid">
                    <div class="stat-card">
                        <i class="fa-solid fa-users stat-icon"></i>
                        <h3><asp:Literal ID="lblAdm1" runat="server" /></h3>
                        <p>Usuarios en Red</p>
                    </div>
                    <div class="stat-card" style="border-bottom: 4px solid var(--danger);">
                        <i class="fa-solid fa-user-slash stat-icon" style="color:var(--danger)"></i>
                        <h3 style="color:var(--danger)"><asp:Literal ID="lblAdm2" runat="server" /></h3>
                        <p>Accesos Bloqueados</p>
                    </div>
                    <div class="stat-card" style="border-bottom: 4px solid var(--accent);">
                        <i class="fa-solid fa-user-plus stat-icon" style="color:var(--accent)"></i>
                        <h3 style="color:var(--accent)"><asp:Literal ID="lblAdm3" runat="server" /></h3>
                        <p>Nuevos Registros</p>
                    </div>
                </div>
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phUserDash" runat="server">
                <div class="dashboard-grid">
                    <div class="stat-card">
                        <i class="fa-solid fa-trophy stat-icon"></i>
                        <h3><asp:Literal ID="lblUsr1" runat="server" /></h3>
                        <p>Record Personal</p>
                    </div>
                    <div class="stat-card">
                        <i class="fa-solid fa-chess-board stat-icon"></i>
                        <h3><asp:Literal ID="lblUsr2" runat="server" /></h3>
                        <p>Simulaciones Ejecutadas</p>
                    </div>
                    <div class="stat-card">
                        <i class="fa-solid fa-earth-americas stat-icon"></i>
                        <h3><asp:Literal ID="lblUsr3" runat="server" /></h3>
                        <p>Ranking Global</p>
                    </div>
                </div>
            </asp:PlaceHolder>

            <div class="panels-grid">
                <div class="panel">
                    <h3><i class="fa-solid fa-list-check" style="color:var(--primary)"></i> <asp:Literal ID="litPanelTitle" runat="server" /></h3>
                    <asp:PlaceHolder ID="phAdminPanels" runat="server">
                        <div class="table-container">
                            <table class="custom-table">
                                <thead><tr><th>Identidad</th><th>Rango Operativo</th><th>Estado</th></tr></thead>
                                <tbody><asp:Literal ID="litUsersTable" runat="server" /></tbody>
                            </table>
                        </div>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phUserPanels" runat="server">
                        <div style="margin-top:10px;"><asp:Literal ID="litScores" runat="server" /></div>
                    </asp:PlaceHolder>
                </div>

                <div class="side-widgets">
                    <div class="widget clock-box">
                        <span class="widget-title">HORA DEL SERVIDOR</span>
                        <div id="clock">00:00:00</div>
                        <div id="date">Cargando fecha...</div>
                    </div>

                    <div class="widget">
                        <span class="widget-title">ESTADO DEL NÚCLEO</span>
                        <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:800;">
                            <span>INTEGRIDAD</span>
                            <span style="color:var(--accent)">100% OPTIMIZADO</span>
                        </div>
                        <div class="health-bar"><div class="health-fill"></div></div>
                    </div>

                    <div class="panel" style="padding:30px; border-radius:25px;">
                        <h3>Acceso Rápido</h3>
                        <div style="display:grid; gap:12px;">
                            <a href="Perfil.aspx" class="nav-link" style="background:rgba(255,255,255,0.03); margin:0;"><i class="fa-solid fa-fingerprint"></i> Configurar Perfil</a>
                            <asp:PlaceHolder ID="phUserActions" runat="server"><a href="UserJuego.aspx" class="nav-link" style="background:rgba(255,255,255,0.03); margin:0;"><i class="fa-solid fa-play"></i> Iniciar Desafío</a></asp:PlaceHolder>
                            <asp:PlaceHolder ID="phAdminActions" runat="server"><a href="AdminDesbloqueo.aspx" class="nav-link" style="background:rgba(255,255,255,0.03); margin:0;"><i class="fa-solid fa-unlock-keyhole"></i> Auditoría de Usuarios</a></asp:PlaceHolder>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
