using System;

namespace Capa_Negocio
{
    // [CONFIG - GLOBAL APP STATE]
    public static class CN_GlobalSettings
    {
        private static bool _mantenimientoActivo = false; // [STATE]

        public static bool MantenimientoActivo
        {
            get => _mantenimientoActivo;
            set => _mantenimientoActivo = value;
        }

        public static bool UseMongoDB
        {
            get
            {
                string val = System.Configuration.ConfigurationManager.AppSettings["UseMongoDB"];
                return !string.IsNullOrEmpty(val) && val.ToLower() == "true";
            }
        }

        public static string MensajeMantenimiento = "Sitio en mantenimiento. Intente más tarde."; // [UI]
    }
}
