using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace Monolito4toA
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Código que se ejecuta al iniciar la aplicación
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            Application["MaintenanceMode"] = false;

            if (Capa_Negocio.CN_GlobalSettings.UseMongoDB)
            {
                try
                {
                    Capa_Datos.MongoDBHelper.MigrateSQLToMongoDB();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("MongoDB migration on startup failed: " + ex.Message);
                }
            }
        }

        void Application_AcquireRequestState(object sender, EventArgs e)
        {
            if (Application["MaintenanceMode"] != null && (bool)Application["MaintenanceMode"])
            {
                string path = Request.Path.ToLower();
                
                // Allow CSS, JS, Images to load
                if (path.Contains(".css") || path.Contains(".js") || path.Contains(".png") || path.Contains(".jpg") || path.Contains(".ico"))
                    return;

                // Allow login and maintenance pages
                if (path.Contains("mantenimiento.aspx") || path.Contains("login.aspx"))
                    return;

                // Allow Admins to bypass maintenance
                if (Session != null && Session["UsuarioLogueado"] != null)
                {
                    Capa_Datos.tbl_usuario user = (Capa_Datos.tbl_usuario)Session["UsuarioLogueado"];
                    if (user.tusu_id == 1) // Admin role
                        return;
                }

                // Redirect others to maintenance
                Response.Redirect("~/Mantenimiento.aspx");
            }
        }
    }
}