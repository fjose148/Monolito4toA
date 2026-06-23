<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OAuthCallback.aspx.cs" Inherits="Monolito4toA.Seguridad.OAuthCallback" Async="true" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Autenticando...</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background: #0f172a; color: white; margin: 0; }
        .loader { border: 4px solid rgba(255, 255, 255, 0.1); border-top: 4px solid #6366f1; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto 20px; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .container { text-align: center; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="loader"></div>
            <h2>Procesando autenticación...</h2>
            <p style="color: #94a3b8;">Por favor, no cierres esta ventana.</p>
        </div>
    </form>
</body>
</html>
