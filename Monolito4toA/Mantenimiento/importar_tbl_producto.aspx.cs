using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4toA.Mantenimientos
{
    public partial class importar_tbl_producto : Page
    {
        protected FileUpload fuExcel;
        protected Button btnImportar;
        protected Panel pnlPreview;
        protected GridView gvPreview;
        protected Literal litMsg;
        protected FileUpload fuImagenes;
        protected Button btnUploadImages;

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session["UsuarioLogueado"] as tbl_usuario;
            if (user == null)
            {
                Response.Redirect("~/Seguridad/Login.aspx");
                return;
            }

            if (user.tusu_id != 1)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }
        }

        protected void btnUploadImages_Click(object sender, EventArgs e)
        {
            if (!fuImagenes.HasFiles)
            {
                ShowAlert("danger", "Por favor, seleccione una o más imágenes para subir.");
                return;
            }

            try
            {
                string baseImageFolder = Server.MapPath("~/Imagenes");
                if (!Directory.Exists(baseImageFolder))
                {
                    Directory.CreateDirectory(baseImageFolder);
                }

                int count = 0;
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                
                foreach (HttpPostedFile file in fuImagenes.PostedFiles)
                {
                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (Array.IndexOf(allowedExtensions, ext) >= 0)
                    {
                        string targetPath = Path.Combine(baseImageFolder, Path.GetFileName(file.FileName));
                        file.SaveAs(targetPath);
                        count++;
                    }
                }

                ShowAlert("success", $"¡Éxito! Se subieron {count} imágenes al directorio del servidor.");
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al subir imágenes: " + ex.Message);
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            if (!fuExcel.HasFile)
            {
                ShowAlert("danger", "Por favor, seleccione un archivo CSV o Excel (.xlsx, .xls) para previsualizar.");
                return;
            }

            try
            {
                string ext = Path.GetExtension(fuExcel.FileName).ToLower();
                if (ext != ".csv" && ext != ".xls" && ext != ".xlsx")
                {
                    ShowAlert("danger", "Formato de archivo no soportado. Debe usar un archivo CSV o de hoja de cálculo Excel.");
                    return;
                }

                // Save temp file locally to parse it
                string tempDir = Server.MapPath("~/App_Data/TempImports/");
                if (!Directory.Exists(tempDir))
                {
                    Directory.CreateDirectory(tempDir);
                }

                string tempPath = Path.Combine(tempDir, Guid.NewGuid().ToString() + ext);
                fuExcel.SaveAs(tempPath);

                DataTable dt = null;

                if (ext == ".csv")
                {
                    dt = ParseCSV(tempPath);
                }
                else
                {
                    try
                    {
                        dt = ParseExcel(tempPath);
                    }
                    catch (Exception ex)
                    {
                        // Fallback message indicating OLEDB driver is missing and suggesting CSV
                        ShowAlert("danger", "No se pudo procesar el archivo Excel debido a restricciones de controladores en el servidor (" + ex.Message + "). <strong>Recomendación:</strong> Guarde su planilla como archivo de texto CSV delimitado por comas y vuelva a intentar la subida.");
                        if (File.Exists(tempPath)) File.Delete(tempPath);
                        return;
                    }
                }

                if (File.Exists(tempPath))
                {
                    File.Delete(tempPath);
                }

                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowAlert("danger", "El archivo procesado no contiene filas válidas o no coincide con el encabezado de planilla requerido.");
                    btnImportar.Visible = false;
                    pnlPreview.Visible = false;
                    return;
                }

                Session["ImportTable"] = dt;
                gvPreview.DataSource = dt;
                gvPreview.DataBind();
                
                pnlPreview.Visible = true;
                btnImportar.Visible = true;
                litMsg.Text = ""; // clear messages
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Ocurrió un error inesperado al procesar el archivo: " + ex.Message);
            }
        }

        private DataTable CreateImportTable()
        {
            var dt = new DataTable();
            dt.Columns.Add("proveedor_id", typeof(string));
            dt.Columns.Add("proveedor_nombre", typeof(string));
            dt.Columns.Add("producto_nombre", typeof(string));
            dt.Columns.Add("producto_cantidad", typeof(string));
            dt.Columns.Add("producto_precio", typeof(string));
            dt.Columns.Add("producto_estado", typeof(string));
            dt.Columns.Add("producto_categoria", typeof(string));
            dt.Columns.Add("imagenes", typeof(string));
            return dt;
        }

        private DataTable ParseCSV(string filePath)
        {
            var dt = CreateImportTable();
            using (var reader = new StreamReader(filePath, Encoding.UTF8))
            {
                string headerLine = reader.ReadLine();
                if (headerLine == null) return dt;

                // Skip the Excel delimiter directive if present
                if (headerLine.StartsWith("sep=", StringComparison.OrdinalIgnoreCase))
                {
                    headerLine = reader.ReadLine();
                    if (headerLine == null) return dt;
                }

                var headers = SplitCsvLine(headerLine);

                // Basic validation: must contain columns proveedor_nombre and producto_nombre
                bool hasProv = false, hasProd = false;
                foreach (var h in headers)
                {
                    if (h.Equals("proveedor_nombre", StringComparison.OrdinalIgnoreCase)) hasProv = true;
                    if (h.Equals("producto_nombre", StringComparison.OrdinalIgnoreCase)) hasProd = true;
                }

                if (!hasProv || !hasProd) return null;

                while (!reader.EndOfStream)
                {
                    string line = reader.ReadLine();
                    if (string.IsNullOrEmpty(line)) continue;

                    var fields = SplitCsvLine(line);
                    if (fields.Count == 0) continue;

                    var row = dt.NewRow();
                    row["proveedor_id"] = GetFieldByName(headers, fields, "proveedor_id");
                    row["proveedor_nombre"] = GetFieldByName(headers, fields, "proveedor_nombre");
                    row["producto_nombre"] = GetFieldByName(headers, fields, "producto_nombre");
                    row["producto_cantidad"] = GetFieldByName(headers, fields, "producto_cantidad");
                    row["producto_precio"] = GetFieldByName(headers, fields, "producto_precio");
                    row["producto_estado"] = GetFieldByName(headers, fields, "producto_estado");
                    row["producto_categoria"] = GetFieldByName(headers, fields, "producto_categoria");
                    row["imagenes"] = GetFieldByName(headers, fields, "imagenes");

                    dt.Rows.Add(row);
                }
            }
            return dt;
        }

        private List<string> SplitCsvLine(string line)
        {
            var result = new List<string>();
            bool inQuotes = false;
            var field = new StringBuilder();

            // Detect delimiter dynamically (semicolon vs comma) outside of quotes
            char delimiter = ',';
            int commaCount = 0;
            int semiCount = 0;
            bool tempInQuotes = false;
            for (int i = 0; i < line.Length; i++)
            {
                if (line[i] == '"') tempInQuotes = !tempInQuotes;
                else if (!tempInQuotes)
                {
                    if (line[i] == ',') commaCount++;
                    else if (line[i] == ';') semiCount++;
                }
            }
            if (semiCount > commaCount)
            {
                delimiter = ';';
            }

            for (int i = 0; i < line.Length; i++)
            {
                char c = line[i];
                if (c == '"')
                {
                    inQuotes = !inQuotes;
                }
                else if (c == delimiter && !inQuotes)
                {
                    result.Add(field.ToString().Trim());
                    field.Clear();
                }
                else
                {
                    field.Append(c);
                }
            }
            result.Add(field.ToString().Trim());
            return result;
        }

        private string GetFieldByName(List<string> headers, List<string> fields, string columnName)
        {
            int index = headers.FindIndex(h => h.Equals(columnName, StringComparison.OrdinalIgnoreCase));
            if (index >= 0 && index < fields.Count)
            {
                return fields[index];
            }
            return "";
        }

        private DataTable ParseExcel(string filePath)
        {
            string connStr = "";
            string ext = Path.GetExtension(filePath).ToLower();
            if (ext == ".xls")
            {
                connStr = $"Provider=Microsoft.Jet.OLEDB.4.0;Data Source={filePath};Extended Properties=\"Excel 8.0;HDR=Yes;IMEX=1\"";
            }
            else if (ext == ".xlsx")
            {
                connStr = $"Provider=Microsoft.ACE.OLEDB.12.0;Data Source={filePath};Extended Properties=\"Excel 12.0 Xml;HDR=Yes;IMEX=1\"";
            }

            var dt = CreateImportTable();
            using (var conn = new System.Data.OleDb.OleDbConnection(connStr))
            {
                conn.Open();
                var schema = conn.GetOleDbSchemaTable(System.Data.OleDb.OleDbSchemaGuid.Tables, null);
                if (schema == null || schema.Rows.Count == 0) return dt;

                string sheetName = schema.Rows[0]["TABLE_NAME"].ToString();
                string selectCmd = $"SELECT * FROM [{sheetName}]";

                using (var adapter = new System.Data.OleDb.OleDbDataAdapter(selectCmd, conn))
                {
                    var rawDt = new DataTable();
                    adapter.Fill(rawDt);

                    foreach (DataRow rawRow in rawDt.Rows)
                    {
                        var row = dt.NewRow();
                        row["proveedor_nombre"] = GetRawRowValue(rawRow, "proveedor_nombre");
                        row["producto_nombre"] = GetRawRowValue(rawRow, "producto_nombre");
                        row["producto_cantidad"] = GetRawRowValue(rawRow, "producto_cantidad");
                        row["producto_precio"] = GetRawRowValue(rawRow, "producto_precio");
                        row["producto_estado"] = GetRawRowValue(rawRow, "producto_estado");
                        row["producto_categoria"] = GetRawRowValue(rawRow, "producto_categoria");
                        row["imagenes"] = GetRawRowValue(rawRow, "imagenes");
                        dt.Rows.Add(row);
                    }
                }
            }
            return dt;
        }

        private string GetRawRowValue(DataRow row, string colName)
        {
            if (row.Table.Columns.Contains(colName))
            {
                return row[colName]?.ToString()?.Trim() ?? "";
            }
            return "";
        }

        protected void btnImportar_Click(object sender, EventArgs e)
        {
            var dt = Session["ImportTable"] as DataTable;
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowAlert("danger", "No hay datos previsualizados listos para importar.");
                return;
            }

            try
            {
                string baseImageFolder = Server.MapPath("~/Imagenes");
                if (!Directory.Exists(baseImageFolder))
                {
                    Directory.CreateDirectory(baseImageFolder);
                }

                int imported = CN_tbl_producto.ImportarDesdeDataTable(dt, baseImageFolder);
                ShowAlert("success", $"¡Importación exitosa! Se han cargado/actualizado {imported} productos en la base de datos.");

                Session["ImportTable"] = null;
                pnlPreview.Visible = false;
                btnImportar.Visible = false;
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al guardar en la base de datos: " + ex.Message);
            }
        }

        protected void btnExportar_Click(object sender, EventArgs e)
        {
            try
            {
                string csv = CN_tbl_producto.ExportarAExcelCSV();
                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "text/csv";
                Response.ContentEncoding = Encoding.UTF8;
                Response.AppendHeader("Content-Disposition", "attachment; filename=CatalogoProductos_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");
                Response.Write(csv);
                Response.Flush();
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
                // standard behavior when calling Response.End
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al exportar catálogo: " + ex.Message);
            }
        }

        protected void btnResetPath_Click(object sender, EventArgs e)
        {
            try
            {
                CN_tbl_producto.ReiniciarTablaPath();
                ShowAlert("success", "Se ha restablecido la tabla de imágenes (tbl_path) y el contador incremental a cero.");
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error al restablecer rutas de imágenes: " + ex.Message);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            System.Web.Security.FormsAuthentication.SignOut();
            Response.Redirect("~/Seguridad/Login.aspx");
        }

        private void ShowAlert(string type, string message)
        {
            string color = "#34d399";
            string bg = "rgba(16, 185, 129, 0.1)";
            string border = "rgba(16, 185, 129, 0.2)";

            if (type == "danger")
            {
                color = "#f87171";
                bg = "rgba(239, 68, 68, 0.1)";
                border = "rgba(239, 68, 68, 0.2)";
            }

            litMsg.Text = $@"
                <div style='padding: 20px; border-radius: 16px; margin-bottom: 30px; color: {color}; background: {bg}; border: 1px solid {border}; font-weight: 700; display: flex; align-items: center; gap: 15px; font-size: 14px;'>
                    <i class='fa-solid fa-circle-info' style='font-size: 18px;'></i>
                    <span>{message}</span>
                </div>";
        }
    }
}
