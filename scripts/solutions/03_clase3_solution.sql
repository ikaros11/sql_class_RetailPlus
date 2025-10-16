-- Soluciones Día 3 — Extensión analítica
-- Asume que phase3_schema.sql fue ejecutado y que hay datos en campañas, devoluciones e inventario
PRAGMA foreign_keys = ON;

-- 1) Ventas 30 días después del inicio de la campaña (ejemplo con CTE)
WITH campana AS (
  SELECT * FROM campanias_marketing WHERE id = 1
), productos_camp AS (
  SELECT producto_id FROM campanias_productos WHERE campania_id = 1
), ventas_camp AS (
  SELECT v.*
  FROM ventas v
  JOIN productos_camp pc ON v.producto_id = pc.producto_id
  JOIN campana c ON date(v.fecha) BETWEEN date(c.fecha_inicio) AND date(c.fecha_inicio,'+30 days')
)
SELECT SUM(cantidad) AS unidades_vendidas, ROUND(SUM(total),2) AS ingresos
FROM ventas_camp;

-- 2) Tasa de devoluciones por producto en periodo (devoluciones / ventas)
WITH ventas_prod AS (
  SELECT producto_id, SUM(cantidad) AS unidades_vendidas
  FROM ventas
  WHERE date(fecha) BETWEEN '2025-08-01' AND '2025-08-31'
  GROUP BY producto_id
), devol_prod AS (
  SELECT producto_id, SUM(cantidad) AS unidades_devueltas
  FROM devoluciones d
  JOIN ventas v ON d.venta_id = v.id
  WHERE date(d.fecha) BETWEEN '2025-08-01' AND '2025-08-31'
  GROUP BY producto_id
)
SELECT vp.producto_id,
       vp.unidades_vendidas,
       IFNULL(dp.unidades_devueltas,0) AS unidades_devueltas,
       ROUND(CAST(IFNULL(dp.unidades_devueltas,0) AS FLOAT)/NULLIF(vp.unidades_vendidas,0)*100,2) AS tasa_devoluciones_pct
FROM ventas_prod vp
LEFT JOIN devol_prod dp ON vp.producto_id = dp.producto_id
ORDER BY tasa_devoluciones_pct DESC
LIMIT 50;

-- 3) Rotación de inventario: ventas / promedio inventario (por producto y sucursal)
WITH ventas_por_periodo AS (
  SELECT sucursal_id, producto_id, SUM(cantidad) AS unidades_vendidas
  FROM ventas
  WHERE date(fecha) BETWEEN '2025-01-01' AND '2025-12-31'
  GROUP BY sucursal_id, producto_id
), avg_inventario AS (
  SELECT sucursal_id, producto_id, AVG(stock) AS stock_promedio
  FROM inventario
  WHERE date BETWEEN '2025-01-01' AND '2025-12-31'
  GROUP BY sucursal_id, producto_id
)
SELECT v.sucursal_id, v.producto_id, v.unidades_vendidas, ai.stock_promedio,
       ROUND(CAST(v.unidades_vendidas AS FLOAT)/NULLIF(ai.stock_promedio,0),4) AS rotacion
FROM ventas_por_periodo v
LEFT JOIN avg_inventario ai ON v.sucursal_id = ai.sucursal_id AND v.producto_id = ai.producto_id
ORDER BY rotacion DESC
LIMIT 100;
