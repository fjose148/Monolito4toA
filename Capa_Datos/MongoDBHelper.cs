using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Capa_Datos
{
    public static class MongoDBHelper
    {
        private static IMongoDatabase _database;

        private static IMongoDatabase Database
        {
            get
            {
                if (_database == null)
                {
                    string connStr = ConfigurationManager.AppSettings["MongoDBConnectionString"] ?? "mongodb://localhost:27017";
                    string dbName = ConfigurationManager.AppSettings["MongoDBDatabase"] ?? "Monolillo4to";
                    var client = new MongoClient(connStr);
                    _database = client.GetDatabase(dbName);
                }
                return _database;
            }
        }

        private static IMongoCollection<BsonDocument> UsuariosCollection => Database.GetCollection<BsonDocument>("tbl_usuario");
        private static IMongoCollection<BsonDocument> TiposUsuarioCollection => Database.GetCollection<BsonDocument>("tbl_tipo_usuario");
        private static IMongoCollection<BsonDocument> ProveedoresCollection => Database.GetCollection<BsonDocument>("tbl_proveedor");
        private static IMongoCollection<BsonDocument> ProductosCollection => Database.GetCollection<BsonDocument>("tbl_producto");
        private static IMongoCollection<BsonDocument> PathsCollection => Database.GetCollection<BsonDocument>("tbl_path");


        private static int GetNextSequence(IMongoCollection<BsonDocument> collection, string idFieldName)
        {
            var sort = Builders<BsonDocument>.Sort.Descending(idFieldName);
            var filter = Builders<BsonDocument>.Filter.Exists(idFieldName);
            var doc = collection.Find(filter).Sort(sort).Limit(1).FirstOrDefault();
            if (doc == null || !doc.Contains(idFieldName))
            {
                return 1;
            }
            return doc[idFieldName].AsInt32 + 1;
        }

        private static string GetStringOrEmpty(BsonDocument doc, string fieldName)
        {
            return doc.Contains(fieldName) && !doc[fieldName].IsBsonNull ? doc[fieldName].AsString : string.Empty;
        }

        #region Mappings
        private static BsonDocument ToBsonTipoUsuario(tbl_tipo_usuario tu)
        {
            if (tu == null) return null;
            return new BsonDocument
            {
                { "tusu_id", tu.tusu_id },
                { "tusu_nombre", tu.tusu_nombre ?? string.Empty },
                { "tusu_estado", tu.tusu_estado?.ToString() ?? "A" }
            };
        }

        private static tbl_tipo_usuario FromBsonTipoUsuario(BsonDocument doc)
        {
            if (doc == null) return null;
            string estadoStr = GetStringOrEmpty(doc, "tusu_estado");
            return new tbl_tipo_usuario
            {
                tusu_id = doc["tusu_id"].AsInt32,
                tusu_nombre = GetStringOrEmpty(doc, "tusu_nombre"),
                tusu_estado = !string.IsNullOrEmpty(estadoStr) ? estadoStr[0] : 'A'
            };
        }

        private static BsonDocument ToBsonUsuario(tbl_usuario u)
        {
            if (u == null) return null;
            byte[] passBytes = u.usu_contraseña != null ? u.usu_contraseña.ToArray() : null;
            return new BsonDocument
            {
                { "usu_id", u.usu_id },
                { "usu_cedula", u.usu_cedula ?? string.Empty },
                { "usu_nombres", u.usu_nombres ?? string.Empty },
                { "usu_apellidos", u.usu_apellidos ?? string.Empty },
                { "usu_direcciones", u.usu_direcciones ?? string.Empty },
                { "usu_celular", u.usu_celular ?? string.Empty },
                { "usu_correo", u.usu_correo ?? string.Empty },
                { "usu_fecha_creacion", u.usu_fecha_creacion.HasValue ? (BsonValue)u.usu_fecha_creacion.Value : BsonNull.Value },
                { "usu_fecha_cumple", u.usu_fecha_cumple.HasValue ? (BsonValue)u.usu_fecha_cumple.Value : BsonNull.Value },
                { "usu_nick", u.usu_nick ?? string.Empty },
                { "usu_contraseña", passBytes != null ? (BsonValue)new BsonBinaryData(passBytes) : BsonNull.Value },
                { "usu_intentos", u.usu_intentos.HasValue ? (BsonValue)u.usu_intentos.Value : BsonNull.Value },
                { "usu_codigo_OTP", u.usu_codigo_OTP ?? string.Empty },
                { "usu_estado", u.usu_estado?.ToString() ?? "A" },
                { "tusu_id", u.tusu_id.HasValue ? (BsonValue)u.tusu_id.Value : BsonNull.Value },
                { "usu_fecha_ultimo_intento", u.usu_fecha_ultimo_intento.HasValue ? (BsonValue)u.usu_fecha_ultimo_intento.Value : BsonNull.Value },
                { "usu_imagen", u.usu_imagen ?? string.Empty },
                { "usu_qr_key", u.usu_qr_key ?? string.Empty }
            };
        }

        private static tbl_usuario FromBsonUsuario(BsonDocument doc)
        {
            if (doc == null) return null;
            string estadoStr = GetStringOrEmpty(doc, "usu_estado");
            var u = new tbl_usuario
            {
                usu_id = doc["usu_id"].AsInt32,
                usu_cedula = GetStringOrEmpty(doc, "usu_cedula"),
                usu_nombres = GetStringOrEmpty(doc, "usu_nombres"),
                usu_apellidos = GetStringOrEmpty(doc, "usu_apellidos"),
                usu_direcciones = GetStringOrEmpty(doc, "usu_direcciones"),
                usu_celular = GetStringOrEmpty(doc, "usu_celular"),
                usu_correo = GetStringOrEmpty(doc, "usu_correo"),
                usu_fecha_creacion = doc.Contains("usu_fecha_creacion") && !doc["usu_fecha_creacion"].IsBsonNull ? (DateTime?)doc["usu_fecha_creacion"].ToUniversalTime().ToLocalTime() : null,
                usu_fecha_cumple = doc.Contains("usu_fecha_cumple") && !doc["usu_fecha_cumple"].IsBsonNull ? (DateTime?)doc["usu_fecha_cumple"].ToUniversalTime().ToLocalTime() : null,
                usu_nick = GetStringOrEmpty(doc, "usu_nick"),
                usu_contraseña = doc.Contains("usu_contraseña") && !doc["usu_contraseña"].IsBsonNull ? new System.Data.Linq.Binary(doc["usu_contraseña"].AsByteArray) : null,
                usu_intentos = doc.Contains("usu_intentos") && !doc["usu_intentos"].IsBsonNull ? (int?)doc["usu_intentos"].AsInt32 : null,
                usu_codigo_OTP = GetStringOrEmpty(doc, "usu_codigo_OTP"),
                usu_estado = !string.IsNullOrEmpty(estadoStr) ? estadoStr[0] : 'A',
                tusu_id = doc.Contains("tusu_id") && !doc["tusu_id"].IsBsonNull ? (int?)doc["tusu_id"].AsInt32 : null,
                usu_fecha_ultimo_intento = doc.Contains("usu_fecha_ultimo_intento") && !doc["usu_fecha_ultimo_intento"].IsBsonNull ? (DateTime?)doc["usu_fecha_ultimo_intento"].ToUniversalTime().ToLocalTime() : null,
                usu_imagen = GetStringOrEmpty(doc, "usu_imagen"),
                usu_qr_key = GetStringOrEmpty(doc, "usu_qr_key")
            };

            // Resolve role relation
            if (u.tusu_id.HasValue)
            {
                var roleDoc = TiposUsuarioCollection.Find(Builders<BsonDocument>.Filter.Eq("tusu_id", u.tusu_id.Value)).FirstOrDefault();
                if (roleDoc != null)
                {
                    u.tbl_tipo_usuario = FromBsonTipoUsuario(roleDoc);
                }
            }
            return u;
        }

        private static BsonDocument ToBsonProveedor(tbl_proveedor p)
        {
            if (p == null) return null;
            return new BsonDocument
            {
                { "prov_id", p.prov_id },
                { "prov_nombre", p.prov_nombre ?? string.Empty },
                { "prov_estado", p.prov_estado?.ToString() ?? "A" }
            };
        }

        private static tbl_proveedor FromBsonProveedor(BsonDocument doc)
        {
            if (doc == null) return null;
            string estadoStr = GetStringOrEmpty(doc, "prov_estado");
            return new tbl_proveedor
            {
                prov_id = doc["prov_id"].AsInt32,
                prov_nombre = GetStringOrEmpty(doc, "prov_nombre"),
                prov_estado = !string.IsNullOrEmpty(estadoStr) ? estadoStr[0] : 'A'
            };
        }

        private static BsonDocument ToBsonProducto(tbl_producto p)
        {
            if (p == null) return null;
            return new BsonDocument
            {
                { "pro_id", p.pro_id },
                { "pro_nombre", p.pro_nombre ?? string.Empty },
                { "pro_cantidad", p.pro_cantidad.HasValue ? (BsonValue)p.pro_cantidad.Value : BsonNull.Value },
                { "pro_precio", p.pro_precio.HasValue ? (BsonValue)p.pro_precio.Value : BsonNull.Value },
                { "pro_estado", p.pro_estado?.ToString() ?? "A" },
                { "prov_id", p.prov_id.HasValue ? (BsonValue)p.prov_id.Value : BsonNull.Value },
                { "pro_categoria", p.pro_categoria ?? string.Empty },
                { "pro_prov_id_backup", p.pro_prov_id_backup.HasValue ? (BsonValue)p.pro_prov_id_backup.Value : BsonNull.Value }
            };
        }

        private static tbl_producto FromBsonProducto(BsonDocument doc)
        {
            if (doc == null) return null;
            string estadoStr = GetStringOrEmpty(doc, "pro_estado");
            var prod = new tbl_producto
            {
                pro_id = doc["pro_id"].AsInt32,
                pro_nombre = GetStringOrEmpty(doc, "pro_nombre"),
                pro_cantidad = doc.Contains("pro_cantidad") && !doc["pro_cantidad"].IsBsonNull ? (int?)doc["pro_cantidad"].AsInt32 : null,
                pro_precio = doc.Contains("pro_precio") && !doc["pro_precio"].IsBsonNull ? (decimal?)doc["pro_precio"].AsDecimal : null,
                pro_estado = !string.IsNullOrEmpty(estadoStr) ? estadoStr[0] : 'A',
                prov_id = doc.Contains("prov_id") && !doc["prov_id"].IsBsonNull ? (int?)doc["prov_id"].AsInt32 : null,
                pro_categoria = GetStringOrEmpty(doc, "pro_categoria"),
                pro_prov_id_backup = doc.Contains("pro_prov_id_backup") && !doc["pro_prov_id_backup"].IsBsonNull ? (int?)doc["pro_prov_id_backup"].AsInt32 : null
            };

            // Resolve relations
            if (prod.prov_id.HasValue)
            {
                var provDoc = ProveedoresCollection.Find(Builders<BsonDocument>.Filter.Eq("prov_id", prod.prov_id.Value)).FirstOrDefault();
                if (provDoc != null)
                {
                    prod.tbl_proveedor = FromBsonProveedor(provDoc);
                }
            }

            var pathDocs = PathsCollection.Find(Builders<BsonDocument>.Filter.Eq("pro_id", prod.pro_id)).ToList();
            foreach (var pd in pathDocs)
            {
                prod.tbl_path.Add(FromBsonPath(pd));
            }

            return prod;
        }

        private static BsonDocument ToBsonPath(tbl_path p)
        {
            if (p == null) return null;
            return new BsonDocument
            {
                { "path_id", p.path_id },
                { "pro_id", p.pro_id },
                { "path_ruta", p.path_ruta ?? string.Empty }
            };
        }

        private static tbl_path FromBsonPath(BsonDocument doc)
        {
            if (doc == null) return null;
            return new tbl_path
            {
                path_id = doc["path_id"].AsInt32,
                pro_id = doc["pro_id"].AsInt32,
                path_ruta = GetStringOrEmpty(doc, "path_ruta")
            };
        }
        #endregion

        #region Roles (tbl_tipo_usuario) Operations
        public static List<tbl_tipo_usuario> ListarTiposUsuario()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("tusu_estado", "A");
            var list = TiposUsuarioCollection.Find(filter).ToList();
            return list.Select(FromBsonTipoUsuario).ToList();
        }

        public static int ObtenerIdPredeterminadoTipoUsuario()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("tusu_estado", "A");
            var doc = TiposUsuarioCollection.Find(filter).FirstOrDefault();
            if (doc != null)
            {
                return doc["tusu_id"].AsInt32;
            }

            // Fallback emergency creation
            int nextId = GetNextSequence(TiposUsuarioCollection, "tusu_id");
            var nuevo = new tbl_tipo_usuario { tusu_id = nextId, tusu_nombre = "Usuario Estándar", tusu_estado = 'A' };
            TiposUsuarioCollection.InsertOne(ToBsonTipoUsuario(nuevo));
            return nextId;
        }

        public static int ObtenerIdUsuarioNormal()
        {
            var list = TiposUsuarioCollection.Find(Builders<BsonDocument>.Filter.Eq("tusu_estado", "A")).ToList().Select(FromBsonTipoUsuario).ToList();
            var normal = list.FirstOrDefault(t => t.tusu_nombre != null && t.tusu_nombre.ToLower().Contains("usuario") && !t.tusu_nombre.ToLower().Contains("admin"));
            if (normal != null) return normal.tusu_id;
            if (list.Count > 0) return list.OrderByDescending(t => t.tusu_id).First().tusu_id;
            return 2;
        }
        #endregion

        #region Users (tbl_usuario) Operations
        public static int InsertarUsuario(tbl_usuario usuario, string plainPassword)
        {
            usuario.usu_id = GetNextSequence(UsuariosCollection, "usu_id");
            usuario.usu_contraseña = new System.Data.Linq.Binary(EncriptarPassword(plainPassword));
            UsuariosCollection.InsertOne(ToBsonUsuario(usuario));
            return usuario.usu_id;
        }

        public static tbl_usuario AutenticarUsuario(string nickOrEmail, string password)
        {
            var filter = Builders<BsonDocument>.Filter.Or(
                Builders<BsonDocument>.Filter.Eq("usu_nick", nickOrEmail),
                Builders<BsonDocument>.Filter.Eq("usu_correo", nickOrEmail)
            );
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc == null) return null;

            var user = FromBsonUsuario(doc);
            if (user.usu_estado == 'I') throw new Exception("Cuenta bloqueada.");

            string passDecrypted = DesencriptarPassword(user.usu_contraseña.ToArray());
            if (passDecrypted == password)
            {
                user.usu_intentos = 0;
                var update = Builders<BsonDocument>.Update.Set("usu_intentos", 0);
                UsuariosCollection.UpdateOne(filter, update);
                return user;
            }
            else
            {
                user.usu_intentos = (user.usu_intentos ?? 0) + 1;
                var update = Builders<BsonDocument>.Update.Set("usu_intentos", user.usu_intentos.Value);
                if (user.usu_intentos >= 3)
                {
                    user.usu_estado = 'I';
                    update = update.Set("usu_estado", "I");
                }
                UsuariosCollection.UpdateOne(filter, update);
                throw new Exception("Incorrecto. Intentos: " + user.usu_intentos);
            }
        }

        public static tbl_usuario AutenticarConQR(string qrKey)
        {
            var doc = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_qr_key", qrKey)).FirstOrDefault();
            if (doc != null)
            {
                var user = FromBsonUsuario(doc);
                if (user.usu_estado != 'I')
                {
                    var filter = Builders<BsonDocument>.Filter.Eq("usu_id", user.usu_id);
                    var update = Builders<BsonDocument>.Update.Set("usu_intentos", 0);
                    UsuariosCollection.UpdateOne(filter, update);
                    user.usu_intentos = 0;
                    return user;
                }
            }
            return null;
        }

        public static tbl_usuario AutenticarRedSocial(string correo, string nombres, string apellidos)
        {
            var doc = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_correo", correo)).FirstOrDefault();
            if (doc != null) return FromBsonUsuario(doc);

            int nextId = GetNextSequence(UsuariosCollection, "usu_id");
            var nuevo = new tbl_usuario
            {
                usu_id = nextId,
                usu_correo = correo,
                usu_nombres = nombres ?? "Usuario",
                usu_nick = correo.Split('@')[0],
                usu_estado = 'A',
                usu_fecha_creacion = DateTime.Now,
                usu_intentos = 0,
                tusu_id = 2,
                usu_qr_key = Guid.NewGuid().ToString()
            };
            UsuariosCollection.InsertOne(ToBsonUsuario(nuevo));
            return nuevo;
        }

        public static tbl_usuario ObtenerUsuarioPorId(int id)
        {
            var doc = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_id", id)).FirstOrDefault();
            return FromBsonUsuario(doc);
        }

        public static tbl_usuario ObtenerUsuarioPorCorreo(string correo)
        {
            var doc = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_correo", correo)).FirstOrDefault();
            return FromBsonUsuario(doc);
        }

        public static tbl_usuario ObtenerUsuarioPorNick(string nick)
        {
            var doc = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_nick", nick)).FirstOrDefault();
            return FromBsonUsuario(doc);
        }

        public static List<tbl_usuario> ObtenerTodosUsuarios()
        {
            var list = UsuariosCollection.Find(new BsonDocument()).ToList();
            return list.Select(FromBsonUsuario).ToList();
        }

        public static List<tbl_usuario> ObtenerUsuariosBloqueados()
        {
            var list = UsuariosCollection.Find(Builders<BsonDocument>.Filter.Eq("usu_estado", "I")).ToList();
            return list.Select(FromBsonUsuario).ToList();
        }

        public static void DesbloquearUsuario(int usuId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            var update = Builders<BsonDocument>.Update.Set("usu_estado", "A").Set("usu_intentos", 0);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void ActualizarPassword(int usuId, string newPassword)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            byte[] enc = EncriptarPassword(newPassword);
            var update = Builders<BsonDocument>.Update.Set("usu_contraseña", new BsonBinaryData(enc));
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void ActualizarOTP(int usuId, string otp)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            var update = Builders<BsonDocument>.Update.Set("usu_codigo_OTP", otp);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void ActualizarQRKey(int usuId, string newQRKey)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            var update = Builders<BsonDocument>.Update.Set("usu_qr_key", newQRKey);
            UsuariosCollection.UpdateOne(filter, update);
        }
        #endregion

        #region Providers (tbl_proveedor) Operations
        public static List<tbl_proveedor> ObtenerTodosProveedores()
        {
            var list = ProveedoresCollection.Find(new BsonDocument()).ToList();
            return list.Select(FromBsonProveedor).ToList();
        }

        public static tbl_proveedor ObtenerProveedorPorId(int id)
        {
            var doc = ProveedoresCollection.Find(Builders<BsonDocument>.Filter.Eq("prov_id", id)).FirstOrDefault();
            return FromBsonProveedor(doc);
        }

        public static void InsertarProveedor(tbl_proveedor prov)
        {
            prov.prov_id = GetNextSequence(ProveedoresCollection, "prov_id");
            prov.prov_estado = 'A';
            ProveedoresCollection.InsertOne(ToBsonProveedor(prov));
        }

        public static void ActualizarProveedor(tbl_proveedor prov)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("prov_id", prov.prov_id);
            var update = Builders<BsonDocument>.Update
                .Set("prov_nombre", prov.prov_nombre ?? string.Empty)
                .Set("prov_estado", prov.prov_estado?.ToString() ?? "A");
            ProveedoresCollection.UpdateOne(filter, update);
        }

        public static void EliminarLogicoProveedor(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            var update = Builders<BsonDocument>.Update.Set("prov_estado", "I");
            ProveedoresCollection.UpdateOne(filter, update);

            // Detach products
            var prodFilter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            var prodUpdate = Builders<BsonDocument>.Update
                .Set("pro_prov_id_backup", id)
                .Set("prov_id", BsonNull.Value);
            ProductosCollection.UpdateMany(prodFilter, prodUpdate);
        }

        public static void RestaurarProveedor(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            var update = Builders<BsonDocument>.Update.Set("prov_estado", "A");
            ProveedoresCollection.UpdateOne(filter, update);

            // Reattach products
            var prodFilter = Builders<BsonDocument>.Filter.Eq("pro_prov_id_backup", id);
            var prodUpdate = Builders<BsonDocument>.Update
                .Set("prov_id", id)
                .Set("pro_prov_id_backup", BsonNull.Value);
            ProductosCollection.UpdateMany(prodFilter, prodUpdate);
        }

        public static void EliminarFisicoProveedor(int id)
        {
            // Detach products first
            var prodFilter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            var prodUpdate = Builders<BsonDocument>.Update.Set("prov_id", BsonNull.Value);
            ProductosCollection.UpdateMany(prodFilter, prodUpdate);

            // Delete provider
            var filter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            ProveedoresCollection.DeleteOne(filter);
        }
        #endregion

        #region Products (tbl_producto) Operations
        public static List<tbl_producto> ObtenerTodosProductos()
        {
            var list = ProductosCollection.Find(new BsonDocument()).ToList();
            return list.Select(FromBsonProducto).OrderByDescending(p => p.pro_id).ToList();
        }

        public static tbl_producto ObtenerProductoPorId(int id)
        {
            var doc = ProductosCollection.Find(Builders<BsonDocument>.Filter.Eq("pro_id", id)).FirstOrDefault();
            return FromBsonProducto(doc);
        }

        public static List<tbl_producto> ObtenerProductosConFiltros(string keyword, string category, int? provId)
        {
            var filterBuilder = Builders<BsonDocument>.Filter;
            var filter = filterBuilder.Eq("pro_estado", "A");

            if (!string.IsNullOrEmpty(keyword))
            {
                var regex = new BsonRegularExpression(keyword, "i");
                var keywordFilter = filterBuilder.Or(
                    filterBuilder.Regex("pro_nombre", regex),
                    filterBuilder.Regex("pro_categoria", regex)
                );
                filter = filterBuilder.And(filter, keywordFilter);
            }

            if (!string.IsNullOrEmpty(category) && category != "TODAS")
            {
                filter = filterBuilder.And(filter, filterBuilder.Eq("pro_categoria", category));
            }

            if (provId.HasValue && provId.Value > 0)
            {
                filter = filterBuilder.And(filter, filterBuilder.Eq("prov_id", provId.Value));
            }

            var list = ProductosCollection.Find(filter).ToList();
            return list.Select(FromBsonProducto).OrderByDescending(p => p.pro_id).ToList();
        }

        public static List<string> ObtenerCategoriasProductos()
        {
            var list = ProductosCollection.Find(new BsonDocument()).ToList();
            return list.Select(d => GetStringOrEmpty(d, "pro_categoria"))
                       .Where(c => !string.IsNullOrEmpty(c))
                       .Distinct()
                       .ToList();
        }

        public static void InsertarProducto(tbl_producto prod, List<string> imagePaths)
        {
            prod.pro_id = GetNextSequence(ProductosCollection, "pro_id");
            prod.pro_estado = 'A';
            ProductosCollection.InsertOne(ToBsonProducto(prod));

            if (imagePaths != null)
            {
                foreach (var path in imagePaths)
                {
                    if (!string.IsNullOrEmpty(path))
                    {
                        var img = new tbl_path
                        {
                            path_id = GetNextSequence(PathsCollection, "path_id"),
                            pro_id = prod.pro_id,
                            path_ruta = path
                        };
                        PathsCollection.InsertOne(ToBsonPath(img));
                    }
                }
            }
        }

        public static void ActualizarProducto(tbl_producto prod, List<string> imagePaths)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_id", prod.pro_id);
            var update = Builders<BsonDocument>.Update
                .Set("pro_nombre", prod.pro_nombre ?? string.Empty)
                .Set("pro_cantidad", prod.pro_cantidad.HasValue ? (BsonValue)prod.pro_cantidad.Value : BsonNull.Value)
                .Set("pro_precio", prod.pro_precio.HasValue ? (BsonValue)prod.pro_precio.Value : BsonNull.Value)
                .Set("pro_categoria", prod.pro_categoria ?? string.Empty)
                .Set("prov_id", prod.prov_id.HasValue ? (BsonValue)prod.prov_id.Value : BsonNull.Value)
                .Set("pro_estado", prod.pro_estado?.ToString() ?? "A");
            ProductosCollection.UpdateOne(filter, update);

            // Clear paths and insert new ones
            var pathFilter = Builders<BsonDocument>.Filter.Eq("pro_id", prod.pro_id);
            PathsCollection.DeleteMany(pathFilter);

            if (imagePaths != null)
            {
                foreach (var path in imagePaths)
                {
                    if (!string.IsNullOrEmpty(path))
                    {
                        var img = new tbl_path
                        {
                            path_id = GetNextSequence(PathsCollection, "path_id"),
                            pro_id = prod.pro_id,
                            path_ruta = path
                        };
                        PathsCollection.InsertOne(ToBsonPath(img));
                    }
                }
            }
        }

        public static void EliminarProducto(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_id", id);
            ProductosCollection.DeleteOne(filter);

            var pathFilter = Builders<BsonDocument>.Filter.Eq("pro_id", id);
            PathsCollection.DeleteMany(pathFilter);
        }

        public static void ReiniciarTablaPath()
        {
            PathsCollection.DeleteMany(new BsonDocument());
        }
        #endregion

        #region Security & Encryption Wrappers
        public static byte[] EncriptarPassword(string password)
        {
            try
            {
                using (var dc = new DactaClasesDataContext())
                {
                    using (var cmd = dc.Connection.CreateCommand())
                    {
                        cmd.CommandText = "SELECT dbo.encriptacon(@pass)";
                        var p = cmd.CreateParameter();
                        p.ParameterName = "@pass";
                        p.Value = password;
                        cmd.Parameters.Add(p);
                        bool closed = dc.Connection.State == System.Data.ConnectionState.Closed;
                        if (closed) dc.Connection.Open();
                        byte[] result = (byte[])cmd.ExecuteScalar();
                        if (closed) dc.Connection.Close();
                        return result;
                    }
                }
            }
            catch
            {
                return System.Text.Encoding.UTF8.GetBytes(password);
            }
        }

        public static string DesencriptarPassword(byte[] encrypted)
        {
            try
            {
                using (var dc = new DactaClasesDataContext())
                {
                    using (var cmd = dc.Connection.CreateCommand())
                    {
                        cmd.CommandText = "SELECT dbo.desencriptacon(@pass)";
                        var p = cmd.CreateParameter();
                        p.ParameterName = "@pass";
                        p.Value = encrypted;
                        cmd.Parameters.Add(p);
                        bool closed = dc.Connection.State == System.Data.ConnectionState.Closed;
                        if (closed) dc.Connection.Open();
                        string result = (string)cmd.ExecuteScalar();
                        if (closed) dc.Connection.Close();
                        return result;
                    }
                }
            }
            catch
            {
                try
                {
                    return System.Text.Encoding.UTF8.GetString(encrypted);
                }
                catch
                {
                    return string.Empty;
                }
            }
        }
        #endregion

        #region SQL Server to MongoDB Migration Script
        public static void MigrateSQLToMongoDB()
        {
            // Only migrate if users collection is empty in MongoDB
            if (UsuariosCollection.CountDocuments(new BsonDocument()) > 0)
            {
                return;
            }

            try
            {
                using (var dc = new DactaClasesDataContext())
                {
                    // 1. Roles
                    var roles = dc.tbl_tipo_usuario.ToList();
                    if (roles.Count > 0)
                    {
                        var bsonRoles = roles.Select(ToBsonTipoUsuario).ToList();
                        TiposUsuarioCollection.InsertMany(bsonRoles);
                    }

                    // 2. Users
                    var users = dc.tbl_usuario.ToList();
                    if (users.Count > 0)
                    {
                        var bsonUsers = users.Select(ToBsonUsuario).ToList();
                        UsuariosCollection.InsertMany(bsonUsers);
                    }

                    // 3. Providers
                    var providers = dc.tbl_proveedor.ToList();
                    if (providers.Count > 0)
                    {
                        var bsonProviders = providers.Select(ToBsonProveedor).ToList();
                        ProveedoresCollection.InsertMany(bsonProviders);
                    }

                    // 4. Products
                    var products = dc.tbl_producto.ToList();
                    if (products.Count > 0)
                    {
                        var bsonProducts = products.Select(ToBsonProducto).ToList();
                        ProductosCollection.InsertMany(bsonProducts);
                    }

                    // 5. Paths
                    var paths = dc.tbl_path.ToList();
                    if (paths.Count > 0)
                    {
                        var bsonPaths = paths.Select(ToBsonPath).ToList();
                        PathsCollection.InsertMany(bsonPaths);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error during SQL to MongoDB migration: " + ex.Message);
            }
        }
        #endregion
    }
}
