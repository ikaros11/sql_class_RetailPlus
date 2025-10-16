-- Phase 2 schema: añadir tablas operativas (sucursales, empleados, formas_pago)
-- Ejecutar DESPUÉS de phase1_schema.sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS sucursales (
  sucursal_id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL,
  ciudad TEXT,
  region TEXT
);

CREATE TABLE IF NOT EXISTS empleados (
  empleado_id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL,
  sucursal_id INTEGER,
  puesto TEXT,
  FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id)
);

CREATE TABLE IF NOT EXISTS formas_pago (
  forma_pago_id INTEGER PRIMARY KEY,
  descripcion TEXT NOT NULL
);

-- En SQLite podemos añadir columnas a la tabla ventas para relacionarla con las nuevas tablas
-- (Nota: ALTER TABLE no permite añadir FK declarativas en versiones antiguas; para fines docentes añadiremos las columnas y gestionaremos integridad por datos)
ALTER TABLE ventas ADD COLUMN empleado_id INTEGER;
ALTER TABLE ventas ADD COLUMN sucursal_id INTEGER;
ALTER TABLE ventas ADD COLUMN forma_pago_id INTEGER;
ALTER TABLE ventas ADD COLUMN total REAL;

-- Crear índices para las nuevas columnas
CREATE INDEX IF NOT EXISTS idx_ventas_sucursal ON ventas(sucursal_id);
CREATE INDEX IF NOT EXISTS idx_ventas_empleado ON ventas(empleado_id);
CREATE INDEX IF NOT EXISTS idx_ventas_formapago ON ventas(forma_pago_id);

-- Ejercicio sugerido: después de añadir columnas, importar datos en `sucursales`, `empleados` y `formas_pago` y actualizar `ventas` con los ids correspondientes.
