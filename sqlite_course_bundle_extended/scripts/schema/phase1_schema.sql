-- Phase 1 schema: modelo mínimo (3 tablas)
-- Ejecutar primero: crea las tablas básicas para el Día 1
PRAGMA foreign_keys = ON;

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
  descuento_pct REAL NOT NULL DEFAULT 0 CHECK (descuento_pct >= 0 AND descuento_pct <= 0.9),
  total REAL,
  -- Nota: columnas operativas (sucursal/empleado/forma_pago) se añadirán en fases posteriores
  FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Índices útiles para la fase 1
CREATE INDEX IF NOT EXISTS idx_ventas_producto ON ventas(producto_id);
CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha);
