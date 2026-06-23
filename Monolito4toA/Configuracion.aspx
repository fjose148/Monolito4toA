<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Configuracion.aspx.cs" Inherits="Monolito4toA.Configuracion" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Configuración del Sistema - Monolito4toA</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --primary: #6366f1;
            --bg-dark: #0f172a;
            --glass-bg: rgba(255, 255, 255, 0.05);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --warning: #f59e0b;
            --danger: #ef4444;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        .config-container {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 40px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header-title {
            text-align: center;
            margin-bottom: 30px;
        }

        .header-title h2 {
            font-size: 32px;
            font-weight: 700;
            color: var(--warning);
        }

        .setting-card {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .setting-info h3 {
            font-size: 18px;
            margin-bottom: 5px;
        }
        .setting-info p {
            color: var(--text-muted);
            font-size: 14px;
        }

        .btn-toggle {
            padding: 12px 24px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-enable {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-disable {
            background-color: var(--primary);
            color: white;
        }

        .btn-back {
            display: block;
            text-align: center;
            margin-top: 30px;
            color: var(--text-muted);
            text-decoration: none;
            font-size: 14px;
            transition: color 0.3s;
        }

        .btn-back:hover {
            color: white;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server"></asp:ScriptManager>
        <div class="config-container">
            <div class="header-title">
                <h2><i class="fa-solid fa-gear"></i> Configuración Avanzada</h2>
                <p style="color: var(--text-muted);">Solo para Administradores</p>
            </div>

            <asp:UpdatePanel ID="upnlConfig" runat="server">
                <ContentTemplate>
                    <div class="setting-card">
                        <div class="setting-info">
                            <h3><i class="fa-solid fa-triangle-exclamation" style="color: var(--warning);"></i> Modo Mantenimiento</h3>
                            <p>Bloquea el acceso a todos los usuarios estándar.</p>
                        </div>
                        <div>
                            <asp:Button ID="btnToggleMantenimiento" runat="server" Text="Activar" CssClass="btn-toggle btn-enable" OnClick="btnToggleMantenimiento_Click" />
                        </div>
                    </div>
                    <div style="text-align: center;">
                        <asp:Label ID="lblStatus" runat="server" Font-Bold="true"></asp:Label>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <a href="Dashboard.aspx" class="btn-back"><i class="fa-solid fa-arrow-left"></i> Volver al Dashboard</a>
        </div>
    </form>
</body>
</html>
