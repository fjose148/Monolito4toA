using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito4toA
{
    // [ADMIN - GESTIÓN DE BLOQUEOS]
    public partial class AdminDesbloqueo : System.Web.UI.Page
    {
        // [AUTH - SEGURIDAD DE ACCESO]
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UsuarioLogueado"] == null) { Response.Redirect("~/Seguridad/Login.aspx", false); return; }
            var user = (tbl_usuario)Session["UsuarioLogueado"];
            if (user.tusu_id != 1) { Response.Redirect("~/Dashboard.aspx", false); return; }

            if (!IsPostBack) CargarUsuarios();
        }

        // [DATOS - CARGAR Y FILTRAR]
        protected void CargarUsuarios()
        {
            string filtro = txtSearch?.Text.Trim() ?? "";
            var lista = CN_tbl_usuario.ObtenerTodos(); 
            
            if (!string.IsNullOrEmpty(filtro))
                lista = lista.Where(u => u.usu_nick.Contains(filtro) || u.usu_correo.Contains(filtro) || u.usu_cedula.Contains(filtro)).ToList();
            
            gvUsuarios.DataSource = lista;
            gvUsuarios.DataBind();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CargarUsuarios();
        }

        // [EVENTOS - ACCIONES GRILLA]
        protected void gvUsuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int usuId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "Desbloquear":
                    CN_tbl_usuario.DesbloquearUsuario(usuId);
                    break;
                case "Bloquear":
                    BloquearUsuario(usuId);
                    break;
                case "Eliminar":
                    EliminarUsuario(usuId);
                    break;
                case "Editar":
                    Response.Redirect($"Perfil.aspx?edit_id={usuId}", false);
                    return;
            }
            CargarUsuarios();
        }

        // [NEGOCIO - BLOQUEO MANUAL]
        private void BloquearUsuario(int id)
        {
            using (var dc = new DactaClasesDataContext()) {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                if (u != null) { u.usu_estado = 'I'; dc.SubmitChanges(); }
            }
        }

        // [NEGOCIO - ELIMINACIÓN TOTAL]
        private void EliminarUsuario(int id)
        {
            try {
                using (var dc = new DactaClasesDataContext()) {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                    if (u != null) {
                        // [DATOS - LIMPIAR IMÁGENES SQL]
                        using (var cmd = dc.Connection.CreateCommand()) {
                            cmd.CommandText = "DELETE FROM tbl_usuario_imagenes WHERE usu_id = @id";
                            var p = cmd.CreateParameter();
                            p.ParameterName = "@id";
                            p.Value = id;
                            cmd.Parameters.Add(p);
                            
                            bool closed = dc.Connection.State == System.Data.ConnectionState.Closed;
                            if (closed) dc.Connection.Open();
                            cmd.ExecuteNonQuery();
                            if (closed) dc.Connection.Close();
                        }
                        
                        // [DATOS - BORRAR USUARIO]
                        dc.tbl_usuario.DeleteOnSubmit(u);
                        dc.SubmitChanges();
                        
                        CN_Logger.LogInfo($"Eliminado permanentemente ID {id}", "Admin");
                    }
                }
            } catch (Exception ex) {
                CN_Logger.LogError($"Error eliminar ID {id}", "Admin", ex);
            }
        }
    }
}

