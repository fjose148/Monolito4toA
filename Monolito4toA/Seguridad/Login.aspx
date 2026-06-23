<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Monolito4toA.Seguridad.Login" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Acceso Seguro — Monolito Secure</title>
    <link rel="shortcut icon" href="../favicon.ico?v=2" type="image/x-icon" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <script src="https://unpkg.com/html5-qrcode"></script>
    <style>
        :root { --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --bg-dark: #030712; --glass: rgba(15, 23, 42, 0.7); --border: rgba(255, 255, 255, 0.1); --text-main: #f8fafc; --text-dim: #94a3b8; }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background: var(--bg-dark); color: var(--text-main); min-height: 100vh; display: flex; align-items: center; justify-content: center; overflow-y: auto; padding: 40px 20px; position: relative; }
        
        /* Animated Background */
        .blobs { position: fixed; inset: 0; z-index: -1; filter: blur(100px); opacity: 0.5; overflow: hidden; }
        .blob { position: absolute; width: 600px; height: 600px; border-radius: 50%; animation: move 20s infinite alternate; }
        .blob-1 { background: var(--primary); top: -200px; left: -200px; animation-delay: 0s; }
        .blob-2 { background: var(--secondary); bottom: -200px; right: -200px; animation-delay: -5s; }
        .blob-3 { background: var(--accent); top: 50%; left: 50%; width: 400px; height: 400px; opacity: 0.3; animation-delay: -10s; }
        @keyframes move { from { transform: translate(0, 0) scale(1); } to { transform: translate(100px, 100px) scale(1.2); } }

        .login-card { width: 100%; max-width: 460px; background: var(--glass); backdrop-filter: blur(25px); border: 1px solid var(--border); border-radius: 40px; padding: 50px; box-shadow: 0 40px 120px rgba(0,0,0,0.6); animation: slideUp 0.8s cubic-bezier(0.16, 1, 0.3, 1); }
        @keyframes slideUp { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }

        .header { text-align: center; margin-bottom: 40px; }
        .header h1 { font-family: 'Outfit'; font-size: 36px; font-weight: 900; letter-spacing: -1px; margin-bottom: 10px; }
        .header p { color: var(--text-dim); font-size: 14px; font-weight: 500; }

        .input-group { margin-bottom: 25px; position: relative; }
        .input-group label { display: block; font-size: 12px; font-weight: 800; color: var(--text-dim); text-transform: uppercase; margin-bottom: 10px; letter-spacing: 1px; transition: 0.3s; }
        .input-wrapper { position: relative; display: flex; align-items: center; }
        .input-wrapper i.fa-lock, .input-wrapper i.fa-user-shield { position: absolute; left: 20px; color: var(--text-dim); font-size: 18px; z-index: 5; pointer-events: none; }
        .input-wrapper i.fa-eye, .input-wrapper i.fa-eye-slash { position: absolute; right: 15px; color: var(--text-dim); font-size: 18px; cursor: pointer; z-index: 100; padding: 10px; transition: 0.3s; }
        .input-wrapper i.fa-eye:hover { color: var(--primary); }
        .control { width: 100%; background: rgba(0,0,0,0.4); border: 2px solid var(--border); border-radius: 18px; padding: 18px 50px 18px 55px; color: white; font-size: 15px; font-weight: 500; transition: 0.3s; position: relative; z-index: 1; }
        .control:focus { border-color: var(--primary); outline: none; background: rgba(0,0,0,0.6); box-shadow: 0 0 20px rgba(99, 102, 241, 0.2); }

        .btn-login { width: 100%; background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white; border: none; border-radius: 18px; padding: 18px; font-size: 16px; font-weight: 800; cursor: pointer; transition: 0.4s; box-shadow: 0 15px 35px rgba(99, 102, 241, 0.3); margin-top: 10px; }
        .btn-login:hover { transform: translateY(-3px) scale(1.02); box-shadow: 0 25px 50px rgba(99, 102, 241, 0.5); }
        .btn-login:active { transform: translateY(-1px); }

        .social-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 30px; }
        .btn-social { background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 16px; padding: 15px; color: white; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 14px; font-weight: 700; transition: 0.3s; }
        .btn-social:hover { background: rgba(255,255,255,0.08); border-color: var(--primary); transform: translateY(-2px); }

        .extra-links { display: flex; justify-content: space-between; align-items: center; margin: 20px 0; font-size: 14px; }
        .extra-links a, .extra-links span { color: var(--text-dim); text-decoration: none; font-weight: 700; cursor: pointer; transition: 0.3s; }
        .extra-links a:hover { color: var(--primary); }

        .qr-trigger { margin-top: 30px; text-align: center; padding-top: 30px; border-top: 1px solid var(--border); }
        .btn-qr { background: rgba(99, 102, 241, 0.1); color: var(--primary); border: 1px solid rgba(99, 102, 241, 0.3); padding: 12px 25px; border-radius: 15px; font-weight: 800; cursor: pointer; transition: 0.3s; display: inline-flex; align-items: center; gap: 10px; }
        .btn-qr:hover { background: var(--primary); color: white; transform: scale(1.05); }

        .alert { padding: 15px; border-radius: 16px; margin-bottom: 25px; font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 12px; animation: shake 0.5s ease; }
        .alert-error { background: rgba(239,68,68,0.15); color: #fca5a5; border: 1px solid rgba(239,68,68,0.3); }
        @keyframes shake { 0%, 100% { transform: translateX(0); } 25% { transform: translateX(-5px); } 75% { transform: translateX(5px); } }

        /* Modal QR Moderno */
        #qrModal { display: none; position: fixed; inset: 0; background: rgba(3, 7, 18, 0.95); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(15px); }
        .modal-content { background: #0f172a; border: 1px solid var(--border); border-radius: 32px; padding: 40px; width: 95%; max-width: 440px; text-align: center; }
        #reader { width: 100%; border-radius: 20px; overflow: hidden; margin: 20px 0; border: 4px solid var(--primary); }

        /* Custom Checkbox */
        .checkbox-container { display: flex; align-items: center; gap: 10px; cursor: pointer; color: var(--text-dim); font-weight: 700; }
        .checkbox-container input { display: none; }
        .custom-check { width: 22px; height: 22px; border: 2px solid var(--border); border-radius: 6px; display: flex; align-items: center; justify-content: center; transition: 0.3s; }
        .checkbox-container input:checked + .custom-check { background: var(--primary); border-color: var(--primary); }
        .checkbox-container input:checked + .custom-check::after { content: '\f00c'; font-family: 'Font Awesome 6 Free'; font-weight: 900; color: white; font-size: 12px; }
    </style>
</head>
<body>
    <div class="blobs"><div class="blob blob-1"></div><div class="blob blob-2"></div><div class="blob blob-3"></div></div>
    <form id="form1" runat="server" autocomplete="off">
        <asp:ScriptManager runat="server" />
        <div id="qrModal">
            <div class="modal-content">
                <h2 style="font-family:'Outfit'; font-weight:900; margin-bottom:10px;">Acceso Biométrico QR</h2>
                <p id="qrStatus" style="color:var(--text-dim); margin-bottom:20px;">Escanea tu llave personal de Monolito</p>
                <div id="reader"></div>
                <div id="qrHashBox" style="display:none; background:rgba(255,255,255,0.05); padding:15px; border-radius:12px; margin-top:15px; word-break:break-all; font-family:monospace; font-size:10px; color:var(--accent);">
                    <span style="display:block; font-weight:800; margin-bottom:5px; color:white;">HASH CIFRADO DETECTADO:</span>
                    <span id="qrHashVal"></span>
                </div>
                <button type="button" onclick="closeScanner()" style="width:100%; margin-top:20px; background:rgba(255,255,255,0.05); border:1px solid var(--border); color:white; padding:15px; border-radius:15px; cursor:pointer; font-weight:800;">Cancelar Proceso</button>
                <asp:HiddenField ID="hfQRToken" runat="server" />
                <asp:Button ID="btnQRLogin" runat="server" OnClick="btnQRLogin_Click" style="display:none;" />
            </div>
        </div>

        <div class="login-card">
            <asp:UpdatePanel ID="upMsg" runat="server">
                <ContentTemplate>
                    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                        <div id="divAlert" runat="server" class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> <asp:Literal ID="litMessage" runat="server" /></div>
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>

            <asp:Panel ID="pnlLogin" runat="server">
                <div class="header">
                    <h1>Monolito <span style="color:var(--primary);">Secure</span></h1>
                    <p>La seguridad de élite que tu sistema merece</p>
                </div>

                <div class="input-group">
                    <label>Identidad Digital</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-user-shield"></i>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="control" placeholder="Nick o Correo" autocomplete="off" />
                    </div>
                </div>

                <div class="input-group">
                    <label>Código de Seguridad</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-lock"></i>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="control" TextMode="Password" placeholder="••••••••••••" autocomplete="new-password" />
                        <i class="fa-solid fa-eye" id="togglePass" onmousedown="event.preventDefault();" onclick="togglePassword('<%= txtPassword.ClientID %>', 'togglePass')"></i>
                    </div>
                </div>

                <div class="extra-links" style="justify-content: flex-end;">
                    <asp:LinkButton ID="lnkForgotPassword" runat="server" OnClick="lnkForgotPassword_Click">¿Perdiste tu llave?</asp:LinkButton>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Desbloquear Acceso" CssClass="btn-login" OnClick="btnLogin_Click" />

                <div class="social-grid">
                    <asp:LinkButton ID="btnGoogle" runat="server" CssClass="btn-social" OnClick="btnGoogle_Click"><i class="fa-brands fa-google"></i> Google</asp:LinkButton>
                    <asp:LinkButton ID="btnGithub" runat="server" CssClass="btn-social" OnClick="btnGithub_Click"><i class="fa-brands fa-github"></i> GitHub</asp:LinkButton>
                </div>

                <div class="qr-trigger">
                    <p style="font-size:12px; color:var(--text-dim); margin-bottom:15px; font-weight:700;">MÉTODOS ALTERNATIVOS</p>
                    <button type="button" class="btn-qr" onclick="openScanner()"><i class="fa-solid fa-qrcode"></i> Escaneo de Llave QR</button>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlOTP" runat="server" Visible="false">
                <div class="header">
                    <h2 style="font-family:'Outfit'; font-weight:900;">Verificación 2FA</h2>
                    <p>Ingresa el código OTP de 6 dígitos enviado a tu correo electrónico</p>
                </div>
                <div class="input-group">
                    <label>Código de Verificación</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-key" style="position: absolute; left: 20px; color: var(--text-dim); font-size: 18px; z-index: 5; pointer-events: none;"></i>
                        <asp:TextBox ID="txtOTP" runat="server" CssClass="control" placeholder="000000" MaxLength="6" autocomplete="off" style="text-align: center; letter-spacing: 4px; font-size: 20px; font-weight: bold; padding: 18px 20px;" />
                    </div>
                </div>
                <asp:Button ID="btnVerifyOTP" runat="server" Text="Confirmar Código" CssClass="btn-login" OnClick="btnVerifyOTP_Click" />
                <div style="text-align:center; margin-top:25px;">
                    <asp:LinkButton ID="lnkCancelOTP" runat="server" OnClick="lnkCancelOTP_Click" style="color:var(--text-dim); text-decoration:none; font-size:14px; font-weight:800; border-bottom: 2px solid transparent; transition: 0.3s;">← Cancelar e Iniciar de nuevo</asp:LinkButton>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlForgotEmail" runat="server" Visible="false">
                <div class="header">
                    <h2 style="font-family:'Outfit'; font-weight:900;">Restaurar Acceso</h2>
                    <p>Recibe una clave de emergencia en tu correo</p>
                </div>
                <div class="input-group">
                    <label>Correo Electrónico de Rescate</label>
                    <div class="input-wrapper"><i class="fa-solid fa-envelope-open-text"></i><asp:TextBox ID="txtForgotEmail" runat="server" CssClass="control" placeholder="tu@identidad.com" /></div>
                </div>
                <asp:Button ID="btnSendTempPass" runat="server" Text="Generar Clave Temporal" CssClass="btn-login" OnClick="btnSendTempPass_Click" />
                <div style="text-align:center; margin-top:25px;"><asp:LinkButton ID="lnkBackToLogin" runat="server" OnClick="lnkBackToLogin_Click" style="color:var(--text-dim); text-decoration:none; font-size:14px; font-weight:800; border-bottom: 2px solid transparent; transition: 0.3s;">← Volver al Portal de Ingreso</asp:LinkButton></div>
            </asp:Panel>

            <div style="text-align:center; margin-top:35px; font-size:14px; color:var(--text-dim); font-weight:600;">
                ¿Aún no tienes acceso? <asp:LinkButton ID="lnkRegistrar" runat="server" OnClick="lnkRegistrar_Click" style="color:var(--primary); text-decoration:none; font-weight:900;">Solicita tu cuenta aquí</asp:LinkButton>
            </div>
        </div>
    </form>
    <script>
        function togglePassword(fieldId, iconId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(iconId);
            if (field.type === 'password') { field.type = 'text'; icon.classList.replace('fa-eye', 'fa-eye-slash'); }
            else { field.type = 'password'; icon.classList.replace('fa-eye-slash', 'fa-eye'); }
        }

        let scanner = null;
        function openScanner() {
            document.getElementById('qrModal').style.display = 'flex';
            document.getElementById('qrStatus').innerText = "Iniciando sensor óptico...";
            scanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 });
            scanner.render((decodedText) => {
                document.getElementById('qrStatus').innerText = "¡ESCANEO EXITOSO!";
                document.getElementById('qrStatus').style.color = "var(--accent)";
                document.getElementById('qrHashBox').style.display = 'block';
                document.getElementById('qrHashVal').innerText = btoa(decodedText); 
                
                document.getElementById('<%= hfQRToken.ClientID %>').value = decodedText;
                
                // Sonido de éxito táctico
                try {
                    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.connect(gain); gain.connect(audioCtx.destination);
                    osc.type = 'sine'; osc.frequency.setValueAtTime(880, audioCtx.currentTime);
                    gain.gain.setValueAtTime(0.1, audioCtx.currentTime);
                    osc.start(); osc.stop(audioCtx.currentTime + 0.1);
                } catch(e) {}
                
                setTimeout(() => {
                    scanner.clear();
                    document.getElementById('<%= btnQRLogin.ClientID %>').click();
                }, 2000);
            });
        }
        function closeScanner() {
            if(scanner) scanner.clear();
            document.getElementById('qrModal').style.display = 'none';
        }
    </script>
</body>
</html>
