using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_proveedor
    {
        // Get all providers
        public static List<tbl_proveedor> ObtenerTodos()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerTodosProveedores();
            }
            using (var dc = new DactaClasesDataContext())
            {
                return dc.tbl_proveedor.ToList();
            }
        }

        // Get provider by ID
        public static tbl_proveedor ObtenerPorId(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerProveedorPorId(id);
            }
            using (var dc = new DactaClasesDataContext())
            {
                return dc.tbl_proveedor.FirstOrDefault(p => p.prov_id == id);
            }
        }

        // Insert provider
        public static void Insertar(tbl_proveedor prov)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.InsertarProveedor(prov);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                prov.prov_estado = 'A';
                dc.tbl_proveedor.InsertOnSubmit(prov);
                dc.SubmitChanges();
            }
        }

        // Update provider
        public static void Actualizar(tbl_proveedor prov)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ActualizarProveedor(prov);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                var existing = dc.tbl_proveedor.FirstOrDefault(p => p.prov_id == prov.prov_id);
                if (existing != null)
                {
                    existing.prov_nombre = prov.prov_nombre;
                    existing.prov_estado = prov.prov_estado;
                    dc.SubmitChanges();
                }
            }
        }

        // Logical Delete: Sets status to 'I' and backs up the prov_id relation on children products
        public static void EliminarLogico(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.EliminarLogicoProveedor(id);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                var prov = dc.tbl_proveedor.FirstOrDefault(p => p.prov_id == id);
                if (prov != null)
                {
                    prov.prov_estado = 'I';

                    // Backup and detach associated products (without deactivating them)
                    var products = dc.tbl_producto.Where(p => p.prov_id == id).ToList();
                    foreach (var p in products)
                    {
                        p.pro_prov_id_backup = id;
                        p.prov_id = null;   // Detach
                    }

                    dc.SubmitChanges();
                }
            }
        }

        // Restore Logical Delete: Sets status to 'A' and reconnects children products from backup
        public static void Restaurar(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.RestaurarProveedor(id);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                var prov = dc.tbl_proveedor.FirstOrDefault(p => p.prov_id == id);
                if (prov != null)
                {
                    prov.prov_estado = 'A';

                    // Reconnect products that were backed up
                    var products = dc.tbl_producto.Where(p => p.pro_prov_id_backup == id).ToList();
                    foreach (var p in products)
                    {
                        p.prov_id = id;
                        p.pro_prov_id_backup = null; // Clear backup
                    }

                    dc.SubmitChanges();
                }
            }
        }

        // Physical Delete (detaches products first to prevent cascading delete)
        public static void EliminarFisico(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.EliminarFisicoProveedor(id);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                // Set prov_id = null on all products associated with this provider
                var products = dc.tbl_producto.Where(p => p.prov_id == id).ToList();
                foreach (var p in products)
                {
                    p.prov_id = null;
                }
                dc.SubmitChanges();

                var prov = dc.tbl_proveedor.FirstOrDefault(p => p.prov_id == id);
                if (prov != null)
                {
                    dc.tbl_proveedor.DeleteOnSubmit(prov);
                    dc.SubmitChanges();

                    // Reseed identity for tbl_proveedor
                    dc.ExecuteCommand(@"
                        DECLARE @maxProvId INT;
                        SELECT @maxProvId = ISNULL(MAX(prov_id), 0) FROM tbl_proveedor;
                        DBCC CHECKIDENT ('tbl_proveedor', RESEED, @maxProvId);");
                }
            }
        }
    }
}
