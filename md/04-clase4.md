# Informe ejecutivo

## Escenario y petición
La dirección (CEO y CFO) pide un informe consolidado trimestral: "Queremos ver, en una sola vista, ventas, margen estimado, top productos y cumplimiento de SLA". No buscan consultas largas: quieren tablas y gráficos listos para presentar.

El reto del día es transformar análisis detallado en una vista ejecutiva reproducible.

## Objetivos
1. Construir CTEs y vistas que consoliden métricas clave en una sola consulta.
2. Aprender a estructurar un informe: KPIs, tablas y fuentes de datos.
3. Preparar una vista o conjunto de consultas que puedan exportarse a CSV para la dirección.

## Concepto explicado con ejemplo
Piensa en CTEs como mini-tablas temporales que limpian y preparan datos por pasos: primero filtras, luego agregas y finalmente unes los resultados. Eso facilita auditar cada etapa y explicar a dirección cómo se llegó al número final.

## Fundamentos teóricos
En el Día 4 veremos conceptos clave para transformar análisis en informes reproducibles y eficientes:

- OLAP vs OLTP: entender la diferencia entre datos transaccionales (detalle) y modelos analíticos (agregaciones y consultas ad-hoc).
- Esquema estrella (star schema): dimensiones (`dim_*`) y tabla de hechos (`fact_sales`) como patrón para facilitar agregaciones y mejorar legibilidad de consultas analíticas.
- CTEs y vistas: mejores prácticas para estructurar transformaciones en pasos auditables y reutilizables.
- Índices y rendimiento: cuáles son los índices más útiles en esquemas analíticos, cómo medir impacto (timings y EXPLAIN) y trade-offs entre lectura y escritura.

## Ejercicios

Objetivo: construir de forma colaborativa una vista ejecutiva y medir rendimiento con datos grandes.

Actividades en clase:
1. En grupo, crear la vista `vw_informe_trimestral` que contenga: `total_ventas`, `ticket_promedio`, `top5_productos` (como texto o subconsulta), `tasa_devoluciones` y `porcentaje_cumplimiento_sla`.
2. Generar datos sintéticos si no se han generado ya (ver sección "Inicio del Día 4"). Cada grupo puede generar N filas para comparar tiempos.
3. Ejecutar una consulta pesada que cruce `fact_sales` con dimensiones y medir el tiempo con `.timer on` en sqlite3.
4. Crear un índice propuesto (por ejemplo sobre `fact_sales(dim_date_id, dim_product_id)`) y repetir la medición. Documentar la mejora.
5. Exportar los KPIs por sucursal a CSV usando la vista.

Pistas:
- Usa CTEs para limpiar y preparar datos paso a paso.
- Usa `.timer on` en sqlite3 para medir tiempos y comparar con/without índices.

Entrega: un breve informe (MD o notebook) con las consultas, tiempos antes/después y una recomendación sobre índices o diseño.
## Ejercicios guiados (con solución desplegable)

Estas actividades son para guiar a los alumnos en la construcción de la vista ejecutiva.

1) Preparar KPIs por sucursal

- Acción: crea CTEs para limpiar ventas y agregar por sucursal.
- Pista: empieza con `ventas_limpias` que convierta `fecha` a `date()`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
WITH ventas_limpias AS (
  SELECT v.*, date(v.fecha) AS fecha_real FROM ventas v WHERE v.total IS NOT NULL
), kpis_sucursal AS (
  SELECT s.sucursal_id, s.nombre,
         SUM(v.total) AS total_ventas,
         AVG(v.total) AS ticket_promedio,
         SUM(CASE WHEN v.es_devolucion = 1 THEN 1 ELSE 0 END) AS devoluciones
  FROM ventas_limpias v
  JOIN sucursales s ON v.sucursal_id = s.sucursal_id
  GROUP BY s.sucursal_id
)
SELECT * FROM kpis_sucursal;

-- Crear vista
CREATE VIEW IF NOT EXISTS vw_informe_trimestral AS
SELECT * FROM kpis_sucursal;
```

</details>

2) Medir rendimiento y proponer índices

- Acción: ejecuta consultas pesadas y mide `.timer on` antes/después de crear índices.
- Pista: crea índices sobre columnas de filtro y join en `fact_sales`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
-- Ejemplo de índice
CREATE INDEX IF NOT EXISTS idx_fact_date_product ON fact_sales(date_key, product_key);
-- Luego mide tiempos con sqlite3: .timer on
```

</details>

---

## Ejercicios

Soluciones: `scripts/solutions/04_clase4_solution.sql`

Nivel 1 (básico)
1. Construir `vw_informe_trimestral` con total_ventas y ticket_promedio por sucursal.
2. Exportar KPIs a CSV.

Nivel 2 (intermedio)
3. Incluir top5_productos por sucursal en la vista (como subconsulta o texto concatenado).
4. Medir tiempos de consulta sin índices.

Nivel 3 (avanzado)
5. Crear índices propuestos, medir mejora y documentar resultados en un informe breve.

## Inicio del Día 4 — Generar datos sintéticos (opcional pero recomendado)

Para simular cargas más grandes y observar el efecto de índices/particionado, iniciaremos el Día 4 generando datos sintéticos. Ejecuta en PowerShell desde la raíz del proyecto:

```powershell
# Generar 200000 filas en ventas (ajusta --rows según necesidad)
python .\data\synthetic\generate_synthetic_data.py --rows 200000 --outdir .\data\synthetic\output
```

El script creará CSV en `data/synthetic/output/`. Después importa los CSV con `scripts/seed/01_seed_from_csv.sql` (ajusta rutas) o importa manualmente los archivos grandes.

## Tablas y acciones de esta fase (Phase 4)
- Ejecutar `phase4_olap_star.sql` para crear dimensiones y la tabla de hechos `fact_sales`.
- Poblaremos `fact_sales` a partir de las tablas transaccionales (ventas, productos, clientes, sucursales, empleados, formas_pago).

## Queries solicitadas por la dirección (Día 4)
1. Informe trimestral por región: total ventas, margen y margen %.
2. Top 5 productos por ingresos en el trimestre.
3. SLA promedio por transportista (dias entre envío y entrega).
4. Consultas OLAP sobre `fact_sales`: ventas por (dim_date.year, dim_product.categoria, dim_store.region).
