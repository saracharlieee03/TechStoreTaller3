CREATE DATABASE TechStoreTaller3;
GO

USE TechStoreTaller3;
GO

/* ======================== CREACIÓN DE TABLAS ======================== */

CREATE TABLE Categorias (
    ID_Categoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL UNIQUE
);
GO

CREATE TABLE Proveedores (
    ID_Proveedor INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL
);
GO

CREATE TABLE Sucursales (
    ID_Sucursal INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL
);
GO

CREATE TABLE Clientes (
    ID_Cliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Ciudad VARCHAR(80) NOT NULL
);
GO

CREATE TABLE Empleados (
    ID_Empleado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Cargo VARCHAR(60) NOT NULL,
    ID_Sucursal INT NOT NULL,
    CONSTRAINT FK_Empleados_Sucursales
        FOREIGN KEY (ID_Sucursal) REFERENCES Sucursales(ID_Sucursal)
);
GO

CREATE TABLE Productos (
    ID_Producto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(120) NOT NULL,
    ID_Categoria INT NOT NULL,
    ID_Proveedor INT NOT NULL,
    Precio DECIMAL(12,2) NOT NULL CHECK (Precio > 0),
    CONSTRAINT FK_Productos_Categorias
        FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID_Categoria),
    CONSTRAINT FK_Productos_Proveedores
        FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor)
);
GO

CREATE TABLE Inventario (
    ID_Inventario INT IDENTITY(1,1) PRIMARY KEY,
    ID_Sucursal INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad >= 0),
    CONSTRAINT FK_Inventario_Sucursales
        FOREIGN KEY (ID_Sucursal) REFERENCES Sucursales(ID_Sucursal),
    CONSTRAINT FK_Inventario_Productos
        FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto),
    CONSTRAINT UQ_Inventario_Sucursal_Producto UNIQUE (ID_Sucursal, ID_Producto)
);
GO

CREATE TABLE Ventas (
    ID_Venta INT IDENTITY(1,1) PRIMARY KEY,
    ID_Cliente INT NOT NULL,
    ID_Empleado INT NOT NULL,
    ID_Sucursal INT NOT NULL,
    Fecha DATETIME2 NOT NULL,
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Completada','Cancelada')),
    CONSTRAINT FK_Ventas_Clientes
        FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID_Cliente),
    CONSTRAINT FK_Ventas_Empleados
        FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID_Empleado),
    CONSTRAINT FK_Ventas_Sucursales
        FOREIGN KEY (ID_Sucursal) REFERENCES Sucursales(ID_Sucursal)
);
GO

CREATE TABLE DetallesVenta (
    ID_Detalle INT IDENTITY(1,1) PRIMARY KEY,
    ID_Venta INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(12,2) NOT NULL CHECK (PrecioUnitario > 0),
    CONSTRAINT FK_DetallesVenta_Ventas
        FOREIGN KEY (ID_Venta) REFERENCES Ventas(ID_Venta),
    CONSTRAINT FK_DetallesVenta_Productos
        FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto)
);
GO

CREATE TABLE Pagos (
    ID_Pago INT IDENTITY(1,1) PRIMARY KEY,
    ID_Venta INT NOT NULL,
    Metodo VARCHAR(30) NOT NULL CHECK (Metodo IN ('Tarjeta','Transferencia','Efectivo')),
    Monto DECIMAL(12,2) NOT NULL CHECK (Monto >= 0),
    FechaPago DATETIME2 NOT NULL,
    CONSTRAINT FK_Pagos_Ventas
        FOREIGN KEY (ID_Venta) REFERENCES Ventas(ID_Venta)
);
GO

/* ======================== INSERCIÓN DE DATOS ======================== */

INSERT INTO Categorias (Nombre) VALUES
('Computadores'), ('Portatiles'), ('Monitores'), ('Teclados'), ('Mouse'),
('Audifonos'), ('Almacenamiento'), ('Componentes'), ('Impresoras'), ('Accesorios');
GO

INSERT INTO Sucursales (Nombre, Ciudad) VALUES
('Centro Medellin','Medellin'), ('Bello','Bello'), ('Envigado','Envigado'),
('Itagui','Itagui'), ('Rionegro','Rionegro');
GO

INSERT INTO Proveedores (Nombre, Ciudad) VALUES
('Proveedor 1','Medellin'), ('Proveedor 2','Bogota'), ('Proveedor 3','Cali'),
('Proveedor 4','Medellin'), ('Proveedor 5','Bogota'), ('Proveedor 6','Cali'),
('Proveedor 7','Medellin'), ('Proveedor 8','Bogota'), ('Proveedor 9','Cali'),
('Proveedor 10','Medellin');
GO

