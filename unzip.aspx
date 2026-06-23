<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        try {
            string zipPath = Server.MapPath("~/Proyecto_Para_Subir.zip");
            string extractPath = Server.MapPath("~/");
            
            if (File.Exists(zipPath)) {
                using (ZipArchive archive = ZipFile.OpenRead(zipPath)) {
                    foreach (ZipArchiveEntry entry in archive.Entries) {
                        string destPath = Path.Combine(extractPath, entry.FullName);
                        string destDir = Path.GetDirectoryName(destPath);
                        if (!Directory.Exists(destDir)) Directory.CreateDirectory(destDir);
                        if (!string.IsNullOrEmpty(entry.Name)) {
                            entry.ExtractToFile(destPath, true);
                        }
                    }
                }
                Response.Write("SUCCESS: Unzipped.<br/>");
                
                // Force Application Pool Recycle by touching web.config
                string webConfigPath = Server.MapPath("~/web.config");
                if (File.Exists(webConfigPath)) {
                    File.SetLastWriteTimeUtc(webConfigPath, DateTime.UtcNow);
                    Response.Write("SUCCESS: App Pool Recycled.");
                }
            } else {
                Response.Write("ERROR: Zip not found.");
            }
        } catch (Exception ex) {
            Response.Write("ERROR: " + ex.Message);
        }
    }
</script>
