# Modelo básico y consultas

## Fundamentos teóricos
En esta sesión cubriremos los conceptos relacionales básicos necesarios para diseñar y consultar el modelo mínimo:

- Modelo relacional: tablas como conjuntos de tuplas. Cada tabla representa una entidad (clientes, productos, ventas).
- Claves primarias y foráneas: identificación única (`PRIMARY KEY`) y enlaces entre tablas (`FOREIGN KEY`) para mantener integridad referencial.
- Tipos de datos simples en SQLite: `INTEGER`, `TEXT`, `REAL` y cómo SQLite maneja fechas como `TEXT` con funciones `date()`/`strftime()`.
- Operaciones fundamentales: `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, `ORDER BY` y agregaciones (`SUM`, `COUNT`, `AVG`).

## Escenario y petición
El gerente, Sr. Javier Ruiz, entra en la sala con una preocupación práctica: "Necesito un informe rápido para la reunión de mañana: ¿cuáles son los productos que más se venden y cuántas ventas hemos tenido en el último mes?".

Este primer día trabajaremos como el equipo de soporte de datos que debe entregar resultados claros y reproducibles. Piensa que eres el analista que recibe la petición: tu objetivo no es solo obtener números sino construir una consulta y un pequeño modelo que cualquiera del equipo pueda volver a ejecutar.

## Objetivos de la sesión
1. Entender la necesidad de negocio y traducirla a una consulta SQL.
2. Diseñar un modelo mínimo (tablas `clientes`, `productos`, `ventas`) y sus relaciones.
3. Escribir consultas para obtener top productos y métricas básicas (conteos, totales y agrupaciones).

## Concepto explicado con analogía
Imagina las tablas como hojas de cálculo enlazadas por referencias: la tabla `ventas` es el registro de transacciones (líneas de ticket) y apunta a `clientes` y `productos` como si fueran la libreta de direcciones y el catálogo. Las JOINs son las fórmulas que juntan hojas para crear el informe final.

## Plan de trabajo (pasos concretos)
1. Crear las tablas y cargar algunos datos de ejemplo.
2. Validar que las claves coinciden (FKs) y que las fechas y montos tienen sentido.
3. Escribir la consulta que responde a la petición del gerente.

## Tablas de esta fase (Phase 1)
- `clientes` → Definidas en `scripts/schema/phase1_schema.sql`
- `productos` → Definidas en `scripts/schema/phase1_schema.sql`
- `ventas` → Definidas en `scripts/schema/phase1_schema.sql`

**Para crear las tablas de Phase 1:**
```bash
sqlite3 retail_plus.db < scripts/schema/phase1_schema.sql
```

## Queries solicitadas por el gerente
1. Total de ventas en el último mes.
2. Top 5 productos por unidades vendidas en las últimas 4 semanas.
3. Ticket promedio por cliente en el periodo seleccionado.

## Ejercicios
Objetivo: realizar las consultas y construcciones en pareja o en grupos pequeños durante la sesión. Cada ejercicio debe entregarse como un archivo `.sql` con comentarios breves que expliquen la lógica.

Ejercicios:
1. Crear las tablas mínimas `clientes`, `productos` y `ventas` (campos sugeridos: id, nombre, precio, fecha, cliente_id, producto_id, cantidad, total). Comparte el DDL con el grupo.
2. Insertar al menos 10 filas de ejemplo que simulen compras en dos semanas diferentes (varia fechas y compradores). Hacerlo en clase: cada pareja inserta datos distintos y luego se mezclan para pruebas.
3. Escribir en grupo la consulta que devuelve el Top 5 de productos por unidades vendidas en las últimas 4 semanas. Explicar la elección de filtros y agrupaciones.
4. Crear una consulta que muestre los 10 clientes con mayor gasto total (SUM(total)). Discutir qué significa "mayor gasto" y cómo puede distorsionarse por outliers.
5. Encontrar las ventas con descuento mayor al 10% y listar cliente y producto asociado (si existe campo `descuento_pct`). Si no existe el campo, explicar cómo añadirlo y actualizar algunos registros de ejemplo.

Pistas rápidas:
- Usa `GROUP BY` y `ORDER BY SUM(cantidad)` para el top de productos.
- `strftime('%Y-%m', fecha)` es útil para agrupar por mes en SQLite.
- Para encontrar la primera compra por cliente usa `MIN(fecha)` o una subconsulta correlacionada.

Entrega en clase: cada grupo envia por correo su archivo `.sql` o lo comparte por pantalla para revisión. Anotar 1 ó 2 discusiones sobre por qué una consulta puede ser lenta con datos grandes.

## Ejercicios guiados (con solución desplegable)

Estos ejercicios guiados están pensados para que el instructor explique paso a paso y los alumnos ejecuten las consultas. Cada paso incluye una pista y una solución oculta que puedes desplegar.

1) Crear las tablas mínimas y verificar integridad

- Acción: crea `clientes`, `productos` y `ventas` (usando `PRIMARY KEY` y `FOREIGN KEY`).
- Pista: usa `CREATE TABLE IF NOT EXISTS` y revisa `PRAGMA foreign_keys`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
-- Modelo mínimo
CREATE TABLE IF NOT EXISTS clientes (
  cliente_id INTEGER PRIMARY KEY,
  nombre TEXT
);

CREATE TABLE IF NOT EXISTS productos (
  producto_id INTEGER PRIMARY KEY,
  nombre TEXT,
  precio REAL
);

CREATE TABLE IF NOT EXISTS ventas (
  venta_id INTEGER PRIMARY KEY,
  fecha TEXT,
  cliente_id INTEGER,
  producto_id INTEGER,
  cantidad INTEGER,
  total REAL,
  FOREIGN KEY(cliente_id) REFERENCES clientes(cliente_id),
  FOREIGN KEY(producto_id) REFERENCES productos(producto_id)
);
```

