<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DetalleProducto.aspx.cs" Inherits="Monolito4toA.DetalleProducto" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Detalles del Producto — Monolito Secure</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        .top-bar { display: flex; align-items: center; gap: 20px; margin-bottom: 30px; }
        
        /* Back button */
        .btn-back { width: 50px; height: 50px; background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 16px; color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; text-decoration: none; transition: 0.3s; }
        .btn-back:hover { background: rgba(255,255,255,0.08); transform: translateX(-3px); }

        .title-area h1 { font-family: 'Outfit'; font-size: 34px; font-weight: 900; letter-spacing: -1px; }
        .title-area p { color: var(--text-dim); margin-top: 2px; }

        /* Grid Detail Layout */
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-bottom: 40px; }

        /* Carousel Section */
        .carousel-outer { position: relative; }
        .carousel-container { display: flex; overflow-x: auto; scroll-snap-type: x mandatory; scrollbar-width: none; border-radius: 28px; border: 1px solid var(--border); aspect-ratio: 4/3; background: #070a13; }
        .carousel-container::-webkit-scrollbar { display: none; }
        .carousel-slide { min-width: 100%; scroll-snap-align: start; position: relative; }
        .carousel-slide img { width: 100%; height: 100%; object-fit: cover; }
        .carousel-tip { position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); background: rgba(3, 7, 18, 0.75); border: 1px solid var(--border); padding: 6px 16px; border-radius: 50px; font-size: 11px; font-weight: 700; display: flex; align-items: center; gap: 8px; backdrop-filter: blur(10px); color: var(--text-dim); }

        /* Info Panel */
        .info-panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 40px; backdrop-filter: blur(20px); display: flex; flex-direction: column; justify-content: space-between; }
        .info-header { margin-bottom: 25px; }
        .category-pill { display: inline-block; padding: 6px 14px; background: rgba(99, 102, 241, 0.15); border: 1px solid rgba(99, 102, 241, 0.2); color: #a5b4fc; font-weight: 800; border-radius: 12px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 15px; }
        .prod-name { font-family: 'Outfit'; font-size: 32px; font-weight: 800; color: white; line-height: 1.2; margin-bottom: 10px; }
        .prod-provider { font-size: 14px; color: var(--text-dim); display: flex; align-items: center; gap: 8px; }
        .prod-provider i { color: var(--primary); }

        .info-body { border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); padding: 30px 0; margin: 25px 0; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .stat-block { display: flex; flex-direction: column; }
        .stat-label { font-size: 11px; text-transform: uppercase; color: var(--text-dim); font-weight: 800; letter-spacing: 1px; margin-bottom: 5px; }
        .stat-value { font-family: 'Outfit'; font-size: 26px; font-weight: 900; }
        .stat-value.price { color: var(--accent); }

        .stock-tag { display: inline-block; padding: 5px 12px; border-radius: 8px; font-size: 12px; font-weight: 800; text-transform: uppercase; margin-top: 5px; }
        .stock-tag-ok { background: rgba(16, 185, 129, 0.15); color: #34d399; }
        .stock-tag-low { background: rgba(245, 158, 11, 0.15); color: #fbbf24; }
        .stock-tag-out { background: rgba(239, 68, 68, 0.15); color: #f87171; }

        /* Charts Section */
        .charts-row { display: grid; grid-template-columns: 1.4fr 1fr; gap: 30px; }
        .chart-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 30px; padding: 30px; backdrop-filter: blur(20px); }
        .chart-title { font-family: 'Outfit'; font-size: 18px; font-weight: 800; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .chart-title i { color: var(--primary); }
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
                <a href="Catalogo.aspx" class="btn-back" title="Volver al Catálogo"><i class="fa-solid fa-arrow-left"></i></a>
                <div class="title-area">
                    <h1>Detalles Técnicos & Analíticas</h1>
                    <p>Visualice las imágenes cargadas y estadísticas de posicionamiento comercial del producto.</p>
                </div>
            </header>

            <asp:Literal ID="litMsg" runat="server" />

            <asp:Panel ID="pnlContent" runat="server">
                <div class="details-grid">
                    <!-- Carousel Outer Container -->
                    <div class="carousel-outer">
                        <div class="carousel-container">
                            <asp:Repeater ID="repCarousel" runat="server">
                                <ItemTemplate>
                                    <div class="carousel-slide">
                                        <img src='<%# ResolveUrl("~/ImageHandler.ashx?path_id=" + Eval("path_id")) %>' alt="Imagen del Producto" />
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Panel ID="pnlNoImages" runat="server" CssClass="carousel-slide" Visible="false">
                                <img src='<%= ResolveUrl("~/Imagenes/default.jpg") %>' alt="Sin Imagen" />
                            </asp:Panel>
                        </div>
                        <div class="carousel-tip">
                            <i class="fa-solid fa-angles-left"></i> Deslice para ver más fotos <i class="fa-solid fa-angles-right"></i>
                        </div>
                    </div>

                    <!-- Ficha Técnica Box -->
                    <div class="info-panel">
                        <div class="info-header">
                            <span class="category-pill"><asp:Literal ID="litCategoria" runat="server" /></span>
                            <h2 class="prod-name"><asp:Literal ID="litNombre" runat="server" /></h2>
                            <div class="prod-provider">
                                <i class="fa-solid fa-store"></i> <span>Proveedor: <asp:Literal ID="litProveedor" runat="server" /></span>
                            </div>
                        </div>

                        <div class="info-body">
                            <div class="stat-block">
                                <span class="stat-label">Precio al Público</span>
                                <span class="stat-value price"><asp:Literal ID="litPrecio" runat="server" /></span>
                            </div>
                            <div class="stat-block">
                                <span class="stat-label">Estado de Inventario</span>
                                <span class="stat-value"><asp:Literal ID="litStock" runat="server" /></span>
                                <div>
                                    <asp:Literal ID="litStockBadge" runat="server" />
                                </div>
                            </div>
                        </div>

                        <div style="font-size: 13px; color: var(--text-dim); line-height: 1.5;">
                            <i class="fa-solid fa-shield-halved" style="color:var(--primary); margin-right: 8px;"></i>
                            Garantía del Fabricante y certificación de autenticidad gestionada bajo protocolos de Monolito Secure.
                        </div>
                    </div>
                </div>

                <!-- Stats Dashboard Grid with Charts -->
                <div class="charts-row">
                    <!-- Price Stats Chart (Bar) -->
                    <div class="chart-card">
                        <div class="chart-title"><i class="fa-solid fa-chart-simple"></i> Análisis de Precio de Mercado</div>
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="chartPrice"></canvas>
                        </div>
                    </div>

                    <!-- Inventory Health Chart (Doughnut) -->
                    <div class="chart-card">
                        <div class="chart-title"><i class="fa-solid fa-chart-pie"></i> Salud de Inventario (Target 100 uds)</div>
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="chartStock"></canvas>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </main>
    </form>

    <script type="text/javascript">
        // Data injected from code-behind
        var priceLabels = <%= ChartLabelsJson %>;
        var priceData = <%= ChartPriceDataJson %>;
        
        var stockCurrent = <%= StockCurrent %>;
        var stockRemaining = <%= StockRemaining %>;

        document.addEventListener("DOMContentLoaded", function() {
            try {
                // Render Price Chart
                var ctxPriceElem = document.getElementById('chartPrice');
                if (ctxPriceElem) {
                    var ctxPrice = ctxPriceElem.getContext('2d');
                    var priceChart = new Chart(ctxPrice, {
                        type: 'bar',
                        data: {
                            labels: priceLabels,
                            datasets: [{
                                label: 'Precio ($ USD)',
                                data: priceData,
                                backgroundColor: [
                                    'rgba(99, 102, 241, 0.75)', // primary
                                    'rgba(148, 163, 184, 0.5)',  // dim
                                    'rgba(16, 185, 129, 0.65)',  // accent
                                    'rgba(239, 68, 68, 0.65)'    // danger
                                ],
                                borderColor: [
                                    '#6366f1',
                                    '#94a3b8',
                                    '#10b981',
                                    '#ef4444'
                                ],
                                borderWidth: 2,
                                borderRadius: 12
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { display: false }
                            },
                            scales: {
                                y: {
                                    grid: { color: 'rgba(255, 255, 255, 0.05)' },
                                    ticks: { color: '#94a3b8', font: { family: 'Plus Jakarta Sans', weight: 'bold' } }
                                },
                                x: {
                                    grid: { display: false },
                                    ticks: { color: '#f8fafc', font: { family: 'Plus Jakarta Sans', weight: 'bold' } }
                                }
                            }
                        }
                    });
                }
            } catch(e) { console.error("Error loading Price Chart:", e); }

            try {
                // Render Stock Chart
                var ctxStockElem = document.getElementById('chartStock');
                if (ctxStockElem) {
                    var ctxStock = ctxStockElem.getContext('2d');
                    var stockChart = new Chart(ctxStock, {
                        type: 'doughnut',
                        data: {
                            labels: ['Stock Actual', 'Faltante para Meta (100)'],
                            datasets: [{
                                data: [stockCurrent, stockRemaining],
                                backgroundColor: [
                                    stockCurrent < 5 ? 'rgba(239, 68, 68, 0.75)' : 'rgba(16, 185, 129, 0.75)',
                                    'rgba(255, 255, 255, 0.05)'
                                ],
                                borderColor: [
                                    stockCurrent < 5 ? '#ef4444' : '#10b981',
                                    'rgba(255, 255, 255, 0.1)'
                                ],
                                borderWidth: 2
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: { color: '#f8fafc', font: { family: 'Plus Jakarta Sans', weight: 'bold' } }
                                }
                            },
                            cutout: '70%'
                        }
                    });
                }
            } catch(e) { console.error("Error loading Stock Chart:", e); }

            try {
                // Auto-play Carousel script (changes slide every 3 seconds)
                var container = document.querySelector('.carousel-container');
                if (container) {
                    var slides = container.querySelectorAll('.carousel-slide');
                    if (slides.length > 1) {
                        var currentIndex = 0;
                        var intervalTime = 3000; // Change image every 3 seconds
                        var intervalId = setInterval(nextSlide, intervalTime);

                        function nextSlide() {
                            currentIndex = (currentIndex + 1) % slides.length;
                            var slideWidth = container.clientWidth;
                            container.scrollTo({
                                left: currentIndex * slideWidth,
                                behavior: 'smooth'
                            });
                        }

                        // Removed pause on hover so it forces autoplay always
                        
                        // Sync active slide index if the user scrolls manually
                        var isScrolling;
                        container.addEventListener('scroll', function() {
                            window.clearTimeout(isScrolling);
                            isScrolling = setTimeout(function() {
                                var slideWidth = container.clientWidth;
                                if (slideWidth > 0) {
                                    currentIndex = Math.round(container.scrollLeft / slideWidth);
                                }
                            }, 66);
                        });
                    }
                }
            } catch(e) { console.error("Error loading Carousel:", e); }
        });
    </script>
</body>
</html>
