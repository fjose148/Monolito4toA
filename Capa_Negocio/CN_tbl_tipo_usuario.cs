using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_tipo_usuario
    {
        // [DATOS - LISTAR ROLES]
        public static List<tbl_tipo_usuario> Listar()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ListarTiposUsuario();
            }
            using (DactaClasesDataContext dc = new DactaClasesDataContext())
            {
                return dc.tbl_tipo_usuario.Where(Tu => Tu.tusu_estado == 'A').ToList();
            }
        }

        // [DATOS - ID POR DEFECTO]
        public static int ObtenerIdPredeterminado()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerIdPredeterminadoTipoUsuario();
            }
            using (DactaClasesDataContext dc = new DactaClasesDataContext())
            {
                var tipo = dc.tbl_tipo_usuario.FirstOrDefault(Tu => Tu.tusu_estado == 'A');
                if (tipo != null)
                {
                    return tipo.tusu_id;
                }

                // [EMERGENCIA - CREAR TIPO]
                tbl_tipo_usuario nuevoTipo = new tbl_tipo_usuario
                {
                    tusu_nombre = "Usuario Estándar",
                    tusu_estado = 'A'
                };
                
                try
                {
                    dc.tbl_tipo_usuario.InsertOnSubmit(nuevoTipo);
                    dc.SubmitChanges();
                    return nuevoTipo.tusu_id;
                }
                catch
                {
                    return 1; // [FALLBACK]
                }
            }
        }

        // [NEGOCIO - OBTENER ROL ESTÁNDAR]
        public static int ObtenerIdUsuarioNormal()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerIdUsuarioNormal();
            }
            using (DactaClasesDataContext dc = new DactaClasesDataContext())
            {
                var tipos = dc.tbl_tipo_usuario.Where(t => t.tusu_estado == 'A').ToList();
                
                var tipoNormal = tipos.FirstOrDefault(t =>
                    t.tusu_nombre != null &&
                    t.tusu_nombre.ToLower().Contains("usuario") &&
                    !t.tusu_nombre.ToLower().Contains("admin"));
                
                if (tipoNormal != null) return tipoNormal.tusu_id;
                
                if (tipos.Count > 0) return tipos.OrderByDescending(t => t.tusu_id).First().tusu_id;
                
                return 2; // [FALLBACK]
            }
        }
    }
}
