-- Soluciones Día 1 — Modelo básico
-- Ejecuta las instrucciones en sqlite3 o DB Browser for SQLite

PRAGMA foreign_keys = ON;

-- (1) Crear tablas (si no existen): ya está en phase1_schema.sql
-- Repetimos aquí como referencia rápida
CREATE TABLE IF NOT EXISTS clientes (
  id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL,
  ciudad TEXT,
  region TEXT,
  fecha_alta DATE
);

CREATE TABLE IF NOT EXISTS productos (
  id INTEGER PRIMARY KEY,
  sku TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  categoria TEXT,
  precio REAL NOT NULL,
  costo REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS ventas (
  id INTEGER PRIMARY KEY,
  fecha DATE NOT NULL,
  cliente_id INTEGER NOT NULL,
  producto_id INTEGER NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  descuento_pct REAL NOT NULL DEFAULT 0,
  total REAL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- (2) Insertar datos de ejemplo
INSERT INTO clientes (id,nombre,ciudad,region,fecha_alta) VALUES
(1,'Ana','Madrid','Centro','2024-01-10'),
(2,'Luis','Valencia','Comunidad Valenciana','2024-02-12');

INSERT INTO productos (id,sku,nombre,categoria,precio,costo) VALUES
(1,'SKU-000001','Camiseta','Moda',15.0,8.0),
(2,'SKU-000002','Taza','Hogar',8.0,3.5),
(3,'SKU-000003','Gorra','Moda',12.0,5.0);

INSERT INTO ventas (id,fecha,cliente_id,producto_id,cantidad,descuento_pct,total) VALUES
(1,'2025-09-01',1,1,2,0.0,30.0),
(2,'2025-09-02',2,2,1,0.0,8.0),
(3,'2025-09-05',1,1,1,0.0,15.0),
(4,'2025-09-08',2,3,3,0.0,36.0);

-- (3) Queries solicitadas
-- Total de ventas en el último mes (ajusta la fecha según entorno)
SELECT ROUND(SUM(total),2) AS total_ventas_ultimo_mes
FROM ventas
WHERE date(fecha) >= date('now','-30 days');

-- Top 5 productos por unidades vendidas (últimas 4 semanas)
SELECT p.id AS producto_id, p.nombre, SUM(v.cantidad) AS unidades_vendidas
FROM ventas v
JOIN productos p ON v.producto_id = p.id
WHERE date(v.fecha) >= date('now','-28 days')
GROUP BY p.id, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 5;

-- Ticket promedio por cliente en el periodo (último mes)
SELECT cliente_id, ROUND(AVG(total),2) AS ticket_promedio
FROM ventas
WHERE date(fecha) >= date('now','-30 days')
GROUP BY cliente_id;
