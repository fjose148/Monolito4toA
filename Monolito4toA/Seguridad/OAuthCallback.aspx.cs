using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using Capa_Negocio;

namespace Monolito4toA.Seguridad
{
    public partial class OAuthCallback : System.Web.UI.Page
    {
        // Google Config
        private static readonly string GoogleClientId = System.Configuration.ConfigurationManager.AppSettings["GoogleClientId"] ?? "763913841788-era6ne66n6ue4djf0au48v6al74ilh1u.apps.googleusercontent.com";
        private static readonly string GoogleClientSecret = System.Configuration.ConfigurationManager.AppSettings["GoogleClientSecret"] ?? "";
        private const string GoogleTokenEndpoint = "https://oauth2.googleapis.com/token";
        private const string GoogleUserInfoEndpoint = "https://www.googleapis.com/oauth2/v2/userinfo";

        // GitHub Config
        private static readonly string GitHubClientId = System.Configuration.ConfigurationManager.AppSettings["GitHubClientId"] ?? "Ov23lio7L1tzTL9Mvm6N";
        private static readonly string GitHubClientSecret = System.Configuration.ConfigurationManager.AppSettings["GitHubClientSecret"] ?? "";
        private const string GitHubTokenEndpoint = "https://github.com/login/oauth/access_token";
        private const string GitHubUserInfoEndpoint = "https://api.github.com/user";
        private const string GitHubEmailsEndpoint = "https://api.github.com/user/emails"; // Para obtener el correo si es privado

        // Redirect URI must match exactly what's configured in the consoles
        private string GetRedirectUri()
        {
            string baseUrl = Request.Url.Scheme + "://" + Request.Url.Authority;
            return baseUrl + "/Seguridad/OAuthCallback.aspx";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(ProcessOAuthCallback));
            }
        }

        private async Task ProcessOAuthCallback()
        {
            try
            {
                string code = Request.QueryString["code"];
                string state = Request.QueryString["state"]; // 'google' or 'github'

                if (string.IsNullOrEmpty(code) || string.IsNullOrEmpty(state))
                {
                    Response.Redirect("~/Seguridad/Login.aspx?error=invalid_callback");
                    return;
                }

                string email = "";
                string nombres = "";

                if (state == "google")
                {
                    var tokenResponse = await ExchangeGoogleCodeForToken(code);
                    if (tokenResponse != null && tokenResponse["access_token"] != null)
                    {
                        var userInfo = await GetGoogleUserInfo(tokenResponse["access_token"].ToString());
                        if (userInfo != null)
                        {
                            email = userInfo["email"]?.ToString();
                            nombres = userInfo["name"]?.ToString();
                        }
                        else
                        {
                            Response.Write("Error obteniendo UserInfo de Google.");
                            return;
                        }
                    }
                    else
                    {
                        Response.Write("Error en token de Google. Verifica que el redirect_uri coincida exactamente.");
                        return;
                    }
                }
                else if (state == "github")
                {
                    var tokenResponse = await ExchangeGitHubCodeForToken(code);
                    if (tokenResponse != null && tokenResponse["access_token"] != null)
                    {
                        string accessToken = tokenResponse["access_token"].ToString();
                        var userInfo = await GetGitHubUserInfo(accessToken);
                        
                        if (userInfo != null)
                        {
                            nombres = userInfo["name"]?.ToString() ?? userInfo["login"]?.ToString();
                            email = userInfo["email"]?.ToString();

                            if (string.IsNullOrEmpty(email))
                            {
                                email = await GetGitHubUserEmail(accessToken);
                            }
                        }
                        else
                        {
                            Response.Write("Error obteniendo UserInfo de GitHub.");
                            return;
                        }
                    }
                    else
                    {
                        Response.Write("Error en token de GitHub. Verifica Client ID y Secret.");
                        return;
                    }
                }

                if (!string.IsNullOrEmpty(email))
                {
                    var user = CN_tbl_usuario.AutenticarRedSocial(email, nombres, "");
                    if (user != null)
                    {
                        // Enviar QR por correo al iniciar sesión por red social (Requerimiento Usuario)
                        try { CN_tbl_usuario.EnviarCorreoBienvenida(user); } catch { }

                        Session["UsuarioLogueado"] = user;
                        Response.Redirect("~/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }

                Response.Write($"Error: No se pudo obtener el email del proveedor ({state}). Nombres obtenidos: {nombres}");
            }
            catch (Exception ex)
            {
                Response.Write("Excepción crítica en OAuthCallback: " + ex.Message + "<br/>" + ex.StackTrace);
            }
        }

        private async Task<JObject> ExchangeGoogleCodeForToken(string code)
        {
            using (HttpClient client = new HttpClient())
            {
                var values = new Dictionary<string, string>
                {
                    { "code", code },
                    { "client_id", GoogleClientId },
                    { "client_secret", GoogleClientSecret },
                    { "redirect_uri", GetRedirectUri() },
                    { "grant_type", "authorization_code" }
                };

                var content = new FormUrlEncodedContent(values);
                var response = await client.PostAsync(GoogleTokenEndpoint, content);
                string responseString = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                    return JObject.Parse(responseString);
                
                Response.Write("Error de Google Token API: " + responseString + "<br/>");
                return null;
            }
        }

        private async Task<JObject> GetGoogleUserInfo(string accessToken)
        {
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                var response = await client.GetAsync(GoogleUserInfoEndpoint);
                string responseString = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                    return JObject.Parse(responseString);

                return null;
            }
        }

        private async Task<JObject> ExchangeGitHubCodeForToken(string code)
        {
            using (HttpClient client = new HttpClient())
            {
                var values = new Dictionary<string, string>
                {
                    { "code", code },
                    { "client_id", GitHubClientId },
                    { "client_secret", GitHubClientSecret },
                    { "redirect_uri", GetRedirectUri() }
                };

                var content = new FormUrlEncodedContent(values);
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                
                var response = await client.PostAsync(GitHubTokenEndpoint, content);
                string responseString = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                    return JObject.Parse(responseString);

                Response.Write("Error de GitHub Token API: " + responseString + "<br/>");
                return null;
            }
        }

        private async Task<JObject> GetGitHubUserInfo(string accessToken)
        {
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", accessToken);
                client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("Monolito4toA", "1.0")); // GitHub requires User-Agent
                
                var response = await client.GetAsync(GitHubUserInfoEndpoint);
                string responseString = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                    return JObject.Parse(responseString);

                return null;
            }
        }

        private async Task<string> GetGitHubUserEmail(string accessToken)
        {
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", accessToken);
                client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("Monolito4toA", "1.0"));
                
                var response = await client.GetAsync(GitHubEmailsEndpoint);
                string responseString = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    JArray emails = JArray.Parse(responseString);
                    foreach (var email in emails)
                    {
                        if (email["primary"] != null && (bool)email["primary"])
                        {
                            return email["email"].ToString();
                        }
                    }
                }
                return "";
            }
        }
    }
}
