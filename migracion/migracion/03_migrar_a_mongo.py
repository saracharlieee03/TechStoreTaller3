
import pyodbc
from pymongo import MongoClient
from decimal import Decimal


# =========================================================
# CONFIGURACIÓN
# =========================================================

SQL_SERVER = "CHARLIE"  # Cambiar si tu servidor tiene otro nombre
SQL_DATABASE = "TechStoreTaller3"

SQL_CONNECTION = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SQL_SERVER};"
    f"DATABASE={SQL_DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

MONGO_URI = "mongodb://localhost:27017/"
MONGO_DATABASE = "TechStoreTaller3"


# =========================================================
# CONVERSIÓN DE DATOS
# =========================================================

def convertir_valores(valor):
    """Convierte Decimal a float y procesa estructuras anidadas."""

    if isinstance(valor, Decimal):
        return float(valor)

    if isinstance(valor, dict):
        return {
            clave: convertir_valores(dato)
            for clave, dato in valor.items()
        }

    if isinstance(valor, list):
        return [convertir_valores(dato) for dato in valor]

    return valor


# =========================================================
# LECTURA DE SQL SERVER
# =========================================================

def obtener_registros(cursor, nombre_tabla):
    """Obtiene los registros de una tabla y los convierte en diccionarios."""

    cursor.execute(f"SELECT * FROM dbo.[{nombre_tabla}]")

    nombres_columnas = [
        columna[0] for columna in cursor.description
    ]

    registros = [
        dict(zip(nombres_columnas, fila))
        for fila in cursor.fetchall()
    ]

    return convertir_valores(registros)


# =========================================================
# MIGRACIÓN DE COLECCIONES INDEPENDIENTES
# =========================================================

def migrar_tabla(cursor, coleccion, nombre_tabla):
    """Migra una tabla SQL a una colección de MongoDB."""

    registros = obtener_registros(cursor, nombre_tabla)

    # Evita duplicar documentos si se ejecuta nuevamente.
    coleccion.delete_many({})

    if registros:
        coleccion.insert_many(registros)

    print(f"{nombre_tabla}: {len(registros)} registros migrados.")


# =========================================================
# MIGRACIÓN DE VENTAS CON DETALLES Y PAGOS EMBEBIDOS
# =========================================================

def migrar_ventas(cursor, base_mongo):
    """Construye cada venta incluyendo sus detalles y pagos."""

    ventas = obtener_registros(cursor, "Ventas")
    detalles = obtener_registros(cursor, "DetallesVenta")
    pagos = obtener_registros(cursor, "Pagos")

    # Comprobar que las tablas tengan la clave de relación.
    for nombre, registros in [
        ("Ventas", ventas),
        ("DetallesVenta", detalles),
        ("Pagos", pagos),
    ]:
        if registros and "ID_Venta" not in registros[0]:
            raise ValueError(
                f"La tabla {nombre} no contiene la columna ID_Venta."
            )

    # Agrupar los detalles por venta.
    detalles_por_venta = {}

    for detalle in detalles:
        id_venta = detalle["ID_Venta"]

        detalles_por_venta.setdefault(id_venta, []).append(detalle)

    # Agrupar los pagos por venta.
    pagos_por_venta = {}

    for pago in pagos:
        id_venta = pago["ID_Venta"]

        pagos_por_venta.setdefault(id_venta, []).append(pago)

    # Crear un documento por venta.
    documentos_ventas = []

    for venta in ventas:
        id_venta = venta["ID_Venta"]

        documento = venta.copy()

        documento["detalles"] = detalles_por_venta.get(
            id_venta, []
        )

        documento["pagos"] = pagos_por_venta.get(
            id_venta, []
        )

        documentos_ventas.append(
            convertir_valores(documento)
        )

    coleccion = base_mongo["ventas"]

    # Limpiar la colección antes de insertar los documentos nuevos.
    coleccion.delete_many({})

    if documentos_ventas:
        coleccion.insert_many(documentos_ventas)

    print(f"Ventas: {len(documentos_ventas)} documentos migrados.")
    print(f"Detalles incorporados: {len(detalles)}.")
    print(f"Pagos incorporados: {len(pagos)}.")


# =========================================================
# PROCESO PRINCIPAL
# =========================================================

def main():
    conexion_sql = None
    cliente_mongo = None

    try:
        # Conectar con SQL Server.
        print("Conectando con SQL Server...")

        conexion_sql = pyodbc.connect(SQL_CONNECTION)
        cursor = conexion_sql.cursor()

        print("Conexión con SQL Server exitosa.")

        # Conectar con MongoDB.
        print("Conectando con MongoDB...")

        cliente_mongo = MongoClient(
            MONGO_URI,
            serverSelectionTimeoutMS=5000
        )

        # Verificar que MongoDB responda.
        cliente_mongo.admin.command("ping")

        base_mongo = cliente_mongo[MONGO_DATABASE]

        print("Conexión con MongoDB exitosa.")

        # Migrar las tablas que quedan como colecciones independientes.
        tablas_independientes = [
            "Categorias",
            "Proveedores",
            "Sucursales",
            "Clientes",
            "Empleados",
            "Productos",
            "Inventario",
        ]

        for tabla in tablas_independientes:
            migrar_tabla(
                cursor,
                base_mongo[tabla.lower()],
                tabla
            )

        # Migrar ventas y embeber sus detalles y pagos.
        migrar_ventas(cursor, base_mongo)

        # Mostrar la cantidad final de documentos por colección.
        print("\nConteo final en MongoDB:")

        nombres_colecciones = [
            "categorias",
            "proveedores",
            "sucursales",
            "clientes",
            "empleados",
            "productos",
            "inventario",
            "ventas",
        ]

        for nombre in nombres_colecciones:
            cantidad = base_mongo[nombre].count_documents({})
            print(f"{nombre}: {cantidad} documentos")

        print("\nMigración terminada correctamente.")

    except pyodbc.Error as error:
        print("\nError de conexión o consulta en SQL Server:")
        print(error)

    except Exception as error:
        print("\nOcurrió un error durante la migración:")
        print(error)

    finally:
        # Cerrar conexiones aunque ocurra un error.
        if conexion_sql is not None:
            conexion_sql.close()

        if cliente_mongo is not None:
            cliente_mongo.close()


# Ejecutar el proceso.
if __name__ == "__main__":
    main()
