# Extensión operativa

## Fundamentos teóricos
Hoy profundizaremos en conceptos que permiten relacionar datos operativos con transacciones:

- Normalización y diseño de dimensiones operativas: cuándo y por qué separar `sucursales` y `empleados` en tablas distintas.
- Tipos de JOIN y su semántica: `INNER JOIN` vs `LEFT JOIN` cuando algunas ventas no tienen datos asociados.
- Denormalización controlada: casos en los que duplicar una columna (p. ej. ciudad) ayuda a rendimiento de consultas de lectura.
- Índices básicos: qué son, cuándo crearlos (columnas usadas en WHERE y JOIN) y su impacto en inserciones.

Estos fundamentos te permitirán diseñar consultas más eficientes y entender decisiones de modelado operativo.

## Escenario y petición
La gerente de operaciones llama por teléfono: "Queremos saber qué tiendas están funcionando mejor esta semana y qué vendedores están destacando — además, necesito comprobar si alguna forma de pago (tarjeta, efectivo) está asociada a devoluciones altas".

Tú y tu equipo sois los responsables de responder con velocidad y claridad. Hoy añadimos las tablas operativas que permiten responder a estas preguntas.

## Objetivos

1. Añadir tablas operativas: `sucursales`, `empleados`, `formas_pago`.
2. Aprender joins multi-tabla y agrupar por dimensiones.
3. Construir KPIs: ventas por sucursal, ranking de vendedores, y análisis por forma de pago.

## Concepto explicado con ejemplo real
Imagina una tienda física: cada venta tiene un cajero (empleado), se hace en una sucursal y se realiza con una forma de pago. Para entender rendimiento debes relacionar esas dimensiones con la tabla `ventas`. Las agregaciones (SUM, COUNT) te dan la medida, GROUP BY la dimensión.

## Plan de trabajo
1. Crear las tablas nuevas e insertar registros de ejemplo.
2. Extender `ventas` con `sucursal_id`, `empleado_id` y `forma_pago_id`.
3. Resolver las preguntas del gerente con consultas y presentar resultados en una tabla ordenada.

## Ejercicios guiados


1) Crear tablas operativas y poblar datos

- Acción: crea `sucursales`, `empleados` y `formas_pago` e inserta registros de ejemplo.
- Pista: define claves primarias y relaciones (empleados -> sucursal).

<details>
<summary>Solución guía (desplegar)</summary>

```sql
CREATE TABLE IF NOT EXISTS sucursales (
   sucursal_id INTEGER PRIMARY KEY,
   nombre TEXT,
   ciudad TEXT
);

CREATE TABLE IF NOT EXISTS empleados (
   empleado_id INTEGER PRIMARY KEY,
   nombre TEXT,
   sucursal_id INTEGER,
   FOREIGN KEY(sucursal_id) REFERENCES sucursales(sucursal_id)
);

CREATE TABLE IF NOT EXISTS formas_pago (
   forma_pago_id INTEGER PRIMARY KEY,
   descripcion TEXT
);

INSERT INTO sucursales (nombre, ciudad) VALUES ('Centro', 'Ciudad A'), ('Norte', 'Ciudad B'), ('Sur', 'Ciudad C');
INSERT INTO empleados (nombre, sucursal_id) VALUES ('Pedro',1),('Lucia',1),('Marta',2),('Carlos',2),('Elena',3),('Diego',3);
INSERT INTO formas_pago (descripcion) VALUES ('Efectivo'),('Tarjeta');
```

</details>

2) Extender `ventas` con columnas operativas

- Acción: añade `sucursal_id`, `empleado_id`, `forma_pago_id` a `ventas` y actualiza algunos registros.
- Pista: `ALTER TABLE` en SQLite tiene limitaciones; puede ser más sencillo recrear la tabla con los campos nuevos en entornos de práctica.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
-- Ejemplo simple: recrear tabla con campos nuevos (en entornos de práctica)
CREATE TABLE ventas_new (
   id INTEGER PRIMARY KEY,
   fecha DATE,
   cliente_id INTEGER,
   producto_id INTEGER,
   cantidad INTEGER,
   total REAL,
   sucursal_id INTEGER,
   empleado_id INTEGER,
   forma_pago_id INTEGER
);
INSERT INTO ventas_new (id, fecha, cliente_id, producto_id, cantidad, total)
   SELECT id, fecha, cliente_id, producto_id, cantidad, total FROM ventas;
DROP TABLE ventas;
ALTER TABLE ventas_new RENAME TO ventas;
```

</details>

3) Consultas operativas solicitadas por la gerente

- Acción: escribe las consultas para KPI por sucursal, ranking de vendedores y análisis de devoluciones por forma de pago.
- Pista: usa `GROUP BY` y joins a `sucursales`, `empleados` y `formas_pago`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
-- Ventas totales por sucursal
SELECT su.sucursal_id, su.nombre, SUM(v.total) AS ventas_total
FROM ventas v
JOIN sucursales su ON v.sucursal_id = su.sucursal_id
GROUP BY su.sucursal_id, su.nombre
ORDER BY ventas_total DESC;

-- Ranking de vendedores
SELECT e.empleado_id, e.nombre, SUM(v.total) AS ventas_total
FROM ventas v
JOIN empleados e ON v.empleado_id = e.empleado_id
GROUP BY e.empleado_id, e.nombre
ORDER BY ventas_total DESC
LIMIT 5;

-- Forma de pago con más devoluciones (si existe tabla devoluciones)
SELECT f.descripcion, COUNT(d.devolucion_id) AS cantidad_devoluciones
FROM devoluciones d
JOIN ventas v ON d.venta_id = v.venta_id
JOIN formas_pago f ON v.forma_pago_id = f.forma_pago_id
GROUP BY f.forma_pago_id, f.descripcion
ORDER BY cantidad_devoluciones DESC;
```

</details>

---

## Ejercicios (dificultad creciente)

Las soluciones están en `scripts/solutions/02_clase2_solution.sql`.

Nivel 1 (básico)
1. Crear las tablas `sucursales`, `empleados` y `formas_pago` e insertar datos.
2. Extender `ventas` con las columnas operativas y verificar integridad.

Nivel 2 (intermedio)
3. **Ejercicio ALTER TABLE**: Usar `ALTER TABLE ventas ADD COLUMN sucursal_id INTEGER` para añadir la columna de sucursal. Luego actualizar algunas filas con `UPDATE ventas SET sucursal_id = 1 WHERE id <= 5`.
4. Consultar la sucursal con mayor ingreso en el último mes.
5. Top 5 vendedores por ventas totales.

Nivel 3 (avanzado)
6. Analizar la proporción de devoluciones por forma de pago y proponer una hipótesis de causa.

Soluciones: `scripts/solutions/02_clase2_solution.sql`
