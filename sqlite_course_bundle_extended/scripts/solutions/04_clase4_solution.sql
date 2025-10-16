-- Soluciones Día 4 — Informe ejecutivo y OLAP (star schema)
-- 1) Generar datos sintéticos (ejecutar en PowerShell desde la raíz del repo)
-- python .\data\synthetic\generate_synthetic_data.py --rows 200000 --outdir .\data\synthetic\output

-- 2) Importar CSV sintéticos o usar los CSV originales. Luego ejecutar phase4_olap_star.sql
-- sqlite3 .\retail_plus.db < .\scripts\phase4_olap_star.sql

-- 3) Queries sobre fact_sales (ejemplos OLAP)
-- Informe trimestral por región
SELECT d.year AS anio, ds.region, SUM(f.ventas_total) AS ventas, SUM(f.margen_est) AS margen,
       ROUND(100.0 * SUM(f.margen_est) / NULLIF(SUM(f.ventas_total),0),2) AS margen_pct
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_store ds ON f.store_key = ds.store_key
GROUP BY d.year, ds.region
ORDER BY d.year, ds.region;

-- Top 5 productos por ingresos en el trimestre actual
WITH actuales AS (
  SELECT date_key FROM dim_date WHERE year = CAST(strftime('%Y','now') AS INTEGER) AND quarter = CAST((CAST(strftime('%m','now') AS INTEGER)+2)/3 AS INTEGER)
)
SELECT dp.producto_id, dp.nombre, SUM(f.ventas_total) AS ingresos
FROM fact_sales f
JOIN actuales a ON f.date_key = a.date_key
JOIN dim_product dp ON f.product_key = dp.product_key
GROUP BY dp.producto_id, dp.nombre
ORDER BY ingresos DESC
LIMIT 5;

-- SLA promedio por transportista (usa tabla envios)
SELECT transportista, ROUND(AVG(julianday(fecha_entrega) - julianday(fecha_envio)),2) AS dias_prom_entrega
FROM envios
WHERE fecha_envio IS NOT NULL AND fecha_entrega IS NOT NULL
GROUP BY transportista
ORDER BY dias_prom_entrega;

-- OLAP: ventas por año / categoría / región
SELECT d.year, dp.categoria, ds.region, SUM(f.ventas_total) AS ventas
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product dp ON f.product_key = dp.product_key
JOIN dim_store ds ON f.store_key = ds.store_key
GROUP BY d.year, dp.categoria, ds.region
ORDER BY d.year, dp.categoria, ds.region;
