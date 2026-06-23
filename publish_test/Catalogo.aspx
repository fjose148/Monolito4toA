<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Catalogo.aspx.cs" Inherits="Monolito4toA.Catalogo" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Catálogo de Productos — Monolito Secure</title>
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
        .main-content { flex: 1; padding: 40px 60px; overflow-y: auto; scrollbar-width: none; display: flex; flex-direction: column; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .title-area h1 { font-family: 'Outfit'; font-size: 38px; font-weight: 900; letter-spacing: -1px; }
        .title-area p { color: var(--text-dim); margin-top: 5px; }

        /* Filter panel */
        .filter-section { display: flex; gap: 20px; align-items: center; margin-bottom: 30px; flex-wrap: wrap; }
        .search-box { position: relative; flex: 1; min-width: 300px; }
        .search-box i { position: absolute; left: 20px; top: 50%; transform: translateY(-50%); color: var(--text-dim); font-size: 18px; }
        .search-input { width: 100%; padding: 16px 20px 16px 55px; background: var(--card-bg); border: 1px solid var(--border); border-radius: 20px; color: white; font-size: 15px; font-weight: 600; transition: 0.3s; backdrop-filter: blur(10px); }
        .search-input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 20px rgba(99, 102, 241, 0.2); }

        .select-filter { padding: 16px 20px; background: var(--card-bg); border: 1px solid var(--border); border-radius: 20px; color: white; font-size: 15px; font-weight: 600; backdrop-filter: blur(10px); outline: none; min-width: 200px; cursor: pointer; transition: 0.3s; }
        .select-filter:focus { border-color: var(--primary); }

        /* Category chips */
        .chips-container { display: flex; gap: 10px; margin-bottom: 30px; overflow-x: auto; padding-bottom: 10px; scrollbar-width: none; }
        .chip { padding: 10px 22px; border-radius: 50px; background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border); color: var(--text-dim); font-weight: 700; cursor: pointer; transition: 0.3s; text-decoration: none; display: inline-block; font-size: 13px; }
        .chip:hover { background: rgba(255,255,255,0.08); color: white; }
        .chip.active { background: linear-gradient(135deg, var(--primary), #4f46e5); color: white; border-color: var(--primary); box-shadow: 0 5px 15px rgba(99, 102, 241, 0.3); }

        /* Cards Grid */
        .catalog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 30px; margin-bottom: 40px; }
        
        /* Card styling */
        .product-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 24px; padding: 20px; backdrop-filter: blur(20px); transition: 0.3s; display: flex; flex-direction: column; position: relative; overflow: hidden; }
        .product-card:hover { transform: translateY(-5px); border-color: rgba(99, 102, 241, 0.3); box-shadow: 0 15px 30px rgba(0,0,0,0.4); }
        
        .card-img-container { height: 200px; border-radius: 16px; overflow-x: auto; scroll-snap-type: x mandatory; scrollbar-width: none; display: flex; position: relative; margin-bottom: 20px; background: #070a13; }
        .card-img-container::-webkit-scrollbar { display: none; }
        .card-img { flex: 0 0 100%; scroll-snap-align: center; width: 100%; height: 100%; object-fit: cover; transition: 0.5s; }
        .product-card:hover .card-img { transform: scale(1.08); }
        
        .category-badge { position: absolute; top: 15px; left: 15px; background: rgba(3, 7, 18, 0.75); border: 1px solid var(--border); padding: 5px 12px; border-radius: 10px; font-size: 11px; font-weight: 800; text-transform: uppercase; color: var(--secondary); letter-spacing: 0.5px; backdrop-filter: blur(5px); }

        .card-body { display: flex; flex-direction: column; flex: 1; }
        .card-title { font-family: 'Outfit'; font-size: 20px; font-weight: 800; color: white; margin-bottom: 8px; line-height: 1.3; }
        .card-provider { font-size: 12px; color: var(--text-dim); margin-bottom: 15px; display: flex; align-items: center; gap: 6px; }
        .card-provider i { color: var(--primary); }

        .card-footer { border-top: 1px solid var(--border); padding-top: 15px; margin-top: auto; display: flex; justify-content: space-between; align-items: center; }
        .price-box { display: flex; flex-direction: column; }
        .price-lbl { font-size: 10px; text-transform: uppercase; color: var(--text-dim); font-weight: 800; letter-spacing: 1px; }
        .price-val { font-family: 'Outfit'; font-size: 22px; font-weight: 900; color: var(--accent); }
        
        .btn-detail { background: rgba(99, 102, 241, 0.1); border: 1px solid rgba(99, 102, 241, 0.25); color: #c7d2fe; width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 16px; transition: 0.3s; text-decoration: none; }
        .btn-detail:hover { background: var(--primary); color: white; border-color: var(--primary); box-shadow: 0 5px 15px rgba(99, 102, 241, 0.4); transform: scale(1.05); }

        /* Stock Indicator */
        .stock-indicator { font-size: 12px; font-weight: 700; margin-bottom: 12px; }
        .stock-ok { color: var(--accent); }
        .stock-low { color: var(--warning); }
        .stock-out { color: var(--danger); }

        /* Empty state */
        .empty-state { text-align: center; padding: 60px 20px; background: var(--card-bg); border-radius: 30px; border: 1px solid var(--border); }
        .empty-state i { font-size: 50px; color: var(--text-dim); margin-bottom: 20px; }
        .empty-state h3 { font-family: 'Outfit'; font-size: 22px; font-weight: 800; margin-bottom: 10px; }
        .empty-state p { color: var(--text-dim); }
    </style>
    <script type="text/javascript">
        var debounceTimer;
        function debounceSearch() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(function () {
                // Raise postback for txtBuscar
                __doPostBack('<%= txtBuscar.UniqueID %>', '');
            }, 300);
        }

        // Auto-play all carousels in the catalog
        document.addEventListener("DOMContentLoaded", function () {
            // Function to initialize carousels
            function initCarousels() {
                var carousels = document.querySelectorAll('.card-img-container');
                carousels.forEach(function (container) {
                    var slides = container.querySelectorAll('.card-img');
                    if (slides.length > 1 && !container.dataset.initialized) {
                        container.dataset.initialized = "true";
                        var currentIndex = 0;
                        setInterval(function () {
                            currentIndex = (currentIndex + 1) % slides.length;
                            var slideWidth = container.clientWidth;
                            container.scrollTo({
                                left: currentIndex * slideWidth,
                                behavior: 'smooth'
                            });
                        }, 4000); // Change image every 4 seconds
                    }
                });
            }

            // Run once on load
            initCarousels();

            // Re-run after UpdatePanel async postback
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                initCarousels();
            });
        });
    </script>
