-- Soluciones Día 2 — Extensión operativa
-- Asume que phase2_schema.sql fue ejecutado (sucursales, empleados, formas_pago y columnas en ventas)
PRAGMA foreign_keys = ON;

-- Ejemplo: insertar sucursales, empleados y formas de pago
INSERT INTO sucursales (sucursal_id,nombre,ciudad,region) VALUES
(1,'Sucursal Centro','Madrid','Centro'),
(2,'Sucursal Norte','Bilbao','País Vasco');

INSERT INTO empleados (empleado_id,nombre,sucursal_id,puesto) VALUES
(1,'Carlos','1','Cajero'),
(2,'María','2','Jefa tienda');

INSERT INTO formas_pago (forma_pago_id,descripcion) VALUES
(1,'Efectivo'),(2,'Tarjeta débito'),(3,'Tarjeta crédito'),(4,'Transferencia');

-- Actualizar algunas ventas de ejemplo con sucursal/empleado/forma_pago
UPDATE ventas SET sucursal_id = 1, empleado_id = 1, forma_pago_id = 2 WHERE id IN (1,3);
UPDATE ventas SET sucursal_id = 2, empleado_id = 2, forma_pago_id = 3 WHERE id IN (2,4);

-- Queries solicitadas
-- 1) Ventas totales por sucursal (último mes)
SELECT s.sucursal_id, s.nombre, ROUND(SUM(v.total),2) AS ventas_total
FROM ventas v
JOIN sucursales s ON v.sucursal_id = s.sucursal_id
WHERE date(v.fecha) >= date('now','-30 days')
GROUP BY s.sucursal_id, s.nombre
ORDER BY ventas_total DESC;

-- 2) Ranking de vendedores por ventas totales (periodo)
SELECT e.empleado_id, e.nombre, SUM(v.total) AS ventas_total
FROM ventas v
JOIN empleados e ON v.empleado_id = e.empleado_id
WHERE date(v.fecha) >= date('now','-90 days')
GROUP BY e.empleado_id, e.nombre
ORDER BY ventas_total DESC
LIMIT 10;

-- 3) Análisis de devoluciones por forma de pago (requiere tabla devoluciones)
SELECT f.descripcion AS forma_pago, COUNT(d.devolucion_id) AS qty_devoluciones
FROM devoluciones d
JOIN ventas v ON d.venta_id = v.id
JOIN formas_pago f ON v.forma_pago_id = f.forma_pago_id
GROUP BY f.forma_pago_id, f.descripcion
ORDER BY qty_devoluciones DESC;
