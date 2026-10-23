USE TechStoreTaller3;
GO

-- 1. Verificar cuántos registros hay en cada tabla
SELECT 'Categorias' AS Tabla, COUNT(*) AS Total FROM Categorias
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM Proveedores
UNION ALL
SELECT 'Sucursales', COUNT(*) FROM Sucursales
UNION ALL
SELECT 'Clientes', COUNT(*) FROM Clientes
UNION ALL
SELECT 'Empleados', COUNT(*) FROM Empleados
UNION ALL
SELECT 'Productos', COUNT(*) FROM Productos
UNION ALL
SELECT 'Inventario', COUNT(*) FROM Inventario
UNION ALL
SELECT 'Ventas', COUNT(*) FROM Ventas
UNION ALL
SELECT 'DetallesVenta', COUNT(*) FROM DetallesVenta
UNION ALL
SELECT 'Pagos', COUNT(*) FROM Pagos;


-- 2. Consultar productos con su categoría y proveedor
SELECT
    p.ID_Producto,
    p.Nombre AS Producto,
    c.Nombre AS Categoria,
    pr.Nombre AS Proveedor,
    p.Precio
FROM Productos p
INNER JOIN Categorias c
    ON p.ID_Categoria = c.ID_Categoria
INNER JOIN Proveedores pr
    ON p.ID_Proveedor = pr.ID_Proveedor;


-- 3. Consultar ventas con información del cliente, empleado y sucursal
SELECT
    v.ID_Venta,
    v.Fecha,
    cl.Nombre AS Cliente,
    e.Nombre AS Empleado,
    s.Nombre AS Sucursal,
    v.Estado
FROM Ventas v
INNER JOIN Clientes cl
    ON v.ID_Cliente = cl.ID_Cliente
INNER JOIN Empleados e
    ON v.ID_Empleado = e.ID_Empleado
INNER JOIN Sucursales s
    ON v.ID_Sucursal = s.ID_Sucursal;


-- 4. Cantidad de unidades vendidas por sucursal
SELECT
    s.Nombre AS Sucursal,
    SUM(dv.Cantidad) AS UnidadesVendidas
FROM Ventas v
INNER JOIN Sucursales s
    ON v.ID_Sucursal = s.ID_Sucursal
INNER JOIN DetallesVenta dv
    ON v.ID_Venta = dv.ID_Venta
WHERE v.Estado = 'Completada'
GROUP BY s.Nombre
ORDER BY UnidadesVendidas DESC;


-- 5. Productos más vendidos
SELECT TOP 10
    p.Nombre AS Producto,
    SUM(dv.Cantidad) AS UnidadesVendidas
FROM DetallesVenta dv
INNER JOIN Productos p
    ON dv.ID_Producto = p.ID_Producto
INNER JOIN Ventas v
    ON dv.ID_Venta = v.ID_Venta
WHERE v.Estado = 'Completada'
GROUP BY p.Nombre
ORDER BY UnidadesVendidas DESC;


-- 6. Clientes que más dinero han gastado
SELECT TOP 10
    c.Nombre AS Cliente,
    SUM(dv.Cantidad * dv.PrecioUnitario) AS TotalGastado
FROM Ventas v
INNER JOIN Clientes c
    ON v.ID_Cliente = c.ID_Cliente
INNER JOIN DetallesVenta dv
    ON v.ID_Venta = dv.ID_Venta
WHERE v.Estado = 'Completada'
GROUP BY c.Nombre
ORDER BY TotalGastado DESC;


-- 7. Productos con inventario bajo
SELECT
    p.Nombre AS Producto,
    s.Nombre AS Sucursal,
    i.Cantidad AS Existencias
FROM Inventario i
INNER JOIN Productos p
    ON i.ID_Producto = p.ID_Producto
INNER JOIN Sucursales s
    ON i.ID_Sucursal = s.ID_Sucursal
WHERE i.Cantidad < 10
ORDER BY i.Cantidad ASC;