/* Generación masiva de clientes */
;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numeros WHERE n < 600
)
INSERT INTO Clientes (Nombre, Email, Ciudad)
SELECT CONCAT('Cliente ', n),
       CONCAT('cliente', n, '@ejemplo.com'),
       CASE n % 5 WHEN 0 THEN 'Medellin' WHEN 1 THEN 'Bello'
                  WHEN 2 THEN 'Envigado' WHEN 3 THEN 'Itagui' ELSE 'Rionegro' END
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* Generación de empleados */
;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM Numeros WHERE n < 20
)
INSERT INTO Empleados (Nombre, Cargo, ID_Sucursal)
SELECT CONCAT('Empleado ', n),
       CASE WHEN n % 4 = 0 THEN 'Administrador' ELSE 'Asesor' END,
       ((n - 1) % 5) + 1
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* Generación de productos */
;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM Numeros WHERE n < 200
)
INSERT INTO Productos (Nombre, ID_Categoria, ID_Proveedor, Precio)
SELECT CONCAT('Producto Tech ', n),
       ((n - 1) % 10) + 1,
       ((n - 1) % 10) + 1,
       CAST(10000 + (n * 1750 % 900000) AS DECIMAL(12,2))
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* 5 sucursales x 200 productos = 1.000 registros de inventario */
INSERT INTO Inventario (ID_Sucursal, ID_Producto, Cantidad)
SELECT S.ID_Sucursal, P.ID_Producto,
       (S.ID_Sucursal * 17 + P.ID_Producto * 3) % 100
FROM Sucursales S
CROSS JOIN Productos P;
GO

/* Generación de 1.000 ventas */
;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM Numeros WHERE n < 1000
)
INSERT INTO Ventas (ID_Cliente, ID_Empleado, ID_Sucursal, Fecha, Estado)
SELECT ((n - 1) % 600) + 1,
       ((n - 1) % 20) + 1,
       ((n - 1) % 5) + 1,
       DATEADD(DAY, -(n % 365), GETDATE()),
       CASE WHEN n % 12 = 0 THEN 'Cancelada' ELSE 'Completada' END
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* Dos detalles por venta: 2.000 filas */
INSERT INTO DetallesVenta (ID_Venta, ID_Producto, Cantidad, PrecioUnitario)
SELECT V.ID_Venta,
       ((V.ID_Venta - 1) % 200) + 1,
       (V.ID_Venta % 3) + 1,
       P.Precio
FROM Ventas V
INNER JOIN Productos P
    ON P.ID_Producto = ((V.ID_Venta - 1) % 200) + 1;
GO

INSERT INTO DetallesVenta (ID_Venta, ID_Producto, Cantidad, PrecioUnitario)
SELECT V.ID_Venta,
       (V.ID_Venta % 200) + 1,
       (V.ID_Venta % 2) + 1,
       P.Precio
FROM Ventas V
INNER JOIN Productos P
    ON P.ID_Producto = (V.ID_Venta % 200) + 1;
GO

/* Un pago por venta, calculado a partir de sus detalles */
INSERT INTO Pagos (ID_Venta, Metodo, Monto, FechaPago)
SELECT V.ID_Venta,
       CASE V.ID_Venta % 3 WHEN 0 THEN 'Tarjeta'
                           WHEN 1 THEN 'Transferencia' ELSE 'Efectivo' END,
       SUM(D.Cantidad * D.PrecioUnitario),
       V.Fecha
FROM Ventas V
INNER JOIN DetallesVenta D ON D.ID_Venta = V.ID_Venta
GROUP BY V.ID_Venta, V.Fecha;
GO

/* ======================== CONSULTAS SQL DE REVISIÓN ======================== */

SELECT
    Productos.ID_Producto AS Producto,
    Productos.Nombre AS Nombre_producto,
    Categorias.Nombre AS Categoria,
    Proveedores.Nombre AS Proveedor,
    Productos.Precio AS Precio
FROM Productos
INNER JOIN Categorias ON Productos.ID_Categoria = Categorias.ID_Categoria
INNER JOIN Proveedores ON Productos.ID_Proveedor = Proveedores.ID_Proveedor
ORDER BY Productos.Nombre;
GO

