/* =========================================================
   TECHSTORE - CREACIÓN DE BASE DE DATOS Y TABLAS
   ========================================================= */

CREATE DATABASE TechStoreTaller3;
GO

USE TechStoreTaller3;
GO

/* ======================== 1. CATEGORIAS ======================== */

CREATE TABLE Categorias (
    ID_Categoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL UNIQUE
);
GO

/* ======================== 2. PROVEEDORES ======================== */

CREATE TABLE Proveedores (
    ID_Proveedor INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL
);
GO

/* ======================== 3. SUCURSALES ======================== */

CREATE TABLE Sucursales (
    ID_Sucursal INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL
);
GO

/* ======================== 4. CLIENTES ======================== */

CREATE TABLE Clientes (
    ID_Cliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Ciudad VARCHAR(80) NOT NULL
);
GO

/* ======================== 5. EMPLEADOS ======================== */

CREATE TABLE Empleados (
    ID_Empleado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Cargo VARCHAR(60) NOT NULL,
    ID_Sucursal INT NOT NULL,

    CONSTRAINT FK_Empleados_Sucursales
        FOREIGN KEY (ID_Sucursal)
        REFERENCES Sucursales(ID_Sucursal)
);
GO

/* ======================== 6. PRODUCTOS ======================== */

CREATE TABLE Productos (
    ID_Producto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(120) NOT NULL,
    ID_Categoria INT NOT NULL,
    ID_Proveedor INT NOT NULL,
    Precio DECIMAL(12,2) NOT NULL CHECK (Precio > 0),

    CONSTRAINT FK_Productos_Categorias
        FOREIGN KEY (ID_Categoria)
        REFERENCES Categorias(ID_Categoria),

    CONSTRAINT FK_Productos_Proveedores
        FOREIGN KEY (ID_Proveedor)
        REFERENCES Proveedores(ID_Proveedor)
);
GO

/* ======================== 7. INVENTARIO ======================== */

CREATE TABLE Inventario (
    ID_Inventario INT IDENTITY(1,1) PRIMARY KEY,
    ID_Sucursal INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad >= 0),

    CONSTRAINT FK_Inventario_Sucursales
        FOREIGN KEY (ID_Sucursal)
        REFERENCES Sucursales(ID_Sucursal),

    CONSTRAINT FK_Inventario_Productos
        FOREIGN KEY (ID_Producto)
        REFERENCES Productos(ID_Producto),

    CONSTRAINT UQ_Inventario_Sucursal_Producto
        UNIQUE (ID_Sucursal, ID_Producto)
);
GO

/* ======================== 8. VENTAS ======================== */

CREATE TABLE Ventas (
    ID_Venta INT IDENTITY(1,1) PRIMARY KEY,
    ID_Cliente INT NOT NULL,
    ID_Empleado INT NOT NULL,
    ID_Sucursal INT NOT NULL,
    Fecha DATETIME2 NOT NULL,
    Estado VARCHAR(20) NOT NULL
        CHECK (Estado IN ('Completada', 'Cancelada')),

    CONSTRAINT FK_Ventas_Clientes
        FOREIGN KEY (ID_Cliente)
        REFERENCES Clientes(ID_Cliente),

    CONSTRAINT FK_Ventas_Empleados
        FOREIGN KEY (ID_Empleado)
        REFERENCES Empleados(ID_Empleado),

    CONSTRAINT FK_Ventas_Sucursales
        FOREIGN KEY (ID_Sucursal)
        REFERENCES Sucursales(ID_Sucursal)
);
GO

/* ======================== 9. DETALLES DE VENTA ======================== */

CREATE TABLE DetallesVenta (
    ID_Detalle INT IDENTITY(1,1) PRIMARY KEY,
    ID_Venta INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(12,2) NOT NULL CHECK (PrecioUnitario > 0),

    CONSTRAINT FK_DetallesVenta_Ventas
        FOREIGN KEY (ID_Venta)
        REFERENCES Ventas(ID_Venta),

    CONSTRAINT FK_DetallesVenta_Productos
        FOREIGN KEY (ID_Producto)
        REFERENCES Productos(ID_Producto)
);
GO

/* ======================== 10. PAGOS ======================== */

CREATE TABLE Pagos (
    ID_Pago INT IDENTITY(1,1) PRIMARY KEY,
    ID_Venta INT NOT NULL,
    Metodo VARCHAR(30) NOT NULL
        CHECK (Metodo IN ('Tarjeta', 'Transferencia', 'Efectivo')),
    Monto DECIMAL(12,2) NOT NULL CHECK (Monto >= 0),
    FechaPago DATETIME2 NOT NULL,

    CONSTRAINT FK_Pagos_Ventas
        FOREIGN KEY (ID_Venta)
        REFERENCES Ventas(ID_Venta)
);
GO
