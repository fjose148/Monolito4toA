<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Perfil.aspx.cs" Inherits="Monolito4toA.Perfil" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mi Perfil — Monolito Secure</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --bg-dark: #030712; --card-bg: rgba(15, 23, 42, 0.7); --border: rgba(255, 255, 255, 0.1); --text-main: #f8fafc; --text-dim: #94a3b8; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; overflow-x: hidden; position: relative; }
        
        /* Blobs like Dashboard */
        .blobs { position: fixed; inset: 0; z-index: -1; filter: blur(100px); opacity: 0.3; }
        .blob { position: absolute; border-radius: 50%; animation: move 20s infinite alternate; }
        .blob-1 { width: 500px; height: 500px; background: var(--primary); top: -100px; left: -100px; }
        .blob-2 { width: 400px; height: 400px; background: var(--secondary); bottom: -100px; right: -100px; }
        @keyframes move { from { transform: translate(0, 0); } to { transform: translate(100px, 100px); } }

        .container { max-width: 700px; margin: 40px auto; padding: 20px; }
        
        .profile-card {
            background: var(--card-bg); backdrop-filter: blur(25px);
            border: 1px solid var(--border); border-radius: 32px;
            overflow: hidden; box-shadow: 0 40px 80px rgba(0,0,0,0.6);
            animation: cardIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes cardIn { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }

        .banner {
            height: 180px; background: linear-gradient(135deg, var(--primary), var(--secondary));
            position: relative; overflow: hidden;
        }
        .banner::before { content: ''; position: absolute; inset: 0; background: url('https://www.transparenttextures.com/patterns/cubes.png'); opacity: 0.1; }
        .banner-glow { position: absolute; width: 250px; height: 250px; background: white; filter: blur(120px); opacity: 0.2; top: -40px; left: -40px; animation: glowMove 10s infinite alternate; }
        @keyframes glowMove { from { transform: translate(0,0); } to { transform: translate(250px, 80px); } }

        .avatar-section { display: flex; flex-direction: column; align-items: center; margin-top: -90px; position: relative; z-index: 5; }
        .profile-img-wrap {
            width: 180px; height: 180px; border-radius: 50%;
            border: 6px solid var(--bg-dark); background: var(--bg-dark);
            box-shadow: 0 0 40px rgba(99, 102, 241, 0.4);
            overflow: hidden; margin-bottom: 20px; position: relative;
        }
        .profile-img-wrap::after { content: ''; position: absolute; inset: 0; border-radius: 50%; box-shadow: inset 0 0 20px rgba(0,0,0,0.5); }
        .profile-img { width: 100%; height: 100%; object-fit: cover; }

        .user-header { text-align: center; margin-bottom: 45px; }
        .user-header h1 { font-family: 'Outfit'; font-size: 42px; font-weight: 900; letter-spacing: -1px; }
        .user-header p { color: var(--primary); font-weight: 800; text-transform: uppercase; letter-spacing: 3px; font-size: 13px; margin-top: 8px; }

        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; padding: 45px; border-top: 1px solid var(--border); }
        @media (max-width: 768px) { .info-grid { grid-template-columns: 1fr; } }

        .info-item {
            display: flex; gap: 20px; align-items: center; padding: 25px;
            background: rgba(255,255,255,0.02); border-radius: 25px;
            border: 1px solid var(--border); transition: 0.4s;
        }
        .info-item:hover { transform: translateY(-8px); background: rgba(255,255,255,0.05); border-color: var(--primary); box-shadow: 0 15px 30px rgba(0,0,0,0.3); }
        
        .info-icon {
            width: 55px; height: 55px; border-radius: 18px;
            background: rgba(99, 102, 241, 0.1); color: var(--primary);
            display: flex; align-items: center; justify-content: center; font-size: 22px; transition: 0.3s;
        }
        .info-item:hover .info-icon { background: var(--primary); color: white; transform: rotate(10deg); }

        .info-content label { display: block; font-size: 11px; font-weight: 800; color: var(--text-dim); text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 5px; }
        .info-content span { font-size: 17px; font-weight: 700; color: white; }

        .actions { padding: 40px; display: flex; gap: 15px; justify-content: center; background: rgba(0,0,0,0.2); }
        .btn { padding: 16px 35px; border-radius: 18px; font-weight: 800; font-size: 15px; cursor: pointer; transition: 0.3s; display: flex; align-items: center; gap: 12px; border: none; }
        .btn-primary { background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white; box-shadow: 0 10px 25px rgba(99, 102, 241, 0.3); }
        .btn-primary:hover { transform: translateY(-3px) scale(1.05); box-shadow: 0 20px 40px rgba(99, 102, 241, 0.5); }
        .btn-outline { background: transparent; border: 2px solid var(--border); color: white; }
        .btn-outline:hover { background: rgba(255,255,255,0.05); border-color: var(--primary); }

        .edit-input { width: 100%; background: rgba(0,0,0,0.3); border: 2px solid var(--border); border-radius: 14px; padding: 14px; color: white; font-weight: 600; transition: 0.3s; }
        .edit-input:focus { border-color: var(--primary); outline: none; background: rgba(0,0,0,0.5); }
    </style>
    <script>
        function preventBack() { window.history.forward(); }
        setTimeout("preventBack()", 0);
        window.onunload = function () { null };
    </script>
