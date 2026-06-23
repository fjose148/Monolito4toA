using System;
using System.IO;
using System.Web;

namespace Capa_Negocio
{
    // [SERVICIO - LOGGING]
    public static class CN_Logger
    {
        // [UTIL - RUTA DE LOGS]
        private static string GetLogPath()
        {
            try
            {
                string path = HttpContext.Current?.Server.MapPath("~/App_Data/Logs") 
                              ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "Logs");
                               
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                string fileName = $"log_{DateTime.Now:yyyy-MM-dd}.txt";
                return Path.Combine(path, fileName);
            }
            catch (Exception)
            {
                return Path.Combine(Path.GetTempPath(), $"monolito_log_{DateTime.Now:yyyy-MM-dd}.txt"); // [FALLBACK]
            }
        }

        // [LOG - INFO]
        public static void LogInfo(string mensaje, string origen = "Sistema")
        {
            WriteLog("INFO", origen, mensaje);
        }

        // [LOG - WARNING]
        public static void LogWarning(string mensaje, string origen = "Sistema")
        {
            WriteLog("WARNING", origen, mensaje);
        }

        // [LOG - ERROR]
        public static void LogError(string mensaje, string origen = "Sistema", Exception ex = null)
        {
            string logMsg = mensaje;
            if (ex != null)
            {
                logMsg += $"\n  -> Exception: {ex.Message}";
            }
            WriteLog("ERROR", origen, logMsg);
        }

        // [LOG - SEGURIDAD]
        public static void LogSecurity(string mensaje, string origen = "Seguridad")
        {
            WriteLog("SECURITY", origen, mensaje);
        }

        // [IO - ESCRITURA FÍSICA]
        private static void WriteLog(string nivel, string origen, string mensaje)
        {
            try
            {
                string logFilePath = GetLogPath();
                string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                string logEntry = $"[{timestamp}] [{nivel}] [{origen}] {mensaje}{Environment.NewLine}";

                lock (typeof(CN_Logger)) // [THREAD-SAFE]
                {
                    File.AppendAllText(logFilePath, logEntry);
                }
            }
            catch
            {
                // [SILENCIADO]
            }
        }
    }
}


