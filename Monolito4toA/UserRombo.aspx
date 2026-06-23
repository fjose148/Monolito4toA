<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Text" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Rombo Espiral — Monolito</title>
    <meta name="description" content="Generador dinámico de rombo en espiral." />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root {
            --primary: #6366f1;
            --secondary: #ec4899;
            --accent: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --bg-dark: #030712;
            --card-bg: rgba(15, 23, 42, 0.7);
            --border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-dim: #94a3b8;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; overflow-y: auto; position: relative; }
        .blobs { position: fixed; inset: 0; z-index: 0; filter: blur(120px); opacity: 0.3; pointer-events: none; }
        .blob { position: absolute; border-radius: 50%; animation: blobMove 30s infinite alternate; }
        .blob-1 { width: 700px; height: 700px; background: var(--primary); top: -300px; right: -200px; }
        .blob-2 { width: 500px; height: 500px; background: var(--secondary); bottom: -200px; left: -150px; animation-delay: -8s; }
        .blob-3 { width: 400px; height: 400px; background: var(--accent); top: 50%; left: 50%; animation-delay: -15s; }
        @keyframes blobMove { from { transform: translate(0, 0) scale(1); } to { transform: translate(80px, 80px) scale(1.2); } }
        form#form1 { position: relative; z-index: 1; min-height: 100vh; display: flex; flex-direction: column; }
        .page-header { padding: 18px 40px; background: rgba(0, 0, 0, 0.5); display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(20px); position: sticky; top: 0; z-index: 10; }
        .back-btn { color: var(--text-dim); text-decoration: none; font-weight: 800; font-size: 14px; display: flex; align-items: center; gap: 10px; transition: 0.3s; padding: 8px 16px; border-radius: 12px; border: 1px solid var(--border); }
        .back-btn:hover { color: white; border-color: var(--primary); background: rgba(99, 102, 241, 0.1); }
        .page-title { font-family: 'Outfit'; font-size: 22px; font-weight: 900; background: linear-gradient(135deg, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .header-badge { background: rgba(99, 102, 241, 0.15); border: 1px solid rgba(99, 102, 241, 0.3); padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: 800; color: #818cf8; text-transform: uppercase; letter-spacing: 1px; }
        .main-content { flex: 1; padding: 50px 60px; animation: fadeUp 0.8s ease; }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
        .controls-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 32px; padding: 40px; max-width: 700px; margin: 0 auto 50px; backdrop-filter: blur(20px); box-shadow: 0 25px 60px rgba(0, 0, 0, 0.4); }
        .controls-card h1 { font-family: 'Outfit'; font-size: 32px; font-weight: 900; margin-bottom: 8px; letter-spacing: -1px; }
        .controls-card p { color: var(--text-dim); font-size: 15px; font-weight: 500; margin-bottom: 35px; line-height: 1.6; }
        .input-row { display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .input-group { display: flex; flex-direction: column; flex: 1; gap: 8px; }
        .input-group label { font-size: 12px; font-weight: 800; text-transform: uppercase; letter-spacing: 1.5px; color: var(--text-dim); }
        .input-field { background: rgba(255, 255, 255, 0.05); border: 1px solid var(--border); border-radius: 16px; padding: 16px 20px; color: white; font-size: 18px; font-family: 'Outfit'; font-weight: 700; width: 100%; transition: 0.3s; outline: none; }
        .input-field:focus { border-color: var(--primary); background: rgba(99, 102, 241, 0.08); box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15); }
        .input-field::placeholder { color: var(--text-dim); font-size: 14px; }
        .btn-generate { background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white; border: none; padding: 16px 32px; border-radius: 16px; font-weight: 900; font-size: 16px; font-family: 'Plus Jakarta Sans'; cursor: pointer; transition: 0.3s; white-space: nowrap; box-shadow: 0 10px 30px rgba(99, 102, 241, 0.3); display: flex; align-items: center; gap: 10px; }
        .btn-generate:hover { transform: translateY(-3px); box-shadow: 0 15px 40px rgba(99, 102, 241, 0.4); }
        .btn-generate:active { transform: translateY(0); }
        .msg-error { margin-top: 18px; padding: 14px 20px; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.25); border-radius: 14px; color: #fca5a5; font-weight: 700; font-size: 14px; display: flex; align-items: center; gap: 10px; animation: shake 0.4s ease; }
        @keyframes shake { 0%, 100% { transform: translateX(0); } 20%, 60% { transform: translateX(-6px); } 40%, 80% { transform: translateX(6px); } }
        .output-section { max-width: 1200px; margin: 0 auto; }
        .output-label { font-size: 11px; font-weight: 900; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: var(--text-dim); }
        .output-label::after { content: ''; height: 1px; flex: 1; background: var(--border); }
        .dual-panel { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
        .spiral-panel { background: var(--card-bg); border: 1px solid var(--border); border-radius: 28px; padding: 30px; backdrop-filter: blur(20px); transition: 0.4s; min-height: 160px; display: flex; flex-direction: column; }
        .panel-title { font-size: 11px; font-weight: 900; text-transform: uppercase; letter-spacing: 2px; color: var(--text-dim); margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
        .panel-title .dot { width: 8px; height: 8px; border-radius: 50%; }
        .dot-even { background: var(--accent); box-shadow: 0 0 8px var(--accent); }
        .dot-odd { background: var(--secondary); box-shadow: 0 0 8px var(--secondary); }
        .spiral-output { font-family: 'Courier New', Consolas, monospace; font-size: 13px; line-height: 1.5; color: #a5b4fc; white-space: pre; overflow-x: auto; flex: 1; display: flex; align-items: center; justify-content: center; }
        .placeholder-text { color: var(--text-dim); font-family: 'Plus Jakarta Sans'; font-size: 14px; font-weight: 600; font-style: italic; text-align: center; padding: 20px; }
        .info-strip { max-width: 700px; margin: 0 auto 30px; padding: 16px 24px; background: rgba(99, 102, 241, 0.06); border: 1px solid rgba(99, 102, 241, 0.15); border-radius: 18px; display: flex; align-items: center; gap: 15px; font-size: 13px; color: var(--text-dim); font-weight: 600; }
        .info-strip i { color: var(--primary); font-size: 16px; flex-shrink: 0; }
    </style>
</head>
<body>
    <div class="blobs">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
        <div class="blob blob-3"></div>
    </div>

    <form id="form1" runat="server">
        <header class="page-header">
            <a href="Dashboard.aspx" class="back-btn" id="backBtn">
                <i class="fa-solid fa-arrow-left"></i> SALIR
            </a>
            <span class="page-title"><i class="fa-solid fa-diamond"></i> Rombo Espiral</span>
            <span class="header-badge"><i class="fa-solid fa-circle-nodes"></i> Generador</span>
        </header>

        <main class="main-content">
            <div class="controls-card">
                <h1><i class="fa-solid fa-asterisk" style="color:var(--primary); font-size:26px;"></i> Generador de Espiral</h1>
                <p>Ingresa el tamaño del rombo. Valores <strong>pares</strong> se muestran a la izquierda (en espejo), <strong>impares</strong> a la derecha.</p>

                <div class="input-row">
                    <div class="input-group">
                        <label for="txtSegments"><i class="fa-solid fa-sliders"></i> Tamaño del Rombo (2 - 20)</label>
                        <asp:TextBox ID="txtSegments" runat="server" CssClass="input-field" placeholder="Ej: 2, 5, 10..." TextMode="Number" min="2" max="20" required="required" />
                    </div>
                    <asp:Button ID="btnGenerar" runat="server" Text="&#xf0d0;  GENERAR" CssClass="btn-generate" OnClick="btnGenerar_Click" />
                </div>
                <asp:Literal ID="litError" runat="server" />
            </div>

            <div class="info-strip">
                <i class="fa-solid fa-circle-info"></i>
                <span>El espiral crece en diagonal en forma de rombo cerrado, adaptando su tamaño automáticamente para no deformarse.</span>
            </div>

            <div class="output-section">
                <div class="output-label">
                    <i class="fa-solid fa-display" style="color:var(--primary)"></i> Resultado del Rombo Espiral
                </div>
                <div class="dual-panel">
                    <div class="spiral-panel" id="panelEven">
                        <div class="panel-title"><span class="dot dot-even"></span>Tamaños Pares — Izquierda</div>
                        <div class="spiral-output" id="outputEven">
                            <asp:Literal ID="litEvenOutput" runat="server">
                                <span class="placeholder-text">Ingresa un tamaño par para ver el rombo aquí.</span>
                            </asp:Literal>
                        </div>
                    </div>
                    <div class="spiral-panel" id="panelOdd">
                        <div class="panel-title"><span class="dot dot-odd"></span>Tamaños Impares — Derecha</div>
                        <div class="spiral-output" id="outputOdd">
                            <asp:Literal ID="litOddOutput" runat="server">
                                <span class="placeholder-text">Ingresa un tamaño impar para ver el rombo aquí.</span>
                            </asp:Literal>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>

    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UsuarioLogueado"] == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx", false);
                return;
            }

            // Usamos reflexión para obtener la propiedad tusu_id dinámicamente y evitar dependencias directas en la vista
            object user = Session["UsuarioLogueado"];
            var propInfo = user.GetType().GetProperty("tusu_id");
            if (propInfo != null)
            {
                int tusu_id = (int)propInfo.GetValue(user, null);
                if (tusu_id == 1)
                {
                    Response.Redirect("~/Dashboard.aspx", false);
                    return;
                }
            }
        }

        private string GetDynamicPreStyle(int n, bool isEven)
        {
            double fontSize = Math.Max(6.0, 22.0 - (n * 0.7));
            double letterSpacing = Math.Max(0.5, 3.0 - (n * 0.12));
            double lineHeight = Math.Max(1.0, 1.6 - (n * 0.03));
            string color = isEven ? "#a5b4fc" : "#f9a8d4";

            var inv = System.Globalization.CultureInfo.InvariantCulture;
            return string.Format(
                inv,
                "style='font-family: \"Courier New\", Consolas, monospace; font-size: {0:F1}px; line-height: {1:F2}; letter-spacing: {2:F2}px; color: {3};'",
                fontSize, lineHeight, letterSpacing, color
            );
        }

        protected void btnGenerar_Click(object sender, EventArgs e)
        {
            litError.Text = "";
            litEvenOutput.Text = "<span class='placeholder-text'>Ingresa un tamaño par para ver el rombo aquí.</span>";
            litOddOutput.Text = "<span class='placeholder-text'>Ingresa un tamaño impar para ver el rombo aquí.</span>";

            string raw = txtSegments.Text.Trim();
            if (string.IsNullOrEmpty(raw))
            {
                MostrarError("Por favor ingrese un número válido.");
                return;
            }

            if (!int.TryParse(raw, out int n))
            {
                MostrarError("Por favor ingrese un número válido.");
                return;
            }

            if (n < 1 || n > 20)
            {
                MostrarError("Error: El tamaño debe estar entre 1 y 20.");
                return;
            }

            string spiral = GenerarRombo(n);

            if (n % 3 == 0)
            {
                litEvenOutput.Text = "<pre " + GetDynamicPreStyle(n, true) + ">" + Server.HtmlEncode(spiral) + "</pre>";
                litOddOutput.Text = "<span class='placeholder-text'>Panel para tamaños impares.</span>";
            }
            else
            {
                litOddOutput.Text = "<pre " + GetDynamicPreStyle(n, false) + ">" + Server.HtmlEncode(spiral) + "</pre>";
                litEvenOutput.Text = "<span class='placeholder-text'>Panel para tamaños pares.</span>";
            }
        }

        private string GenerarRombo(int n)
        {
            if (n <= 0) return "";
            
            int totalRows = 2 * n - 1;
            string[] fullPattern = new string[totalRows];
            
            int maxX = n - 1;
            int displayWidth = 2 * maxX + 1;
            int center =  maxX;
            
            char[][] grid = new char[totalRows][];
            for (int row = 0; row < totalRows; row++)
            {
                grid[row] = new char[displayWidth];
                for (int col = 0; col < displayWidth; col++) grid[row][col] = ' ';
            }

            Action<int, int> plot = (px, py) => {
                int row = (n - 1) - py;
                int col = (n % 2 == 0) ? center + px : center - px;
                if (row >= 0 && row < totalRows && col >= 0 && col < displayWidth) {
                    grid[row][col] = '*';
                }
            };

            int x = -n + 1;
            int y = 0;
            int N = n - 1;
            
            int lenDR = N;
            int lenUR = N;
            int lenUL = N;
            int lenDL = N - 2;

            while (true)
            {
                if (lenDR <= 0) break;
                for (int i = 0; i < lenDR; i++) { plot(x, y); x++; y--; }
                
                if (lenUR <= 0) break;
                for (int i = 0; i < lenUR; i++) { plot(x, y); x++; y++; }
                
                if (lenUL <= 0) break;
                for (int i = 0; i < lenUL; i++) { plot(x, y); x--; y++; }
                
                if (lenDL <= 0) break;
                for (int i = 0; i < lenDL; i++) { plot(x, y); x--; y--; }
                
                lenDR = lenDL;
                lenUR -= 4;
                lenUL -= 4;
                lenDL -= 4;
            }

            for (int row = 0; row < totalRows; row++)
            {
                fullPattern[row] = new string(grid[row]).TrimEnd();
            }
            
            return BuildDiamondFrameFull(fullPattern);
        }

        private string BuildDiamondFrameFull(string[] fullPattern)
        {
            int maxLength = 0;
            foreach (var s in fullPattern) if (s != null && s.Length > maxLength) maxLength = s.Length;
            
            int innerWidth = maxLength + 1; 
            
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("╔").Append(new string('═', innerWidth)).AppendLine("╗");
            
            for (int i = 0; i < fullPattern.Length; i++)
            {
                sb.Append("║ ").Append((fullPattern[i] ?? "").PadRight(innerWidth - 2)).AppendLine(" ║");
            }
            
            sb.Append("╚").Append(new string('═', innerWidth)).AppendLine("╝");
            
            return sb.ToString();
        }

        private void MostrarError(string mensaje)
        {
            litError.Text = "<div class='msg-error'><i class='fa-solid fa-triangle-exclamation'></i> " + Server.HtmlEncode(mensaje) + "</div>";
        }
    </script>
</body>
</html>