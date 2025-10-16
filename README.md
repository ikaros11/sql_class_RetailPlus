# Retail Plus (SQLite) — Modelo extendido

Materiales del curso: una base de datos SQLite (`retail_plus.db`), los datos en CSV dentro de `data/`, scripts SQL en `scripts/` y las guías de clase en el directorio `md/`.

Hilo conductor: el curso guía al alumno desde un modelo transaccional mínimo hasta la construcción de un esquema analítico (star schema) y un informe ejecutivo reproducible, enseñando diseño, consultas y optimización paso a paso.

## Objetivo del repositorio

Proveer un caso realista de retail para practicar SQL analítico con SQLite. Incluye desde un esquema extendido hasta consultas OLAP y ejercicios guiados pensados para clases presenciales o autodidactas.

## Estructura del proyecto

- `retail_plus.db` — Base de datos SQLite ya poblada (opcional).
- `data/` — CSV con los datasets (clientes, productos, ventas, sucursales, etc.).
- `scripts/` — Scripts SQL: esquema, seed desde CSV, consultas de ejemplo y proyecto final.
- `md/` — Guiones y planes por día (lecciones, objetivos, ejercicios).
- `00-prerrequisitos-entorno.md` — Instrucciones para preparar el entorno (GUI y CLI).
- `Clase-sql-analitico.md` — Documento principal del curso (objetivos y formato).

## Índice rápido (TOC)

- Lecciones:
  - [Día 1 — Modelo básico](md/01-clase1.md)
  - [Día 2 — Extensión operativa](md/02-clase2.md)
  - [Día 3 — Extensión analítica](md/03-clase3.md)
  - [Día 4 — Informe ejecutivo](md/04-clase4.md)
- Scripts por fase:
  - `scripts/schema/phase1_schema.sql` (Phase 1: tablas básicas)
  - `scripts/schema/phase2_schema.sql` (Phase 2: tablas operativas)
  - `scripts/schema/phase3_schema.sql` (Phase 3: tablas analíticas)
  - `scripts/schema/phase4_olap_star.sql` (Phase 4: star schema OLAP)
- Documentación adicional:
  - [docs/partitioning_and_data.md](docs/partitioning_and_data.md)

## Scripts principales por fase

- **Phase 1**: `scripts/schema/phase1_schema.sql` (crear tablas básicas)
- **Phase 2**: `scripts/schema/phase2_schema.sql` (añadir operativas)
- **Phase 3**: `scripts/schema/phase3_schema.sql` (añadir analíticas)
- **Phase 4**: `scripts/schema/phase4_olap_star.sql` (crear star schema)
- **Soluciones**: `scripts/solutions/` (ejercicios resueltos por día)

## Ejemplo rápido (sanity check)

Si abres `retail_plus.db` en DB Browser for SQLite o usas `sqlite3`, prueba estas consultas para comprobar que está todo bien:

```sql
-- Total de ventas registradas
SELECT COUNT(*) AS total_ventas FROM ventas;

-- Ventas por año
SELECT strftime('%Y', fecha) AS ano, COUNT(*) AS ventas
FROM ventas
GROUP BY ano
ORDER BY ano;
```

## Recomendado para comenzar

1. Lee `00-prerrequisitos-entorno.md` para preparar tu entorno (GUI o CLI).
2. Abre `retail_plus.db` con DB Browser for SQLite o con `sqlite3`.
3. Ejecuta `scripts/02_queries_analitica_basica.sql` y revisa los comentarios.

## Buenas prácticas de clase

- Trabaja en una copia de `retail_plus.db` si vas a modificar datos.
- Importa CSV siguiendo el orden: dimensiones (categorías, productos, clientes, sucursales, empleados) y luego hechos (`ventas`, `devoluciones`, `inventario`).
- Añade índices si necesitas acelerar consultas en tablas grandes.

## Licencia y uso

Este material es de ejemplo para aprendizaje. Puedes reutilizarlo en cursos y talleres citando la fuente.
