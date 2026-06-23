using System;
using System.Collections.Specialized;
using System.Net.Http;
using System.Text;

namespace Capa_Negocio
{
    // [API - WHATSAPP INTEGRATION]
    public class CN_WhatsApp
    {
        private const string ApiUrl   = "https://api.ultramsg.com/instance175411/messages/chat";
        private const string Token    = "e51qa0idpixlkmtp"; // [AUTH]

        // [UTIL - NORMALIZAR TELÉFONO]
        private static string NormalizarTelefono(string telefono)
        {
            if (string.IsNullOrEmpty(telefono)) return string.Empty;

            string clean = telefono.Replace("+", "").Replace(" ", "").Replace("-", "").Trim();

            // Ya tiene código de país
            if (clean.StartsWith("593") && clean.Length == 12)
                return "+" + clean;

            // Empieza con 0 (formato local: 09XXXXXXXX)
            if (clean.StartsWith("09") && clean.Length == 10)
                return "+593" + clean.Substring(1);

            // Empieza con 9 sin el cero (9XXXXXXXX)
            if (clean.StartsWith("9") && clean.Length == 9)
                return "+593" + clean;

            // [FALLBACK]
            return "+" + clean;
        }

        // [API - ENVIAR MENSAJE BASE]
        public static void EnviarMensaje(string telefono, string mensaje)
        {
            try
            {
                string to = NormalizarTelefono(telefono);
                if (string.IsNullOrEmpty(to))
                {
                    CN_Logger.LogWarning("WhatsApp: número de teléfono vacío.", "WhatsApp");
                    return;
                }

                using (HttpClient client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(20);

                    // UltraMsg usa POST con form-data
                    var body = new StringContent(
                        $"token={Uri.EscapeDataString(Token)}&to={Uri.EscapeDataString(to)}&body={Uri.EscapeDataString(mensaje)}",
                        Encoding.UTF8,
                        "application/x-www-form-urlencoded"
                    );

                    var response = client.PostAsync(ApiUrl, body).Result;
                    string responseText = response.Content.ReadAsStringAsync().Result;

                    if (response.IsSuccessStatusCode)
                        CN_Logger.LogInfo($"WhatsApp enviado a {to}", "WhatsApp");
                    else
                        CN_Logger.LogWarning($"Fallo WhatsApp a {to}. HTTP {response.StatusCode}", "WhatsApp");
                }
            }
            catch (Exception ex)
            {
                CN_Logger.LogError("Error WhatsApp via UltraMsg", "WhatsApp", ex);
            }
        }

        // [NOTIFICACIÓN - CÓDIGO SEGURIDAD]
        public static void EnviarCodigoSeguridad(string telefono, string codigo, string nombre)
        {
            string msg =
                $"🔐 *Monolito4toA — Recuperación de Cuenta*\n\n" +
                $"Hola *{nombre}*, tu clave temporal de acceso es:\n\n" +
                $"🔑 *{codigo}*\n\n" +
                $"⚠️ Esta clave expira en 24 horas.";
            EnviarMensaje(telefono, msg);
        }

        // [NOTIFICACIÓN - BIENVENIDA]
        public static void EnviarBienvenida(string telefono, string nombre, string qrKey)
        {
            string msg =
                $"🎉 *¡Bienvenido a Monolito4toA, {nombre}!*\n\n" +
                $"🔑 *Tu llave QR de acceso:*\n`{qrKey}`";
            EnviarMensaje(telefono, msg);
        }

        // [NOTIFICACIÓN - BLOQUEO]
        public static void EnviarNotificacionBloqueo(string telefono, string nombre)
        {
            string msg =
                $"⛔ *Monolito4toA — Cuenta Bloqueada*\n\n" +
                $"Hola *{nombre}*, tu cuenta ha sido bloqueada por intentos fallidos.";
            EnviarMensaje(telefono, msg);
        }
    }
}
