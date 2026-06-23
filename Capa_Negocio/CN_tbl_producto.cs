using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Text;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_producto
    {
        // Get all products including their provider and images
        public static List<tbl_producto> ObtenerTodos()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerTodosProductos();
            }
            using (var dc = new DactaClasesDataContext())
            {
                var loadOptions = new DataLoadOptions();
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_proveedor);
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_path);
                dc.LoadOptions = loadOptions;

                return dc.tbl_producto.OrderByDescending(p => p.pro_id).ToList();
            }
        }

        // Get product by ID
        public static tbl_producto ObtenerPorId(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerProductoPorId(id);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var loadOptions = new DataLoadOptions();
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_proveedor);
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_path);
                dc.LoadOptions = loadOptions;

                return dc.tbl_producto.FirstOrDefault(p => p.pro_id == id);
            }
        }

        // Get products with filters (for Live Search & Category) using LINQ with lambda
        public static List<tbl_producto> ObtenerConFiltros(string keyword, string category, int? provId)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerProductosConFiltros(keyword, category, provId);
            }
            using (var dc = new DactaClasesDataContext())
            {
                var loadOptions = new DataLoadOptions();
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_proveedor);
                loadOptions.LoadWith<tbl_producto>(p => p.tbl_path);
                dc.LoadOptions = loadOptions;

                var query = dc.tbl_producto.AsQueryable();

                if (!string.IsNullOrEmpty(keyword))
                {
                    string k = keyword.ToLower();
                    query = query.Where(p => p.pro_nombre.ToLower().Contains(k) || 
                                             (p.pro_categoria != null && p.pro_categoria.ToLower().Contains(k)));
                }

                if (!string.IsNullOrEmpty(category) && category != "TODAS")
                {
                    query = query.Where(p => p.pro_categoria == category);
                }

                if (provId.HasValue && provId.Value > 0)
                {
                    query = query.Where(p => p.prov_id == provId.Value);
                }

                // Show only active products in user catalog
                query = query.Where(p => p.pro_estado == 'A');

                return query.OrderByDescending(p => p.pro_id).ToList();
            }
        }

        // Get distinct categories in products
        public static List<string> ObtenerCategorias()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                return MongoDBHelper.ObtenerCategoriasProductos();
            }
            using (var dc = new DactaClasesDataContext())
            {
                return dc.tbl_producto
                         .Where(p => p.pro_categoria != null && p.pro_categoria != "")
                         .Select(p => p.pro_categoria)
                         .Distinct()
                         .ToList();
            }
        }

        // Insert product with multiple image paths
        public static void Insertar(tbl_producto prod, List<string> imagePaths)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.InsertarProducto(prod, imagePaths);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                prod.pro_estado = 'A';
                dc.tbl_producto.InsertOnSubmit(prod);
                dc.SubmitChanges(); // This populates prod.pro_id

                if (imagePaths != null)
                {
                    foreach (var path in imagePaths)
                    {
                        if (!string.IsNullOrEmpty(path))
                        {
                            var img = new tbl_path
                            {
                                pro_id = prod.pro_id,
                                path_ruta = path
                            };
                            dc.tbl_path.InsertOnSubmit(img);
                        }
                    }
                    dc.SubmitChanges();
                }
            }
        }

        // Update product and refresh its images
        public static void Actualizar(tbl_producto prod, List<string> imagePaths)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ActualizarProducto(prod, imagePaths);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                var existing = dc.tbl_producto.FirstOrDefault(p => p.pro_id == prod.pro_id);
                if (existing != null)
                {
                    existing.pro_nombre = prod.pro_nombre;
                    existing.pro_cantidad = prod.pro_cantidad;
                    existing.pro_precio = prod.pro_precio;
                    existing.pro_categoria = prod.pro_categoria;
                    existing.prov_id = prod.prov_id;
                    existing.pro_estado = prod.pro_estado;

                    // Update images: clear existing ones and insert new ones
                    var oldImgs = dc.tbl_path.Where(img => img.pro_id == prod.pro_id);
                    dc.tbl_path.DeleteAllOnSubmit(oldImgs);

                    if (imagePaths != null)
                    {
                        foreach (var path in imagePaths)
                        {
                            if (!string.IsNullOrEmpty(path))
                            {
                                var img = new tbl_path
                                {
                                    pro_id = prod.pro_id,
                                    path_ruta = path
                                };
                                dc.tbl_path.InsertOnSubmit(img);
                            }
                        }
                    }

                    dc.SubmitChanges();
                }
            }
        }

        // Delete product
        public static void Eliminar(int id)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.EliminarProducto(id);
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                var prod = dc.tbl_producto.FirstOrDefault(p => p.pro_id == id);
                if (prod != null)
                {
                    dc.tbl_producto.DeleteOnSubmit(prod);
                    dc.SubmitChanges();

                    // Reseed identity
                    dc.ExecuteCommand(@"
                        DECLARE @maxId INT;
                        SELECT @maxId = ISNULL(MAX(pro_id), 0) FROM tbl_producto;
                        DBCC CHECKIDENT ('tbl_producto', RESEED, @maxId);");
                }
            }
        }

        // Clean table path and reset counter using the stored procedure
        public static void ReiniciarTablaPath()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                MongoDBHelper.ReiniciarTablaPath();
                return;
            }
            using (var dc = new DactaClasesDataContext())
            {
                dc.ExecuteCommand("EXEC sp_reiniciar_tabla_path");
            }
        }

        // Bulk Excel/CSV Import
        public static int ImportarDesdeDataTable(DataTable dt, string baseImageFolder)
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                int importCount = 0;
                foreach (DataRow row in dt.Rows)
                {
                    try
                    {
                        string provNombre = row["proveedor_nombre"]?.ToString()?.Trim();
                        string proNombre = row["producto_nombre"]?.ToString()?.Trim();
                        if (string.IsNullOrEmpty(provNombre) || string.IsNullOrEmpty(proNombre)) continue;

                        // 1. Get or Create Provider (Parent)
                        var provs = MongoDBHelper.ObtenerTodosProveedores();
                        var prov = provs.FirstOrDefault(p => p.prov_nombre.ToLower() == provNombre.ToLower());
                        if (prov == null)
                        {
                            prov = new tbl_proveedor
                            {
                                prov_nombre = provNombre,
                                prov_estado = 'A'
                            };
                            MongoDBHelper.InsertarProveedor(prov);
                        }
                        else if (prov.prov_estado == 'I')
                        {
                            prov.prov_estado = 'A'; // Reactivate if it was logically deleted
                            MongoDBHelper.ActualizarProveedor(prov);
                        }

                        // 2. Parse Product Details
                        int cantidad = 0;
                        int.TryParse(row["producto_cantidad"]?.ToString(), out cantidad);

                        decimal precio = 0;
                        decimal.TryParse(row["producto_precio"]?.ToString(), out precio);

                        char estado = 'A';
                        string estStr = row["producto_estado"]?.ToString()?.Trim()?.ToUpper();
                        if (!string.IsNullOrEmpty(estStr) && estStr.Length > 0)
                        {
                            estado = estStr[0];
                        }

                        string categoria = row["producto_categoria"]?.ToString()?.Trim() ?? "General";

                        // 3. Create or Update Product (Child)
                        var prods = MongoDBHelper.ObtenerTodosProductos();
                        var prod = prods.FirstOrDefault(p => p.pro_nombre.ToLower() == proNombre.ToLower() && p.prov_id == prov.prov_id);
                        bool isNew = false;
                        if (prod == null)
                        {
                            prod = new tbl_producto();
                            isNew = true;
                        }

                        prod.pro_nombre = proNombre;
                        prod.pro_cantidad = cantidad;
                        prod.pro_precio = precio;
                        prod.pro_estado = estado;
                        prod.prov_id = prov.prov_id;
                        prod.pro_categoria = categoria;

                        // 4. Import Images Reference
                        string imagenesStr = row["imagenes"]?.ToString()?.Trim();
                        List<string> imagePaths = new List<string>();
                        if (!string.IsNullOrEmpty(imagenesStr))
                        {
                            string[] imgFiles = imagenesStr.Split(new char[] { ';', ',' }, StringSplitOptions.RemoveEmptyEntries);
                            foreach (var file in imgFiles)
                            {
                                string cleanFile = file.Trim();
                                if (string.IsNullOrEmpty(cleanFile)) continue;
                                imagePaths.Add("~/Imagenes/" + cleanFile);
                            }
                        }

                        if (isNew)
                        {
                            MongoDBHelper.InsertarProducto(prod, imagePaths);
                        }
                        else
                        {
                            MongoDBHelper.ActualizarProducto(prod, imagePaths);
                        }

                        importCount++;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Bulk Import Row Error: " + ex.Message);
                    }
                }
                return importCount;
            }

            using (var dc = new DactaClasesDataContext())
            {
                int importCount = 0;
                foreach (DataRow row in dt.Rows)
                {
                    try
                    {
                        string provNombre = row["proveedor_nombre"]?.ToString()?.Trim();
                        string proNombre = row["producto_nombre"]?.ToString()?.Trim();
                        if (string.IsNullOrEmpty(provNombre) || string.IsNullOrEmpty(proNombre)) continue;

                        // 1. Get or Create Provider (Parent)
                        var prov = dc.tbl_proveedor.FirstOrDefault(p => p.prov_nombre.ToLower() == provNombre.ToLower());
                        if (prov == null)
                        {
                            prov = new tbl_proveedor
                            {
                                prov_nombre = provNombre,
                                prov_estado = 'A'
                            };
                            dc.tbl_proveedor.InsertOnSubmit(prov);
                            dc.SubmitChanges(); // Populate prov_id
                        }
                        else if (prov.prov_estado == 'I')
                        {
                            prov.prov_estado = 'A'; // Reactivate if it was logically deleted
                            dc.SubmitChanges();
                        }

                        // 2. Parse Product Details
                        int cantidad = 0;
                        int.TryParse(row["producto_cantidad"]?.ToString(), out cantidad);

                        decimal precio = 0;
                        decimal.TryParse(row["producto_precio"]?.ToString(), out precio);

                        char estado = 'A';
                        string estStr = row["producto_estado"]?.ToString()?.Trim()?.ToUpper();
                        if (!string.IsNullOrEmpty(estStr) && estStr.Length > 0)
                        {
                            estado = estStr[0];
                        }

                        string categoria = row["producto_categoria"]?.ToString()?.Trim() ?? "General";

                        // 3. Create or Update Product (Child)
                        var prod = dc.tbl_producto.FirstOrDefault(p => p.pro_nombre.ToLower() == proNombre.ToLower() && p.prov_id == prov.prov_id);
                        bool isNew = false;
                        if (prod == null)
                        {
                            prod = new tbl_producto();
                            isNew = true;
                        }

                        prod.pro_nombre = proNombre;
                        prod.pro_cantidad = cantidad;
                        prod.pro_precio = precio;
                        prod.pro_estado = estado;
                        prod.prov_id = prov.prov_id;
                        prod.pro_categoria = categoria;

                        if (isNew)
                        {
                            dc.tbl_producto.InsertOnSubmit(prod);
                        }
                        dc.SubmitChanges(); // Populate pro_id

                        // 4. Import Images Reference
                        string imagenesStr = row["imagenes"]?.ToString()?.Trim();
                        if (!string.IsNullOrEmpty(imagenesStr))
                        {
                            // Clear existing images for this product first
                            var existingImgs = dc.tbl_path.Where(img => img.pro_id == prod.pro_id);
                            dc.tbl_path.DeleteAllOnSubmit(existingImgs);

                            string[] imgFiles = imagenesStr.Split(new char[] { ';', ',' }, StringSplitOptions.RemoveEmptyEntries);
                            foreach (var file in imgFiles)
                            {
                                string cleanFile = file.Trim();
                                if (string.IsNullOrEmpty(cleanFile)) continue;

                                // Use relative path for cloud hosting compatibility
                                string relativePath = "~/Imagenes/" + cleanFile;

                                var img = new tbl_path
                                {
                                    pro_id = prod.pro_id,
                                    path_ruta = relativePath
                                };
                                dc.tbl_path.InsertOnSubmit(img);
                            }
                            dc.SubmitChanges();
                        }

                        importCount++;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Bulk Import Row Error: " + ex.Message);
                    }
                }
                return importCount;
            }
        }

        // Export All Products to CSV Format (Flat file downloadable)
        public static string ExportarAExcelCSV()
        {
            if (CN_GlobalSettings.UseMongoDB)
            {
                var sb = new StringBuilder();
                sb.AppendLine("sep=;");
                sb.AppendLine("proveedor_id;proveedor_nombre;producto_nombre;producto_cantidad;producto_precio;producto_estado;producto_categoria;imagenes");

                var prods = MongoDBHelper.ObtenerTodosProductos();
                foreach (var p in prods)
                {
                    string provIdStr = p.prov_id?.ToString() ?? "0";
                    string provName = p.tbl_proveedor?.prov_nombre ?? "Sin Proveedor";
                    var imgNames = p.tbl_path
                                     .Select(img => Path.GetFileName(img.path_ruta))
                                     .ToList();
                    string imgsSeparated = string.Join(",", imgNames);

                    string csvProv = EscapeCSV(provName);
                    string csvProd = EscapeCSV(p.pro_nombre);
                    string csvCat = EscapeCSV(p.pro_categoria ?? "General");
                    string csvImgs = EscapeCSV(imgsSeparated);

                    sb.AppendLine($"{provIdStr};{csvProv};{csvProd};{p.pro_cantidad};{p.pro_precio?.ToString("F2", System.Globalization.CultureInfo.InvariantCulture)};{p.pro_estado};{csvCat};{csvImgs}");
                }
                return sb.ToString();
            }

            var sbSql = new StringBuilder();
            sbSql.AppendLine("sep=;");
            sbSql.AppendLine("proveedor_id;proveedor_nombre;producto_nombre;producto_cantidad;producto_precio;producto_estado;producto_categoria;imagenes");

            using (var dc = new DactaClasesDataContext())
            {
                var prods = dc.tbl_producto.ToList();
                foreach (var p in prods)
                {
                    string provIdStr = p.prov_id?.ToString() ?? "0";
                    string provName = p.tbl_proveedor?.prov_nombre ?? "Sin Proveedor";
                    // Gather image filenames
                    var imgNames = dc.tbl_path
                                     .Where(img => img.pro_id == p.pro_id)
                                     .Select(img => Path.GetFileName(img.path_ruta))
                                     .ToList();
                    // Separate multiple images with comma since semicolon is the column separator
                    string imgsSeparated = string.Join(",", imgNames);

                    // Escape CSV values
                    string csvProv = EscapeCSV(provName);
                    string csvProd = EscapeCSV(p.pro_nombre);
                    string csvCat = EscapeCSV(p.pro_categoria ?? "General");
                    string csvImgs = EscapeCSV(imgsSeparated);

                    sbSql.AppendLine($"{provIdStr};{csvProv};{csvProd};{p.pro_cantidad};{p.pro_precio?.ToString("F2", System.Globalization.CultureInfo.InvariantCulture)};{p.pro_estado};{csvCat};{csvImgs}");
                }
            }
            return sbSql.ToString();
        }

        private static string EscapeCSV(string field)
        {
            if (string.IsNullOrEmpty(field)) return "";
            if (field.Contains(";") || field.Contains("\"") || field.Contains("\n") || field.Contains("\r"))
            {
                return "\"" + field.Replace("\"", "\"\"") + "\"";
            }
            return field;
        }
    }
}
