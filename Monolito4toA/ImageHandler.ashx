<%@ WebHandler Language="C#" Class="Monolito4toA.ImageHandler" %>
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.Configuration;
using System.IO;

namespace Monolito4toA
{
    public class ImageHandler : IHttpHandler, IRequiresSessionState
    {
        private string ConnStr {
            get {
                return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Capa_Datos.Properties.Settings.Monolillo4toConnectionString"].ConnectionString;
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Buffer = true;
            context.Response.Clear();
            
            try
            {
                // A. Imagen de Producto (por path_id)
                string pathIdStr = context.Request.QueryString["path_id"];
                if (!string.IsNullOrEmpty(pathIdStr) && int.TryParse(pathIdStr, out int pathId))
                {
                    using (var dc = new Capa_Datos.DactaClasesDataContext())
                    {
                        var img = System.Linq.Queryable.FirstOrDefault(dc.tbl_path, x => x.path_id == pathId);
                        if (img != null && !string.IsNullOrEmpty(img.path_ruta))
                        {
                            string physicalPath = img.path_ruta;
                            if (physicalPath.StartsWith("~/"))
                            {
                                physicalPath = context.Server.MapPath(physicalPath);
                            }
                            else if (!File.Exists(physicalPath))
                            {
                                string fileName = Path.GetFileName(physicalPath);
                                string fallback = context.Server.MapPath("~/Imagenes/" + fileName);
                                if (File.Exists(fallback))
                                {
                                    physicalPath = fallback;
                                }
                            }

                            if (File.Exists(physicalPath))
                            {
                                string ext = Path.GetExtension(physicalPath).ToLower();
                                if (ext == ".jpg" || ext == ".jpeg") context.Response.ContentType = "image/jpeg";
                                else if (ext == ".png") context.Response.ContentType = "image/png";
                                else if (ext == ".gif") context.Response.ContentType = "image/gif";
                                else if (ext == ".webp") context.Response.ContentType = "image/webp";
                                else context.Response.ContentType = "application/octet-stream";

                                context.Response.WriteFile(physicalPath);
                                return;
                            }
                        }
                    }
                }

                // 1. Previsualización de Sesión (Registro)
                if (context.Request.QueryString["preview"] == "true")
                {
                    var imgs = context.Session["TempImages"] as List<byte[]>;
                    var types = context.Session["TempImageTypes"] as List<string>;
                    int idx;
                    if (int.TryParse(context.Request.QueryString["idx"], out idx) && imgs != null && idx < imgs.Count)
                    {
                        context.Response.ContentType = types[idx];
                        context.Response.OutputStream.Write(imgs[idx], 0, imgs[idx].Length);
                        return;
                    }
                }

                // 1b. Previsualización de Perfil (Edición)
                if (context.Request.QueryString["previewPerfil"] == "true")
                {
                    var img = context.Session["TempPerfilImage"] as byte[];
                    var type = context.Session["TempPerfilImageType"] as string;
                    if (img != null)
                    {
                        context.Response.ContentType = type ?? "image/jpeg";
                        context.Response.OutputStream.Write(img, 0, img.Length);
                        return;
                    }
                }

                // 2. Imagen Real de Usuario
                string idStr = context.Request.QueryString["usu_id"];
                if (!string.IsNullOrEmpty(idStr) && int.TryParse(idStr, out int usuId))
                {
                    using (SqlConnection conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        
                        // --- FASE A: Buscar Base64 en la tabla principal (Prioridad Alta) ---
                        const string qBase = "SELECT usu_imagen FROM tbl_usuario WHERE usu_id = @id";
                        using (var cmd = new SqlCommand(qBase, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", usuId);
                            object val = cmd.ExecuteScalar();
                            if (val != null && val != DBNull.Value)
                            {
                                string imgData = val.ToString();
                                if (imgData.StartsWith("data:image"))
                                {
                                    // Extraer bytes del Base64
                                    int commaIdx = imgData.IndexOf(',');
                                    if (commaIdx > 0)
                                    {
                                        string mime = imgData.Substring(5, commaIdx - 5).Replace(";base64", "");
                                        string pureBase64 = imgData.Substring(commaIdx + 1);
                                        byte[] bin = Convert.FromBase64String(pureBase64);
                                        context.Response.ContentType = mime;
                                        context.Response.OutputStream.Write(bin, 0, bin.Length);
                                        return;
                                    }
                                }
                            }
                        }

                        // --- FASE B: Buscar en tabla de imágenes (Legacy / Galería) ---
                        const string qImg = "SELECT TOP 1 img_binario, img_tipo FROM tbl_usuario_imagenes WHERE usu_id = @id ORDER BY img_es_perfil DESC, img_id DESC";
                        using (var cmd = new SqlCommand(qImg, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", usuId);
                            using (var r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    byte[] bin = (byte[])r["img_binario"];
                                    context.Response.ContentType = r["img_tipo"].ToString();
                                    context.Response.OutputStream.Write(bin, 0, bin.Length);
                                    return;
                                }
                            }
                        }
                    }
                }

                // 3. Fallback: Devolver imagen local predeterminada
                ReturnDefault(context);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ImageHandler Critical Error: " + ex.Message);
                ReturnDefault(context);
            }
        }

        private void ReturnDefault(HttpContext context)
        {
            try {
                string path = context.Server.MapPath("~/Content/Images/default-avatar.png");
                if (File.Exists(path)) {
                    context.Response.ContentType = "image/png";
                    context.Response.WriteFile(path);
                } else {
                    context.Response.StatusCode = 404;
                }
            } catch {
                context.Response.StatusCode = 404;
            }
        }

        public bool IsReusable => false;
    }
}
