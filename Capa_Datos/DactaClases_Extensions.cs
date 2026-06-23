using System;
using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace Capa_Datos
{
    public partial class DactaClasesDataContext
    {
        public System.Data.Linq.Table<tbl_proveedor> tbl_proveedor
        {
            get { return this.GetTable<tbl_proveedor>(); }
        }

        public System.Data.Linq.Table<tbl_producto> tbl_producto
        {
            get { return this.GetTable<tbl_producto>(); }
        }

        public System.Data.Linq.Table<tbl_path> tbl_path
        {
            get { return this.GetTable<tbl_path>(); }
        }
    }

    [Table(Name = "dbo.tbl_proveedor")]
    public partial class tbl_proveedor
    {
        private int _prov_id;
        private string _prov_nombre;
        private System.Nullable<char> _prov_estado;
        private EntitySet<tbl_producto> _tbl_producto;

        public tbl_proveedor()
        {
            this._tbl_producto = new EntitySet<tbl_producto>(
                new Action<tbl_producto>(this.attach_tbl_producto), 
                new Action<tbl_producto>(this.detach_tbl_producto)
            );
        }

        [Column(Storage = "_prov_id", AutoSync = AutoSync.OnInsert, DbType = "Int NOT NULL IDENTITY", IsPrimaryKey = true, IsDbGenerated = true)]
        public int prov_id
        {
            get { return this._prov_id; }
            set { this._prov_id = value; }
        }

        [Column(Storage = "_prov_nombre", DbType = "VarChar(50)")]
        public string prov_nombre
        {
            get { return this._prov_nombre; }
            set { this._prov_nombre = value; }
        }

        [Column(Storage = "_prov_estado", DbType = "Char(1)")]
        public System.Nullable<char> prov_estado
        {
            get { return this._prov_estado; }
            set { this._prov_estado = value; }
        }

        [Association(Name = "FK_tbl_producto_tbl_proveedor", Storage = "_tbl_producto", ThisKey = "prov_id", OtherKey = "prov_id")]
        public EntitySet<tbl_producto> tbl_producto
        {
            get { return this._tbl_producto; }
            set { this._tbl_producto.Assign(value); }
        }

        private void attach_tbl_producto(tbl_producto entity)
        {
            entity.tbl_proveedor = this;
        }

        private void detach_tbl_producto(tbl_producto entity)
        {
            entity.tbl_proveedor = null;
        }
    }

    [Table(Name = "dbo.tbl_producto")]
    public partial class tbl_producto
    {
        private int _pro_id;
        private string _pro_nombre;
        private System.Nullable<int> _pro_cantidad;
        private System.Nullable<decimal> _pro_precio;
        private System.Nullable<char> _pro_estado;
        private System.Nullable<int> _prov_id;
        private string _pro_categoria;
        private System.Nullable<int> _pro_prov_id_backup;

        private EntityRef<tbl_proveedor> _tbl_proveedor;
        private EntitySet<tbl_path> _tbl_path;

        public tbl_producto()
        {
            this._tbl_proveedor = default(EntityRef<tbl_proveedor>);
            this._tbl_path = new EntitySet<tbl_path>(
                new Action<tbl_path>(this.attach_tbl_path),
                new Action<tbl_path>(this.detach_tbl_path)
            );
        }

        [Column(Storage = "_pro_id", AutoSync = AutoSync.OnInsert, DbType = "Int NOT NULL IDENTITY", IsPrimaryKey = true, IsDbGenerated = true)]
        public int pro_id
        {
            get { return this._pro_id; }
            set { this._pro_id = value; }
        }

        [Column(Storage = "_pro_nombre", DbType = "VarChar(50)")]
        public string pro_nombre
        {
            get { return this._pro_nombre; }
            set { this._pro_nombre = value; }
        }

        [Column(Storage = "_pro_cantidad", DbType = "Int")]
        public System.Nullable<int> pro_cantidad
        {
            get { return this._pro_cantidad; }
            set { this._pro_cantidad = value; }
        }

        [Column(Storage = "_pro_precio", DbType = "Decimal(9,2)")]
        public System.Nullable<decimal> pro_precio
        {
            get { return this._pro_precio; }
            set { this._pro_precio = value; }
        }

        [Column(Storage = "_pro_estado", DbType = "Char(1)")]
        public System.Nullable<char> pro_estado
        {
            get { return this._pro_estado; }
            set { this._pro_estado = value; }
        }

        [Column(Storage = "_prov_id", DbType = "Int")]
        public System.Nullable<int> prov_id
        {
            get { return this._prov_id; }
            set { this._prov_id = value; }
        }

        [Column(Storage = "_pro_categoria", DbType = "VarChar(50)")]
        public string pro_categoria
        {
            get { return this._pro_categoria; }
            set { this._pro_categoria = value; }
        }

        [Column(Storage = "_pro_prov_id_backup", DbType = "Int")]
        public System.Nullable<int> pro_prov_id_backup
        {
            get { return this._pro_prov_id_backup; }
            set { this._pro_prov_id_backup = value; }
        }

        [Association(Name = "FK_tbl_producto_tbl_proveedor", Storage = "_tbl_proveedor", ThisKey = "prov_id", OtherKey = "prov_id", IsForeignKey = true)]
        public tbl_proveedor tbl_proveedor
        {
            get { return this._tbl_proveedor.Entity; }
            set
            {
                tbl_proveedor previousValue = this._tbl_proveedor.Entity;
                if (((previousValue != value) || (this._tbl_proveedor.HasLoadedOrAssignedValue == false)))
                {
                    if ((previousValue != null))
                    {
                        this._tbl_proveedor.Entity = null;
                        previousValue.tbl_producto.Remove(this);
                    }
                    this._tbl_proveedor.Entity = value;
                    if ((value != null))
                    {
                        value.tbl_producto.Add(this);
                        this._prov_id = value.prov_id;
                    }
                    else
                    {
                        this._prov_id = default(Nullable<int>);
                    }
                }
            }
        }

        [Association(Name = "FK_tbl_path_tbl_producto", Storage = "_tbl_path", ThisKey = "pro_id", OtherKey = "pro_id")]
        public EntitySet<tbl_path> tbl_path
        {
            get { return this._tbl_path; }
            set { this._tbl_path.Assign(value); }
        }

        private void attach_tbl_path(tbl_path entity)
        {
            entity.tbl_producto = this;
        }

        private void detach_tbl_path(tbl_path entity)
        {
            entity.tbl_producto = null;
        }
    }

    [Table(Name = "dbo.tbl_path")]
    public partial class tbl_path
    {
        private int _path_id;
        private int _pro_id;
        private string _path_ruta;
        private EntityRef<tbl_producto> _tbl_producto;

        public tbl_path()
        {
            this._tbl_producto = default(EntityRef<tbl_producto>);
        }

        [Column(Storage = "_path_id", AutoSync = AutoSync.OnInsert, DbType = "Int NOT NULL IDENTITY", IsPrimaryKey = true, IsDbGenerated = true)]
        public int path_id
        {
            get { return this._path_id; }
            set { this._path_id = value; }
        }

        [Column(Storage = "_pro_id", DbType = "Int NOT NULL")]
        public int pro_id
        {
            get { return this._pro_id; }
            set { this._pro_id = value; }
        }

        [Column(Storage = "_path_ruta", DbType = "VarChar(500) NOT NULL", CanBeNull = false)]
        public string path_ruta
        {
            get { return this._path_ruta; }
            set { this._path_ruta = value; }
        }

        [Association(Name = "FK_tbl_path_tbl_producto", Storage = "_tbl_producto", ThisKey = "pro_id", OtherKey = "pro_id", IsForeignKey = true)]
        public tbl_producto tbl_producto
        {
            get { return this._tbl_producto.Entity; }
            set
            {
                tbl_producto previousValue = this._tbl_producto.Entity;
                if (((previousValue != value) || (this._tbl_producto.HasLoadedOrAssignedValue == false)))
                {
                    if ((previousValue != null))
                    {
                        this._tbl_producto.Entity = null;
                        previousValue.tbl_path.Remove(this);
                    }
                    this._tbl_producto.Entity = value;
                    if ((value != null))
                    {
                        value.tbl_path.Add(this);
                        this._pro_id = value.pro_id;
                    }
                    else
                    {
                        this._pro_id = default(int);
                    }
                }
            }
        }
    }
}