SELECT
    Ventas.ID_Venta AS Venta,
    Clientes.Nombre AS Cliente,
    Empleados.Nombre AS Empleado,
    Sucursales.Nombre AS Sucursal,
    Ventas.Fecha AS Fecha,
    Ventas.Estado AS Estado
FROM Ventas
INNER JOIN Clientes ON Ventas.ID_Cliente = Clientes.ID_Cliente
INNER JOIN Empleados ON Ventas.ID_Empleado = Empleados.ID_Empleado
INNER JOIN Sucursales ON Ventas.ID_Sucursal = Sucursales.ID_Sucursal
ORDER BY Ventas.Fecha DESC;
GO

SELECT
    Sucursales.Nombre AS Sucursal,
    SUM(DetallesVenta.Cantidad) AS Unidades_vendidas,
    SUM(DetallesVenta.Cantidad * DetallesVenta.PrecioUnitario) AS Ingresos
FROM Ventas
INNER JOIN Sucursales ON Ventas.ID_Sucursal = Sucursales.ID_Sucursal
INNER JOIN DetallesVenta ON Ventas.ID_Venta = DetallesVenta.ID_Venta
WHERE Ventas.Estado = 'Completada'
GROUP BY Sucursales.Nombre
ORDER BY Ingresos DESC;
GO

SELECT TOP 10
    Productos.Nombre AS Producto,
    SUM(DetallesVenta.Cantidad) AS Unidades_vendidas
FROM DetallesVenta
INNER JOIN Productos ON DetallesVenta.ID_Producto = Productos.ID_Producto
INNER JOIN Ventas ON DetallesVenta.ID_Venta = Ventas.ID_Venta
WHERE Ventas.Estado = 'Completada'
GROUP BY Productos.Nombre
ORDER BY Unidades_vendidas DESC;
GO

SELECT TOP 10
    Clientes.Nombre AS Cliente,
    COUNT(DISTINCT Ventas.ID_Venta) AS Numero_compras,
    SUM(DetallesVenta.Cantidad * DetallesVenta.PrecioUnitario) AS Total_gastado
FROM Clientes
INNER JOIN Ventas ON Clientes.ID_Cliente = Ventas.ID_Cliente
INNER JOIN DetallesVenta ON Ventas.ID_Venta = DetallesVenta.ID_Venta
WHERE Ventas.Estado = 'Completada'
GROUP BY Clientes.Nombre
ORDER BY Total_gastado DESC;
GO

SELECT
    Sucursales.Nombre AS Sucursal,
    Productos.Nombre AS Producto,
    Inventario.Cantidad AS Stock
FROM Inventario
INNER JOIN Sucursales ON Inventario.ID_Sucursal = Sucursales.ID_Sucursal
INNER JOIN Productos ON Inventario.ID_Producto = Productos.ID_Producto
WHERE Inventario.Cantidad <= 15
ORDER BY Inventario.Cantidad ASC;
GO

/* Conteo de filas por tabla */
SELECT 'Categorias' AS Tabla, COUNT(*) AS Filas FROM Categorias UNION ALL
SELECT 'Proveedores', COUNT(*) FROM Proveedores UNION ALL
SELECT 'Sucursales', COUNT(*) FROM Sucursales UNION ALL
SELECT 'Clientes', COUNT(*) FROM Clientes UNION ALL
SELECT 'Empleados', COUNT(*) FROM Empleados UNION ALL
SELECT 'Productos', COUNT(*) FROM Productos UNION ALL
SELECT 'Inventario', COUNT(*) FROM Inventario UNION ALL
SELECT 'Ventas', COUNT(*) FROM Ventas UNION ALL
SELECT 'DetallesVenta', COUNT(*) FROM DetallesVenta UNION ALL
SELECT 'Pagos', COUNT(*) FROM Pagos;
GO

SELECT SUM(Filas) AS Total_registros
FROM (
    SELECT COUNT(*) AS Filas FROM Categorias
    UNION ALL SELECT COUNT(*) FROM Proveedores
    UNION ALL SELECT COUNT(*) FROM Sucursales
    UNION ALL SELECT COUNT(*) FROM Clientes
    UNION ALL SELECT COUNT(*) FROM Empleados
    UNION ALL SELECT COUNT(*) FROM Productos
    UNION ALL SELECT COUNT(*) FROM Inventario
    UNION ALL SELECT COUNT(*) FROM Ventas
    UNION ALL SELECT COUNT(*) FROM DetallesVenta
    UNION ALL SELECT COUNT(*) FROM Pagos
) AS Conteos;
GO
