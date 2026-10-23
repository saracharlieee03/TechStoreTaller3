
/*
PROYECTO: TechStoreTaller3
CONSULTAS DE AGREGACIÓN EN MONGODB

Las consultas se ejecutan en mongosh, conectado a la base:
TechStoreTaller3

Seleccionar la base antes de ejecutarlas:
use TechStoreTaller3
*/


// ============================================================
// CONSULTA 1. ¿Cuáles son las ventas completadas?
// Objetivo: mostrar únicamente las ventas cuyo estado sea
// "Completada".
// ============================================================

db.ventas.aggregate([
  {
    $match: {
      Estado: "Completada"
    }
  },
  {
    $project: {
      _id: 0,
      ID_Venta: 1,
      ID_Cliente: 1,
      ID_Empleado: 1,
      ID_Sucursal: 1,
      Fecha: 1,
      Estado: 1
    }
  }
]);


// ============================================================
// CONSULTA 2. ¿Cuánto dinero se vendió por sucursal?
// Objetivo: sumar el monto de los detalles de las ventas
// completadas y agruparlo por sucursal.
// ============================================================

db.ventas.aggregate([
  {
    $match: {
      Estado: "Completada"
    }
  },
  {
    $unwind: "$detalles"
  },
  {
    $group: {
      _id: "$ID_Sucursal",
      ingresos: {
        $sum: {
          $multiply: [
            "$detalles.Cantidad",
            "$detalles.PrecioUnitario"
          ]
        }
      }
    }
  },
  {
    $lookup: {
      from: "sucursales",
      localField: "_id",
      foreignField: "ID_Sucursal",
      as: "sucursal"
    }
  },
  {
    $unwind: "$sucursal"
  },
  {
    $project: {
      _id: 0,
      Sucursal: "$sucursal.Nombre",
      ingresos: 1
    }
  },
  {
    $sort: {
      ingresos: -1
    }
  }
]);


// ============================================================
// CONSULTA 3. ¿Cuáles son los productos más vendidos?
// Objetivo: sumar las unidades vendidas de cada producto
// en ventas completadas y mostrar los primeros 10.
// ============================================================

db.ventas.aggregate([
  {
    $match: {
      Estado: "Completada"
    }
  },
  {
    $unwind: "$detalles"
  },
  {
    $group: {
      _id: "$detalles.ID_Producto",
      unidadesVendidas: {
        $sum: "$detalles.Cantidad"
      }
    }
  },
  {
    $lookup: {
      from: "productos",
      localField: "_id",
      foreignField: "ID_Producto",
      as: "producto"
    }
  },
  {
    $unwind: "$producto"
  },
  {
    $project: {
      _id: 0,
      Producto: "$producto.Nombre",
      unidadesVendidas: 1
    }
  },
  {
    $sort: {
      unidadesVendidas: -1
    }
  },
  {
    $limit: 10
  }
]);


// ============================================================
// CONSULTA 4. ¿Cuánto ha gastado cada cliente?
// Objetivo: calcular el valor total de las compras completadas
// por cliente y mostrar los 10 clientes con mayor gasto.
// ============================================================

db.ventas.aggregate([
  {
    $match: {
      Estado: "Completada"
    }
  },
  {
    $unwind: "$detalles"
  },
  {
    $group: {
      _id: "$ID_Cliente",
      totalGastado: {
        $sum: {
          $multiply: [
            "$detalles.Cantidad",
            "$detalles.PrecioUnitario"
          ]
        }
      }
    }
  },
  {
    $lookup: {
      from: "clientes",
      localField: "_id",
      foreignField: "ID_Cliente",
      as: "cliente"
    }
  },
  {
    $unwind: "$cliente"
  },
  {
    $project: {
      _id: 0,
      Cliente: "$cliente.Nombre",
      totalGastado: 1
    }
  },
  {
    $sort: {
      totalGastado: -1
    }
  },
  {
    $limit: 10
  }
]);


// ============================================================
// CONSULTA 5. ¿Qué métodos de pago se utilizan y cuántas veces?
// Objetivo: contar los pagos agrupándolos por método.
// ============================================================

db.ventas.aggregate([
  {
    $unwind: "$pagos"
  },
  {
    $group: {
      _id: "$pagos.Metodo",
      cantidadPagos: {
        $sum: 1
      },
      montoTotal: {
        $sum: "$pagos.Monto"
      }
    }
  },
  {
    $project: {
      _id: 0,
      MetodoPago: "$_id",
      cantidadPagos: 1,
      montoTotal: 1
    }
  },
  {
    $sort: {
      cantidadPagos: -1
    }
  }
]);


// ============================================================
// CONSULTA 6. ¿Qué productos tienen poco inventario?
// Objetivo: encontrar productos con 15 unidades o menos
// y mostrar la sucursal, el producto y la cantidad disponible.
// ============================================================

db.inventario.aggregate([
  {
    $match: {
      Cantidad: {
        $lte: 15
      }
    }
  },
  {
    $lookup: {
      from: "productos",
      localField: "ID_Producto",
      foreignField: "ID_Producto",
      as: "producto"
    }
  },
  {
    $unwind: "$producto"
  },
  {
    $lookup: {
      from: "sucursales",
      localField: "ID_Sucursal",
      foreignField: "ID_Sucursal",
      as: "sucursal"
    }
  },
  {
    $unwind: "$sucursal"
  },
  {
    $project: {
      _id: 0,
      Sucursal: "$sucursal.Nombre",
      Producto: "$producto.Nombre",
      Stock: "$Cantidad"
    }
  },
  {
    $sort: {
      Stock: 1
    }
  }
]);


// ============================================================
// CONSULTA 7. ¿Cuántas ventas tiene cada cliente?
// Objetivo: contar las ventas registradas por cliente y mostrar
// el nombre del cliente.
// ============================================================

db.ventas.aggregate([
  {
    $group: {
      _id: "$ID_Cliente",
      cantidadVentas: {
        $sum: 1
      }
    }
  },
  {
    $lookup: {
      from: "clientes",
      localField: "_id",
      foreignField: "ID_Cliente",
      as: "cliente"
    }
  },
  {
    $unwind: "$cliente"
  },
  {
    $project: {
      _id: 0,
      Cliente: "$cliente.Nombre",
      cantidadVentas: 1
    }
  },
  {
    $sort: {
      cantidadVentas: -1
    }
  }
]);


// ============================================================
// CONSULTA 8. ¿Qué sucursales tienen más ventas?
// Objetivo: contar las ventas de cada sucursal, mostrar su nombre
// y ordenar el resultado de mayor a menor.
// ============================================================

db.ventas.aggregate([
  {
    $group: {
      _id: "$ID_Sucursal",
      cantidadVentas: {
        $sum: 1
      }
    }
  },
  {
    $lookup: {
      from: "sucursales",
      localField: "_id",
      foreignField: "ID_Sucursal",
      as: "sucursal"
    }
  },
  {
    $unwind: "$sucursal"
  },
  {
    $project: {
      _id: 0,
      Sucursal: "$sucursal.Nombre",
      cantidadVentas: 1
    }
  },
  {
    $sort: {
      cantidadVentas: -1
    }
  }
]);
