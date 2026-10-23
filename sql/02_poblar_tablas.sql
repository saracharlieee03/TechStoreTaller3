/* =========================================================
   TECHSTORE - POBLACIÓN DE TABLAS CON DATOS FICTICIOS
   ========================================================= */

USE TechStoreTaller3;
GO

/* ======================== CATEGORÍAS ======================== */

INSERT INTO Categorias (Nombre) VALUES
('Computadores'), ('Portatiles'), ('Monitores'), ('Teclados'), ('Mouse'),
('Audifonos'), ('Almacenamiento'), ('Componentes'), ('Impresoras'), ('Accesorios');
GO

/* ======================== SUCURSALES ======================== */

INSERT INTO Sucursales (Nombre, Ciudad) VALUES
('Centro Medellin','Medellin'), ('Bello','Bello'), ('Envigado','Envigado'),
('Itagui','Itagui'), ('Rionegro','Rionegro');
GO

/* ======================== PROVEEDORES ======================== */

INSERT INTO Proveedores (Nombre, Ciudad) VALUES
('Proveedor 1','Medellin'), ('Proveedor 2','Bogota'), ('Proveedor 3','Cali'),
('Proveedor 4','Medellin'), ('Proveedor 5','Bogota'), ('Proveedor 6','Cali'),
('Proveedor 7','Medellin'), ('Proveedor 8','Bogota'), ('Proveedor 9','Cali'),
('Proveedor 10','Medellin');
GO

/* ======================== CLIENTES: 600 REGISTROS ======================== */

;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numeros WHERE n < 600
)
INSERT INTO Clientes (Nombre, Email, Ciudad)
SELECT CONCAT('Cliente ', n),
       CONCAT('cliente', n, '@ejemplo.com'),
       CASE n % 5
           WHEN 0 THEN 'Medellin'
           WHEN 1 THEN 'Bello'
           WHEN 2 THEN 'Envigado'
           WHEN 3 THEN 'Itagui'
           ELSE 'Rionegro'
       END
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* ======================== EMPLEADOS: 20 REGISTROS ======================== */

;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numeros WHERE n < 20
)
INSERT INTO Empleados (Nombre, Cargo, ID_Sucursal)
SELECT CONCAT('Empleado ', n),
       CASE WHEN n % 4 = 0 THEN 'Administrador' ELSE 'Asesor' END,
       ((n - 1) % 5) + 1
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* ======================== PRODUCTOS: 200 REGISTROS ======================== */

;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numeros WHERE n < 200
)
INSERT INTO Productos (Nombre, ID_Categoria, ID_Proveedor, Precio)
SELECT CONCAT('Producto Tech ', n),
       ((n - 1) % 10) + 1,
       ((n - 1) % 10) + 1,
       CAST(10000 + (n * 1750 % 900000) AS DECIMAL(12,2))
FROM Numeros
OPTION (MAXRECURSION 0);
GO

/* ======================== INVENTARIO: 1.000 REGISTROS ======================== */
/* Combina las 5 sucursales con los 200 productos. */

INSERT INTO Inventario (ID_Sucursal, ID_Producto, Cantidad)
SELECT S.ID_Sucursal,
       P.ID_Producto,
       (S.ID_Sucursal * 17 + P.ID_Producto * 3) % 100
FROM Sucursales AS S
CROSS JOIN Productos AS P;
GO

/* ======================== VENTAS: 1.000 REGISTROS ======================== */

;WITH Numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numeros WHERE n < 1000
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

/* ======================== DETALLES DE VENTA: 2.000 REGISTROS ======================== */
/* Primer detalle por cada venta. */

INSERT INTO DetallesVenta (ID_Venta, ID_Producto, Cantidad, PrecioUnitario)
SELECT V.ID_Venta,
       ((V.ID_Venta - 1) % 200) + 1,
       (V.ID_Venta % 3) + 1,
       P.Precio
FROM Ventas AS V
INNER JOIN Productos AS P
    ON P.ID_Producto = ((V.ID_Venta - 1) % 200) + 1;
GO

/* Segundo detalle por cada venta. */

INSERT INTO DetallesVenta (ID_Venta, ID_Producto, Cantidad, PrecioUnitario)
SELECT V.ID_Venta,
       (V.ID_Venta % 200) + 1,
       (V.ID_Venta % 2) + 1,
       P.Precio
FROM Ventas AS V
INNER JOIN Productos AS P
    ON P.ID_Producto = (V.ID_Venta % 200) + 1;
GO

/* ======================== PAGOS: 1.000 REGISTROS ======================== */
/* Genera un pago por venta con el valor total de sus detalles. */

INSERT INTO Pagos (ID_Venta, Metodo, Monto, FechaPago)
SELECT V.ID_Venta,
       CASE V.ID_Venta % 3
           WHEN 0 THEN 'Tarjeta'
           WHEN 1 THEN 'Transferencia'
           ELSE 'Efectivo'
       END,
       SUM(D.Cantidad * D.PrecioUnitario),
       V.Fecha
FROM Ventas AS V
INNER JOIN DetallesVenta AS D
    ON D.ID_Venta = V.ID_Venta
GROUP BY V.ID_Venta, V.Fecha;
GO