</head>
<body>
    <div class="blobs"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <aside class="sidebar">
            <div class="logo-box">
                <div class="logo-icon"><i class="fa-solid fa-shield-halved"></i></div>
                <div style="font-family:'Outfit'; font-size:26px; font-weight:900; letter-spacing:-1px;">Monolito</div>
            </div>
            <nav>
                <a href="Dashboard.aspx" class="nav-link"><i class="fa-solid fa-layer-group"></i> Panel Principal</a>
                <a href="Perfil.aspx" class="nav-link"><i class="fa-solid fa-id-card-clip"></i> Mi Perfil</a>
                
                <asp:PlaceHolder ID="phUserNav" runat="server" Visible="false">
                    <a href="UserJuego.aspx" class="nav-link"><i class="fa-solid fa-terminal"></i> Terminal de Juego</a>
                    <a href="UserRombo.aspx" class="nav-link"><i class="fa-solid fa-diamond"></i> Rombo Espiral</a>
                </asp:PlaceHolder>
                
                <asp:PlaceHolder ID="phAdminNav" runat="server" Visible="false">
                    <div style="margin:30px 20px 15px; font-size:11px; color:var(--text-dim); text-transform:uppercase; font-weight:900; letter-spacing:2px;">Centro de Mando</div>
                    <a href="AdminDesbloqueo.aspx" class="nav-link"><i class="fa-solid fa-user-gear"></i> Gestión de Usuarios</a>
                    <a href="Mantenimiento/listar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-box-open"></i> Gestión de Productos</a>
                    <a href="Mantenimiento/listar_tbl_proveedor.aspx" class="nav-link"><i class="fa-solid fa-truck-ramp-box"></i> Gestión de Proveedores</a>
                    <a href="Mantenimiento/importar_tbl_producto.aspx" class="nav-link"><i class="fa-solid fa-file-excel"></i> Importar/Exportar Excel</a>
                </asp:PlaceHolder>
                <a href="Catalogo.aspx" class="nav-link active"><i class="fa-solid fa-store"></i> Vitrina de Catálogo</a>
            </nav>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="logout-btn">
                <i class="fa-solid fa-power-off"></i> <span>Cerrar Sesión</span>
            </asp:LinkButton>
        </aside>

        <main class="main-content">
            <header class="top-bar">
                <div class="title-area">
                    <h1>Vitrina & Catálogo de Productos</h1>
                    <p>Filtre y busque al instante por categorías, stock, precios o palabras clave.</p>
                </div>
            </header>

            <asp:UpdatePanel ID="upCatalog" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- Filters Section -->
                    <div class="filter-section">
                        <div class="search-box">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <asp:TextBox ID="txtBuscar" runat="server" CssClass="search-input" placeholder="Buscar por nombre o descripción..." onkeyup="debounceSearch();" AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged" />
                        </div>
                        <div>
                            <asp:DropDownList ID="ddlProveedor" runat="server" CssClass="select-filter" AutoPostBack="true" OnSelectedIndexChanged="ddlProveedor_SelectedIndexChanged" />
                        </div>
                    </div>

                    <!-- Category Chips -->
                    <div class="chips-container">
                        <asp:LinkButton ID="btnCatAll" runat="server" CssClass="chip active" CommandArgument="TODAS" OnClick="btnCategory_Click">Todas las Categorías</asp:LinkButton>
                        <asp:Repeater ID="repCategories" runat="server">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnCat" runat="server" CssClass="chip" CommandArgument='<%# Container.DataItem %>' OnClick="btnCategory_Click">
                                    <%# Container.DataItem %>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <asp:Literal ID="litMsg" runat="server" />

                    <!-- Catalog Cards Grid -->
                    <asp:Panel ID="pnlCatalog" runat="server">
                        <div class="catalog-grid">
                            <asp:Repeater ID="repCatalog" runat="server">
                                <ItemTemplate>
                                    <div class="product-card">
                                        <div class="card-img-container">
                                            <span class="category-badge" style="position:absolute; top:10px; left:10px; z-index:10;"><%# Eval("pro_categoria") ?? "General" %></span>
                                            <asp:Repeater ID="repImages" runat="server" DataSource='<%# GetProductImagesSrcs(Eval("pro_id")) %>'>
                                                <ItemTemplate>
                                                    <img src='<%# Container.DataItem %>' class="card-img" alt="Producto" />
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                        <div class="card-body">
                                            <h3 class="card-title"><%# Eval("pro_nombre") %></h3>
                                            <div class="card-provider">
                                                <i class="fa-solid fa-store"></i> <span><%# Eval("tbl_proveedor.prov_nombre") ?? "Ninguno" %></span>
                                            </div>
                                            <div class='<%# GetStockClass(Eval("pro_cantidad")) %>'>
                                                <%# GetStockText(Eval("pro_cantidad")) %>
                                            </div>
                                        </div>
                                        <div class="card-footer">
                                            <div class="price-box">
                                                <span class="price-lbl">Precio unitario</span>
                                                <span class="price-val">
                                                    <%# string.Format(System.Globalization.CultureInfo.GetCultureInfo("en-US"), "${0:N2}", Eval("pro_precio")) %>
                                                </span>
                                            </div>
                                            <a href='DetalleProducto.aspx?id=<%# Eval("pro_id") %>' class="btn-detail" title="Ver Detalles">
                                                <i class="fa-solid fa-chevron-right"></i>
                                            </a>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>

                    <!-- Empty state -->
                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-box-open"></i>
                        <h3>Sin resultados coincidentes</h3>
                        <p>No pudimos encontrar productos que coincidan con sus criterios de filtrado. Intente con otra combinación de búsqueda.</p>
                    </asp:Panel>

                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="txtBuscar" EventName="TextChanged" />
                    <asp:AsyncPostBackTrigger ControlID="ddlProveedor" EventName="SelectedIndexChanged" />
                </Triggers>
            </asp:UpdatePanel>
        </main>
    </form>
</body>
</html>
