-- Phase 4: Crear modelo estrella (star schema) y poblar fact table desde tablas transaccionales
-- Requiere que las fases 1..3 estén ejecutadas y que existan ventas, productos, clientes, sucursales, empleados y formas_pago
PRAGMA foreign_keys = OFF; -- durante ETL puede ser conveniente desactivar y luego validar

-- Dimensiones
CREATE TABLE IF NOT EXISTS dim_date (
  date_key INTEGER PRIMARY KEY, -- YYYYMMDD
  fecha DATE,
  year INTEGER,
  quarter INTEGER,
  month INTEGER,
  day INTEGER,
  week INTEGER
);

CREATE TABLE IF NOT EXISTS dim_product (
  product_key INTEGER PRIMARY KEY,
  producto_id INTEGER,
  sku TEXT,
  nombre TEXT,
  categoria TEXT,
  precio REAL,
  costo REAL
);

CREATE TABLE IF NOT EXISTS dim_customer (
  customer_key INTEGER PRIMARY KEY,
  cliente_id INTEGER,
  nombre TEXT,
  ciudad TEXT,
  region TEXT
);

CREATE TABLE IF NOT EXISTS dim_store (
  store_key INTEGER PRIMARY KEY,
  sucursal_id INTEGER,
  nombre TEXT,
  ciudad TEXT,
  region TEXT
);

CREATE TABLE IF NOT EXISTS dim_employee (
  employee_key INTEGER PRIMARY KEY,
  empleado_id INTEGER,
  nombre TEXT,
  sucursal_id INTEGER
);

CREATE TABLE IF NOT EXISTS dim_payment (
  payment_key INTEGER PRIMARY KEY,
  forma_pago_id INTEGER,
  descripcion TEXT
);

-- Fact table
CREATE TABLE IF NOT EXISTS fact_sales (
  fact_id INTEGER PRIMARY KEY,
  date_key INTEGER,
  product_key INTEGER,
  customer_key INTEGER,
  store_key INTEGER,
  employee_key INTEGER,
  payment_key INTEGER,
  unidades INTEGER,
  ventas_total REAL,
  descuento_pct REAL,
  costo_total REAL,
  margen_est REAL
);

-- Poblar dimensiones desde tablas transaccionales
-- dim_date: extraer fechas distintas desde ventas
INSERT OR IGNORE INTO dim_date (date_key, fecha, year, quarter, month, day, week)
SELECT
  CAST(strftime('%Y%m%d', fecha) AS INTEGER) AS date_key,
  fecha,
  CAST(strftime('%Y', fecha) AS INTEGER) AS year,
  CAST((CAST(strftime('%m', fecha) AS INTEGER)+2)/3 AS INTEGER) AS quarter,
  CAST(strftime('%m', fecha) AS INTEGER) AS month,
  CAST(strftime('%d', fecha) AS INTEGER) AS day,
  CAST(strftime('%W', fecha) AS INTEGER) AS week
FROM ventas
GROUP BY fecha;

-- dim_product
INSERT OR IGNORE INTO dim_product (product_key, producto_id, sku, nombre, categoria, precio, costo)
SELECT id, id, sku, nombre, categoria, precio, costo FROM productos;

-- dim_customer
INSERT OR IGNORE INTO dim_customer (customer_key, cliente_id, nombre, ciudad, region)
SELECT id, id, nombre, ciudad, region FROM clientes;

-- dim_store
INSERT OR IGNORE INTO dim_store (store_key, sucursal_id, nombre, ciudad, region)
SELECT sucursal_id, sucursal_id, nombre, ciudad, region FROM sucursales;

-- dim_employee
INSERT OR IGNORE INTO dim_employee (employee_key, empleado_id, nombre, sucursal_id)
SELECT empleado_id, empleado_id, nombre, sucursal_id FROM empleados;

-- dim_payment
INSERT OR IGNORE INTO dim_payment (payment_key, forma_pago_id, descripcion)
SELECT forma_pago_id, forma_pago_id, descripcion FROM formas_pago;

-- Poblar fact_sales: mapear claves de dimensiones y calcular estimaciones
INSERT INTO fact_sales (date_key, product_key, customer_key, store_key, employee_key, payment_key, unidades, ventas_total, descuento_pct, costo_total, margen_est)
SELECT
  CAST(strftime('%Y%m%d', v.fecha) AS INTEGER) AS date_key,
  v.producto_id AS product_key,
  v.cliente_id AS customer_key,
  v.sucursal_id AS store_key,
  v.empleado_id AS employee_key,
  v.forma_pago_id AS payment_key,
  SUM(v.cantidad) AS unidades,
  SUM(v.total) AS ventas_total,
  AVG(v.descuento_pct) AS descuento_pct,
  SUM(p.costo * v.cantidad) AS costo_total,
  SUM((v.total) - (p.costo * v.cantidad)) AS margen_est
FROM ventas v
LEFT JOIN productos p ON p.id = v.producto_id
GROUP BY date_key, product_key, customer_key, store_key, employee_key, payment_key;

-- Índices sobre fact table para acelerar consultas OLAP
CREATE INDEX IF NOT EXISTS idx_fact_date ON fact_sales(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_product ON fact_sales(product_key);
CREATE INDEX IF NOT EXISTS idx_fact_store ON fact_sales(store_key);

PRAGMA foreign_keys = ON;

-- Nota: para sincronizar datos (re-running) se pueden truncar fact_sales o usar INSERT OR REPLACE estrategias.