</head>
<body onload="preventBack()">
    <div class="blobs"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>
    <form id="form1" runat="server">
        <div class="container">
            <div style="margin-bottom:30px; display:flex; justify-content:space-between; align-items:center;">
                <a href="Dashboard.aspx" style="color:var(--text-dim); text-decoration:none; font-weight:800; display:flex; align-items:center; gap:10px; transition:0.3s;" class="back-link">
                    <i class="fa-solid fa-chevron-left"></i> Volver al Panel
                </a>
                <div style="font-family:'Outfit'; font-weight:900; font-size:20px; color:var(--primary);">MONOLITO<span style="color:white">SECURE</span></div>
            </div>

            <div class="profile-card">
                <div class="banner"><div class="banner-glow"></div></div>
                
                <div class="avatar-section">
                    <div class="profile-img-wrap">
                        <asp:Image ID="imgPerfil" runat="server" CssClass="profile-img" onerror="this.src='Content/Images/default-avatar.png'" />
                    </div>
                    <div class="user-header">
                        <h1><asp:Literal ID="lblFullNombre" runat="server" /></h1>
                        <p><asp:Literal ID="lblRol" runat="server" /></p>
                    </div>
                </div>

                <asp:MultiView ID="mvPerfil" runat="server" ActiveViewIndex="0">
                    <asp:View ID="vwDetalle" runat="server">
                        <div class="info-grid">
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-id-card"></i></div><div class="info-content"><label>Cédula</label><span><asp:Literal ID="lblCedula" runat="server" /></span></div></div>
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-at"></i></div><div class="info-content"><label>Nickname</label><span>@<asp:Literal ID="lblNick" runat="server" /></span></div></div>
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-envelope"></i></div><div class="info-content"><label>Correo</label><span><asp:Literal ID="lblCorreo" runat="server" /></span></div></div>
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-mobile-screen"></i></div><div class="info-content"><label>Celular</label><span><asp:Literal ID="lblCelular" runat="server" /></span></div></div>
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-cake-candles"></i></div><div class="info-content"><label>Nacimiento</label><span><asp:Literal ID="lblFechaNac" runat="server" /></span></div></div>
                            <div class="info-item"><div class="info-icon"><i class="fa-solid fa-location-dot"></i></div><div class="info-content"><label>Dirección</label><span><asp:Literal ID="lblDireccion" runat="server" /></span></div></div>
                        </div>

                        <!-- QR Authentication Section -->
                        <div style="margin:0 45px 45px; padding:35px; background:rgba(99,102,241,0.05); border:1px solid rgba(99,102,241,0.2); border-radius:30px; display:flex; align-items:center; gap:35px;">
                            <div style="background:white; padding:15px; border-radius:20px; box-shadow:0 15px 40px rgba(0,0,0,0.4);">
                                <asp:Image ID="imgQR" runat="server" style="width:150px; height:150px;" />
                            </div>
                            <div style="flex:1;">
                                <h3 style="font-family:'Outfit'; font-size:22px; margin-bottom:10px;">Llave de Acceso QR</h3>
                                <p style="font-size:13px; color:var(--text-dim); margin-bottom:20px; line-height:1.5;">Esta es tu llave digital única. Úsala para iniciar sesión de forma instantánea desde dispositivos autorizados.</p>
                                <asp:Button ID="btnRegenQR" runat="server" Text="Regenerar Llave Segura" CssClass="btn btn-outline" style="padding:10px 20px; font-size:12px;" OnClick="btnRegenQR_Click" />
                            </div>
                        </div>

                        <div class="actions">
                            <asp:Button ID="btnEditar" runat="server" Text="Actualizar Identidad" CssClass="btn btn-primary" OnClick="btnEditar_Click" />
                        </div>
                    </asp:View>

                    <asp:View ID="vwEditar" runat="server">
                        <div class="info-grid">
                             <div class="info-item" style="grid-column: 1 / -1; background:rgba(99, 102, 241, 0.05);">
                                 <div class="info-content" style="width:100%">
                                     <label>Actualizar Fotografía</label>
                                     <div style="display:flex; align-items:center; gap:20px; margin-top:15px; flex-wrap:wrap;">
                                         <asp:FileUpload ID="fuPerfil" runat="server" accept="image/*" style="background: rgba(0,0,0,0.2); border: 1px solid var(--border); border-radius: 10px; padding: 6px; color: white;" />
                                         <asp:Button ID="btnSubirPerfil" runat="server" Text="Cargar Imagen" CssClass="btn btn-outline" style="padding:10px 20px; font-size:13px;" OnClick="btnSubirPerfil_Click" UseSubmitBehavior="false" />
                                         <asp:Label ID="lblImgStatus" runat="server" style="font-size:12px; font-weight:800;" />
                                     </div>
                                 </div>
                             </div>
                            <div class="info-item"><div class="info-content" style="width:100%"><label>Nombres</label><asp:TextBox ID="txtEditNombres" runat="server" CssClass="edit-input" /></div></div>
                            <div class="info-item"><div class="info-content" style="width:100%"><label>Apellidos</label><asp:TextBox ID="txtEditApellidos" runat="server" CssClass="edit-input" /></div></div>
                            <div class="info-item"><div class="info-content" style="width:100%"><label>Celular</label><asp:TextBox ID="txtEditCelular" runat="server" CssClass="edit-input" /></div></div>
                            <div class="info-item"><div class="info-content" style="width:100%"><label>Dirección</label><asp:TextBox ID="txtEditDireccion" runat="server" CssClass="edit-input" /></div></div>
                        </div>
                        <div class="actions">
                            <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cambios" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline" OnClick="btnCancelar_Click" />
                        </div>
                    </asp:View>
                </asp:MultiView>
            </div>
        </div>
    </form>
</body>
</html>
