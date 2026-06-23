<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registrar.aspx.cs" Inherits="Monolito4toA.Seguridad.Registrar" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Registro Seguro — Monolito Secure</title>
    <link rel="shortcut icon" href="../favicon.ico?v=2" type="image/x-icon" />
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root {
            --primary: #6366f1;
            --primary-glow: rgba(99, 102, 241, 0.5);
            --secondary: #ec4899;
            --accent: #10b981;
            --bg-dark: #030712;
            --glass: rgba(15, 23, 42, 0.6);
            --border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-dim: #94a3b8;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }

        body {
            background: var(--bg-dark);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            overflow-x: hidden;
            position: relative;
        }

        .blobs {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1;
            filter: blur(80px); opacity: 0.5;
        }
        .blob { position: absolute; width: 600px; height: 600px; border-radius: 50%; animation: move 25s infinite alternate; }
        .blob-1 { background: var(--primary); top: -200px; left: -200px; }
        .blob-2 { background: var(--secondary); bottom: -200px; right: -200px; animation-delay: -7s; }

        @keyframes move { from { transform: translate(0,0) rotate(0deg); } to { transform: translate(150px, 150px) rotate(180deg); } }

        .reg-card {
            width: 100%;
            max-width: 1100px; /* Expansive layout as requested */
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--border);
            border-radius: 40px;
            padding: 60px;
            box-shadow: 0 40px 100px rgba(0, 0, 0, 0.6);
            animation: cardFade 0.8s ease-out;
            position: relative;
            z-index: 10;
        }

        @keyframes cardFade { from { opacity: 0; transform: scale(0.98); } to { opacity: 1; transform: scale(1); } }

        .header { text-align: center; margin-bottom: 50px; }
        .header h1 { font-family: 'Outfit', sans-serif; font-size: 42px; font-weight: 900; background: linear-gradient(to right, #fff, var(--primary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .header p { color: var(--text-dim); font-size: 16px; margin-top: 10px; }

        .content-grid { display: grid; grid-template-columns: 1fr 1.5fr; gap: 60px; }
        @media (max-width: 900px) { .content-grid { grid-template-columns: 1fr; } }

        /* Photo Section */
        .photo-section { text-align: center; }
        .upload-area {
            width: 100%; aspect-ratio: 1; max-width: 320px; margin: 0 auto 30px;
            background: rgba(255,255,255,0.03); border: 3px dashed var(--border);
            border-radius: 32px; display: flex; flex-direction: column; align-items: center; justify-content: center;
            cursor: pointer; transition: 0.4s; position: relative; overflow: hidden;
        }
        .upload-area:hover { border-color: var(--primary); background: rgba(99,102,241,0.08); transform: translateY(-5px); }
        .upload-area i { font-size: 50px; color: var(--primary); margin-bottom: 15px; }
        
        .gallery-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
            gap: 15px; margin-top: 25px;
        }
        .thumb {
            width: 100%; aspect-ratio: 1; border-radius: 12px; object-fit: cover;
            border: 2px solid var(--border); cursor: pointer; transition: 0.3s;
        }
        .thumb:hover { transform: scale(1.1); border-color: var(--primary); z-index: 5; }
        .thumb.selected { border-color: var(--accent); box-shadow: 0 0 15px var(--accent); }

        /* Form Grid */
        .form-layout { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .full-width { grid-column: span 2; }
        @media (max-width: 600px) { .form-layout { grid-template-columns: 1fr; } .full-width { grid-column: span 1; } }

        .field-group { margin-bottom: 5px; }
        .field-group label { display: block; font-size: 12px; font-weight: 800; color: var(--text-dim); text-transform: uppercase; margin-bottom: 10px; letter-spacing: 1px; }
        
        .input-box { position: relative; display: flex; align-items: center; }
        .input-box i:not(.fa-eye):not(.fa-eye-slash) { position: absolute; left: 18px; color: var(--text-dim); transition: 0.3s; z-index: 5; pointer-events: none; }
        .input-box i.fa-eye, .input-box i.fa-eye-slash { position: absolute; right: 15px; color: var(--text-dim); font-size: 18px; cursor: pointer; z-index: 100; padding: 10px; transition: 0.3s; }
        .input-box i.fa-eye:hover { color: var(--primary); }
        .control {
            width: 100%; background: rgba(0,0,0,0.2); border: 2px solid var(--border);
            border-radius: 14px; padding: 14px 50px 14px 50px; color: white; font-size: 15px;
            transition: all 0.3s; position: relative; z-index: 1;
        }
        .control:focus { outline: none; border-color: var(--primary); background: rgba(0,0,0,0.4); box-shadow: 0 0 15px rgba(99, 102, 241, 0.15); }

        /* Password Indicator */
        .strength-wrap { margin-top: 10px; }
        .strength-meter { height: 6px; background: rgba(255,255,255,0.05); border-radius: 10px; overflow: hidden; }
        .strength-bar { height: 100%; width: 0%; transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .strength-label { font-size: 11px; font-weight: 800; color: var(--text-dim); margin-top: 6px; display: block; text-align: right; }

        .btn-register {
            width: 100%; background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white; border: none; border-radius: 18px; padding: 20px;
            font-size: 18px; font-weight: 900; cursor: pointer; transition: all 0.4s;
            box-shadow: 0 15px 35px rgba(99, 102, 241, 0.3);
            margin-top: 20px;
        }
        .btn-register:hover { transform: translateY(-4px); box-shadow: 0 25px 50px rgba(99, 102, 241, 0.5); }

        .footer { text-align: center; margin-top: 35px; font-size: 16px; color: var(--text-dim); }
        .footer a { color: var(--primary); text-decoration: none; font-weight: 800; transition: 0.3s; }
        .footer a:hover { color: var(--secondary); text-shadow: 0 0 10px var(--primary-glow); }

        .alert { padding: 15px; border-radius: 15px; font-size: 14px; font-weight: 600; margin-bottom: 25px; display: flex; align-items: center; gap: 12px; }
        .alert-error { background: rgba(239, 68, 68, 0.15); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.2); }
        .alert-success { background: rgba(16, 185, 129, 0.15); color: #a7f3d0; border: 1px solid rgba(16, 185, 129, 0.2); }
    </style>
</head>
<body>
    <div class="blobs">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
    </div>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" />
        
        <div class="reg-card">
            <div class="header">
                <h1>Únete a <span style="color: var(--primary);">Monolito</span></h1>
                <p>Crea tu identidad digital de alta seguridad en segundos</p>
            </div>

            <asp:UpdatePanel ID="upMsg" runat="server">
                <ContentTemplate>
                    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                        <div id="divAlert" runat="server" class="alert">
                            <i class="fa-solid fa-bell"></i>
                            <asp:Literal ID="litMessage" runat="server" />
                        </div>
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>

            <div class="content-grid">
                <div class="photo-section">
                    <div class="upload-area" style="cursor: default; padding: 20px;">
                        <i class="fa-solid fa-images" style="font-size: 40px; color: var(--primary); margin-bottom: 10px;"></i>
                        <p style="font-weight: 800; color: var(--primary); margin-bottom: 10px;">Fotos del Usuario</p>
                        <asp:FileUpload ID="fuImagen" runat="server" AllowMultiple="true" accept="image/*" style="max-width: 90%; margin: 10px auto; background: rgba(0,0,0,0.2); border: 1px solid var(--border); border-radius: 10px; padding: 6px; color: white;" />
                        <asp:Button ID="btnSubirImagen" runat="server" Text="Cargar Fotos" CssClass="btn-register" OnClick="btnSubirImagen_Click" UseSubmitBehavior="false" style="padding: 10px 20px; font-size: 14px; margin-top: 10px; width: auto; display: inline-block; box-shadow: none;" />
                    </div>

                    <asp:Panel ID="divPreviewsContainer" runat="server" Visible="false" style="margin-top: 20px;">
                        <p style="font-size: 11px; color: var(--text-dim); font-weight: 700; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px;">Haz clic en una imagen para seleccionarla como avatar de perfil principal:</p>
                        <div class="gallery-grid">
                            <asp:Repeater ID="repPreviews" runat="server" OnItemCommand="repPreviews_ItemCommand">
                                <ItemTemplate>
                                    <div style="position: relative; display: inline-block; cursor: pointer; margin-bottom: 10px;">
                                        <asp:ImageButton ID="imgThumb" runat="server" 
                                            ImageUrl='<%# ResolveUrl("~/ImageHandler.ashx?preview=true&idx=" + Eval("Index")) %>' 
                                            CssClass='<%# Convert.ToInt32(Eval("Index")) == Convert.ToInt32(hfSelectedIndex.Value) ? "thumb selected" : "thumb" %>' 
                                            CommandName="SelectProfile" 
                                            CommandArgument='<%# Eval("Index") %>' 
                                            style="width: 80px; height: 80px; object-fit: cover; border-radius: 12px; border: 2px solid var(--border);" />
                                        
                                        <asp:PlaceHolder ID="phCheck" runat="server" Visible='<%# Convert.ToInt32(Eval("Index")) == Convert.ToInt32(hfSelectedIndex.Value) %>'>
                                            <i class="fa-solid fa-circle-check" style="position: absolute; top: 5px; right: 5px; color: var(--accent); background: var(--bg-dark); border-radius: 50%; font-size: 14px;"></i>
                                        </asp:PlaceHolder>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>
                    <asp:HiddenField ID="hfSelectedIndex" runat="server" Value="0" />
                </div>

                <div class="form-section">
                    <div class="form-layout">
                        <div class="field-group">
                            <label>Cédula / ID</label>
                            <div class="input-box">
                                <i class="fa-solid fa-id-badge"></i>
                                <asp:TextBox ID="txtCedula" runat="server" CssClass="control" placeholder="Número de identificación" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Nickname</label>
                            <div class="input-box">
                                <i class="fa-solid fa-at"></i>
                                <asp:TextBox ID="txtNick" runat="server" CssClass="control" placeholder="Nombre de usuario único" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Nombres</label>
                            <div class="input-box">
                                <i class="fa-solid fa-user"></i>
                                <asp:TextBox ID="txtNombres" runat="server" CssClass="control" placeholder="Sus nombres completos" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Apellidos</label>
                            <div class="input-box">
                                <i class="fa-solid fa-signature"></i>
                                <asp:TextBox ID="txtApellidos" runat="server" CssClass="control" placeholder="Sus apellidos completos" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>WhatsApp / Celular</label>
                            <div class="input-box">
                                <i class="fa-brands fa-whatsapp"></i>
                                <asp:TextBox ID="txtCelular" runat="server" CssClass="control" placeholder="Ej: 09XXXXXXXX" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Fecha de Nacimiento</label>
                            <div class="input-box">
                                <i class="fa-solid fa-calendar-day"></i>
                                <asp:TextBox ID="txtFechaCumple" runat="server" CssClass="control" TextMode="Date" />
                            </div>
                        </div>
                        <div class="field-group full-width">
                            <label>Dirección Domiciliaria</label>
                            <div class="input-box">
                                <i class="fa-solid fa-map-location-dot"></i>
                                <asp:TextBox ID="txtDireccion" runat="server" CssClass="control" placeholder="Calle principal, secundaria y referencia" />
                            </div>
                        </div>
                        <div class="field-group full-width">
                            <label>Correo Electrónico Corporativo</label>
                            <div class="input-box">
                                <i class="fa-solid fa-paper-plane"></i>
                                <asp:TextBox ID="txtCorreo" runat="server" CssClass="control" placeholder="usuario@monolito.com" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Contraseña de Seguridad</label>
                            <div class="input-box">
                                <i class="fa-solid fa-shield-halved"></i>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="control" TextMode="Password" onkeyup="checkStrength(this.value)" placeholder="••••••••••••" style="padding-right: 60px !important;" />
                                <i class="fa-solid fa-eye" id="togglePass" style="position: absolute; right: 20px; top: 50%; transform: translateY(-50%); cursor: pointer; color: var(--text-dim); z-index: 100; font-size: 18px; padding: 10px;" onmousedown="event.preventDefault();" onclick="togglePassword('<%= txtPassword.ClientID %>', 'togglePass')"></i>
                            </div>
                            <div class="strength-wrap">
                                <div class="strength-meter"><div id="strength-bar" class="strength-bar"></div></div>
                                <span id="strength-text" class="strength-label">Fuerza insuficiente</span>
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Confirmar Clave</label>
                            <div class="input-box">
                                <i class="fa-solid fa-check-double"></i>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="control" TextMode="Password" placeholder="••••••••••••" style="padding-right: 60px !important;" />
                                <i class="fa-solid fa-eye" id="toggleConfirm" style="position: absolute; right: 20px; top: 50%; transform: translateY(-50%); cursor: pointer; color: var(--text-dim); z-index: 100; font-size: 18px; padding: 10px;" onmousedown="event.preventDefault();" onclick="togglePassword('<%= txtConfirmPassword.ClientID %>', 'toggleConfirm')"></i>
                            </div>
                        </div>
                    </div>

                    <div style="margin-top: 15px; text-align: center;">
                        <asp:Label ID="lblUploadStatus" runat="server" CssClass="strength-label" style="text-align:center; font-size:13px; color:var(--accent);" />
                    </div>

                    <asp:Button ID="btnRegistrar" runat="server" Text="Finalizar Registro Premium" CssClass="btn-register" OnClick="btnRegistrar_Click" />
                    
                    <div class="footer">
                        ¿Ya eres parte de Monolito? <asp:LinkButton ID="lnkLogin" runat="server" OnClick="lnkLogin_Click">Iniciar Sesión</asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        function togglePassword(fieldId, iconId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(iconId);
            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        }

        function checkStrength(p) {
            let s = 0;
            if (p.length > 8) s++;
            if (/[A-Z]/.test(p)) s++;
            if (/[0-9]/.test(p)) s++;
            if (/[^A-Za-z0-9]/.test(p)) s++;

            const bar = document.getElementById('strength-bar');
            const text = document.getElementById('strength-text');
            const colors = ['#ef4444', '#f59e0b', '#3b82f6', '#10b981'];
            const labels = ['Muy Débil', 'Débil', 'Segura', 'Inviolable'];

            bar.style.width = (s * 25) + '%';
            bar.style.backgroundColor = colors[s-1] || 'rgba(255,255,255,0.05)';
            text.innerText = labels[s-1] || 'Fuerza insuficiente';
            text.style.color = colors[s-1] || 'inherit';
        }
    </script>
</body>
</html>