</details>

--------------------

2) Insertar datos de ejemplo y comprobar resultados

- Acción: inserta varias filas (mínimo 8–12) distribuidas en dos semanas.
- Pista: usa `INSERT INTO` y consulta `SELECT COUNT(*) FROM ventas`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
INSERT INTO clientes (nombre) VALUES ('Ana'), ('Luis');
INSERT INTO productos (nombre, precio) VALUES ('Camiseta', 15.0), ('Taza', 8.0), ('Gorra', 12.0);
INSERT INTO ventas (fecha, cliente_id, producto_id, cantidad, total) VALUES
('2025-09-01', 1, 1, 2, 30.0),
('2025-09-02', 2, 2, 1, 8.0),
('2025-09-05', 1, 1, 1, 15.0),
('2025-09-08', 2, 3, 3, 36.0);
```

</details>

-----

3) Consulta: Top 5 productos en las últimas 4 semanas

- Acción: escribe la consulta que agrupe por producto y ordene por unidades vendidas.
- Pista: usa `SUM(cantidad)`, `GROUP BY` y `date('now', '-28 days')`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
SELECT p.producto_id, p.nombre, SUM(v.cantidad) AS unidades_vendidas
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
WHERE date(v.fecha) >= date('now', '-28 days')
GROUP BY p.producto_id, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 5;
```

</details>

---

## Ejercicios (dificultad creciente)

Los siguientes ejercicios son para que los alumnos resuelvan en clase. Las soluciones están en `scripts/solutions/01_clase1_solution.sql`.

Nivel 1 (básico)
1. Total de ventas en el último mes.
2. Ticket promedio por cliente en el periodo seleccionado.

Nivel 2 (intermedio)
3. Top 5 productos por unidades vendidas en las últimas 4 semanas.
4. 10 clientes con mayor gasto total (SUM(total)).

Soluciones: `scripts/solutions/01_clase1_solution.sql`
