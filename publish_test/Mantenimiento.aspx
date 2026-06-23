<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Mantenimiento.aspx.cs" Inherits="Monolito4toA.Mantenimiento" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Gestión de Mantenimiento — Monolito</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --bg: #050811; --card: #0f172a; --primary: #6366f1; --border: rgba(255,255,255,0.08); }
        body { background: var(--bg); color: white; font-family: 'Plus Jakarta Sans', sans-serif; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .card { width: 100%; max-width: 450px; background: var(--card); border: 1px solid var(--border); border-radius: 20px; padding: 40px; text-align: center; }
        .icon { font-size: 50px; color: var(--primary); margin-bottom: 20px; }
        h1 { font-size: 24px; margin-bottom: 10px; }
        p { color: #64748b; font-size: 14px; margin-bottom: 30px; }
        .status-box { padding: 20px; border-radius: 12px; margin-bottom: 30px; font-weight: 800; font-size: 18px; }
        .status-on { background: rgba(239,68,68,0.1); color: #ef4444; border: 1px solid rgba(239,68,68,0.2); }
        .status-off { background: rgba(16,185,129,0.1); color: #10b981; border: 1px solid rgba(16,185,129,0.2); }
        .btn { width: 100%; padding: 15px; border-radius: 10px; border: none; font-weight: 700; cursor: pointer; transition: 0.3s; margin-bottom: 15px; }
        .btn-toggle { background: var(--primary); color: white; }
        .btn-back { background: transparent; color: #64748b; border: 1px solid var(--border); }
        .btn:hover { transform: translateY(-2px); opacity: 0.9; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <div class="icon"><i class="fa-solid fa-screwdriver-wrench"></i></div>
            <h1>Estado del Sistema</h1>
            <p>Controla el acceso global de los usuarios estándar durante actualizaciones.</p>
            
            <div id="divStatus" runat="server" class="status-box">
                <asp:Literal ID="litStatus" runat="server" />
            </div>

            <asp:Button ID="btnToggle" runat="server" OnClick="btnToggle_Click" CssClass="btn btn-toggle" />
            <a href="Dashboard.aspx" class="btn btn-back" style="display:block; text-decoration:none;">Volver al Dashboard</a>
        </div>
    </form>
</body>
</html>
