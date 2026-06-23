<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDesbloqueo.aspx.cs" Inherits="Monolito4toA.AdminDesbloqueo" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Administración — Monolito Secure</title>
    <link rel="shortcut icon" href="favicon.ico?v=2" type="image/x-icon" />
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root {
            --primary: #6366f1;
            --secondary: #ec4899;
            --accent: #10b981;
            --bg-dark: #030712;
            --card-bg: rgba(15, 23, 42, 0.6);
            --border: rgba(255, 255, 255, 0.08);
            --text-main: #f8fafc;
            --text-dim: #64748b;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }

        body {
            background: var(--bg-dark);
            color: var(--text-main);
            min-height: 100vh;
            padding: 40px 20px;
            overflow-x: hidden;
            position: relative;
        }

        .blobs { position: fixed; inset: 0; z-index: -1; filter: blur(100px); opacity: 0.3; }
        .blob { position: absolute; border-radius: 50%; animation: move 20s infinite alternate; }
        .blob-1 { width: 500px; height: 500px; background: var(--primary); top: -100px; left: -100px; }
        .blob-2 { width: 400px; height: 400px; background: var(--secondary); bottom: -100px; right: -100px; animation-delay: -5s; }
        @keyframes move { from { transform: translate(0,0); } to { transform: translate(100px, 100px); } }

        .container { max-width: 1200px; margin: 0 auto; animation: fadeUp 0.8s ease; }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px; }
        .header h1 { font-family: 'Outfit'; font-size: 36px; font-weight: 900; }
        .btn-back {
            padding: 12px 24px; background: rgba(255,255,255,0.05); border: 1px solid var(--border);
            border-radius: 14px; color: white; text-decoration: none; font-weight: 700; transition: 0.3s;
        }
        .btn-back:hover { background: rgba(255,255,255,0.1); border-color: var(--primary); transform: translateX(-5px); }

        .admin-panel {
            background: var(--card-bg); backdrop-filter: blur(25px); border: 1px solid var(--border);
            border-radius: 35px; padding: 40px; box-shadow: 0 40px 80px rgba(0,0,0,0.6);
        }

        .search-box { margin-bottom: 35px; position: relative; max-width: 400px; }
        .search-box i { position: absolute; left: 18px; top: 50%; transform: translateY(-50%); color: var(--text-dim); }
        .search-input {
            width: 100%; background: rgba(0,0,0,0.2); border: 1px solid var(--border);
            border-radius: 14px; padding: 14px 14px 14px 45px; color: white; font-size: 15px;
            transition: 0.3s;
        }
        .search-input:focus { outline: none; border-color: var(--primary); background: rgba(0,0,0,0.3); }

        /* Custom Table */
        .table-container { width: 100%; overflow-x: auto; }
        .grid-view { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .grid-view th { text-align: left; padding: 15px; color: var(--text-dim); font-size: 12px; text-transform: uppercase; letter-spacing: 1px; font-weight: 800; }
        .grid-view tr td { padding: 18px 15px; background: rgba(255,255,255,0.02); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); transition: 0.3s; }
        .grid-view tr td:first-child { border-left: 1px solid var(--border); border-radius: 16px 0 0 16px; }
        .grid-view tr td:last-child { border-right: 1px solid var(--border); border-radius: 0 16px 16px 0; }
        .grid-view tr:hover td { background: rgba(255,255,255,0.06); border-color: var(--primary); }

        .action-btn {
            width: 36px; height: 36px; border-radius: 10px; border: 1px solid var(--border);
            display: inline-flex; align-items: center; justify-content: center;
            cursor: pointer; transition: 0.3s; background: rgba(255,255,255,0.05); color: white;
            margin-right: 5px;
        }
        .btn-edit:hover { background: var(--primary); border-color: var(--primary); }
        .btn-delete:hover { background: #ef4444; border-color: #ef4444; }
        .btn-lock:hover { background: #f59e0b; border-color: #f59e0b; }
        .btn-unlock:hover { background: var(--accent); border-color: var(--accent); }

        .status-badge {
            padding: 6px 12px; border-radius: 10px; font-size: 11px; font-weight: 800;
        }
        .status-A { background: rgba(16, 185, 129, 0.1); color: var(--accent); }
        .status-I { background: rgba(239, 68, 68, 0.1); color: #fca5a5; }
    </style>
</head>
<body>
    <div class="blobs">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
    </div>

    <form id="form1" runat="server">
        <div class="container">
            <div class="header">
                <h1>Gestión de <span style="color: var(--primary);">Usuarios</span></h1>
                <a href="Dashboard.aspx" class="btn-back"><i class="fa-solid fa-house"></i> Dashboard</a>
            </div>

            <div class="admin-panel">
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Buscar por nick o correo..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                </div>

                <div class="table-container">
                    <asp:GridView ID="gvUsuarios" runat="server" AutoGenerateColumns="False" 
                        CssClass="grid-view" GridLines="None" OnRowCommand="gvUsuarios_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="Identidad">
                                <ItemTemplate>
                                    <div style="font-weight: 800; color: white;">@<%# Eval("usu_nick") %></div>
                                    <div style="font-size: 12px; color: var(--text-dim);"><%# Eval("usu_correo") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="usu_cedula" HeaderText="Cédula" />
                            <asp:TemplateField HeaderText="Rol">
                                <ItemTemplate>
                                    <span class='badge <%# Eval("tusu_id").ToString() == "1" ? "badge-admin" : "badge-user" %>'>
                                        <%# Eval("tusu_id").ToString() == "1" ? "ADMIN" : "USUARIO" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='status-badge status-<%# Eval("usu_estado") %>'>
                                        <%# Eval("usu_estado").ToString() == "A" ? "ACTIVO" : "BLOQUEADO" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="usu_intentos" HeaderText="Fallas" />
                            <asp:TemplateField HeaderText="Acciones">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="Editar" CommandArgument='<%# Eval("usu_id") %>' CssClass="action-btn btn-edit"><i class="fa-solid fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton ID="lnkLock" runat="server" CommandName="Bloquear" CommandArgument='<%# Eval("usu_id") %>' CssClass="action-btn btn-lock" Visible='<%# Eval("usu_estado").ToString() == "A" %>'><i class="fa-solid fa-lock"></i></asp:LinkButton>
                                    <asp:LinkButton ID="lnkUnlock" runat="server" CommandName="Desbloquear" CommandArgument='<%# Eval("usu_id") %>' CssClass="action-btn btn-unlock" Visible='<%# Eval("usu_estado").ToString() == "I" %>'><i class="fa-solid fa-unlock"></i></asp:LinkButton>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("usu_id") %>' CssClass="action-btn btn-delete" OnClientClick="return confirm('¿Seguro?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
