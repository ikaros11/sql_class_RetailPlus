-- Phase 3 schema: extensiones analíticas (devoluciones, inventario, campañas, envíos)
-- Ejecutar DESPUÉS de phase2_schema.sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS devoluciones (
  devolucion_id INTEGER PRIMARY KEY,
  venta_id INTEGER NOT NULL,
  producto_id INTEGER,
  cantidad INTEGER NOT NULL DEFAULT 1,
  fecha DATE,
  motivo TEXT,
  FOREIGN KEY (venta_id) REFERENCES ventas(id)
);

CREATE TABLE IF NOT EXISTS inventario (
  sucursal_id INTEGER NOT NULL,
  producto_id INTEGER NOT NULL,
  fecha DATE NOT NULL,
  stock INTEGER NOT NULL,
  PRIMARY KEY (sucursal_id, producto_id, fecha)
);

CREATE TABLE IF NOT EXISTS campanias_marketing (
  id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE
);

CREATE TABLE IF NOT EXISTS campanias_productos (
  id INTEGER PRIMARY KEY,
  campania_id INTEGER NOT NULL,
  producto_id INTEGER NOT NULL,
  FOREIGN KEY (campania_id) REFERENCES campanias_marketing(id),
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE IF NOT EXISTS envios (
  envio_id INTEGER PRIMARY KEY,
  venta_id INTEGER,
  fecha_envio DATE,
  fecha_entrega DATE,
  transportista TEXT,
  estado TEXT,
  FOREIGN KEY (venta_id) REFERENCES ventas(id)
);

-- Índices sugeridos
CREATE INDEX IF NOT EXISTS idx_devoluciones_venta ON devoluciones(venta_id);
CREATE INDEX IF NOT EXISTS idx_inventario_fecha ON inventario(fecha);
CREATE INDEX IF NOT EXISTS idx_campania_producto ON campanias_productos(producto_id);
CREATE INDEX IF NOT EXISTS idx_envios_fecha ON envios(fecha_envio);

-- Ejercicio sugerido: importar CSV correspondientes y calcular tasa de devoluciones por producto y rotación de inventario.
