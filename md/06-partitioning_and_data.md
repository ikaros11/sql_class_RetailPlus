# Particionado lógico y volumen de datos — recomendaciones

Este documento explica recomendaciones para: (1) particionado lógico en SQLite (simulado), (2) si el dataset actual es suficiente para ejercicios, y (3) buenas prácticas para añadir datos.

## 1) ¿Los datos actuales son suficientes?

Resumen rápido:
- `data/ventas.csv` contiene ~8k filas. `productos.csv` y `clientes.csv` contienen cientos de filas. `inventario.csv` contiene >11k filas con series temporales por sucursal.
- Para ejercicios de aula (joins, agregaciones, ventanas y rendimiento básico) el volumen es suficiente: permite ejemplos variados (fechas, sucursales, empleados, devoluciones, campañas).

Sin embargo, para practicar temas de escalabilidad (particionado, particionado por tiempo, consultas en millones de filas, índices a gran escala) necesitarás datos sintéticos más grandes (por ejemplo, 1M filas en `ventas`).

Recomendaciones:
- Mantén este dataset como "entorno de enseñanza"; es ideal para demos interactivas.
- Si quieres añadir ejercicios sobre rendimiento a gran escala, genera datos sintéticos con un script que multiplique filas (ver sección "Generar datos sintéticos").

## 2) Índices y vistas
- Crea índices en columnas usadas en JOINs y filtros frecuentes (producto_id, fecha, sucursal_id, empleado_id, cliente_id).
- Añade vistas para consolidar KPIs y simplificar consultas en clase (ej.: `vw_kpis_sucursal`, `vw_top_productos`, `vw_ventas_detalle`).
-- Archivo de ejemplo: `scripts/olap/05_views_indices.sql` (incluye CREATE INDEX y CREATE VIEW).

## 3) Particionado lógico (simulado) en SQLite
SQLite no soporta particionado nativo tipo PostgreSQL o BigQuery. Se usan alternativas:

1. Particionado por tablas (sharding lógico): crear tablas por periodo, p.ej. `ventas_2023`, `ventas_2024`. Para consultas globales, se usan UNION ALL o vistas que agrupen estas tablas.

2. Particionado por vistas/materialización: mantén una tabla maestra pero crea vistas con filtros por rango de fecha para acelerar algunas consultas.

3. Uso de attached databases: puedes almacenar particiones en archivos `.db` separados y usar `ATTACH 'ventas_2023.db' AS ventas_2023;` y consultar con `UNION ALL`.

Recomendación práctica de curso:
- Enseña la idea de particionado mediante tablas `ventas_YYYY` y una vista `vw_ventas_all` que haga `UNION ALL` de las particiones. Es didáctico y reproduce el comportamiento de particionado.

Ejemplo de particionado por tablas:

```sql
-- Crear particiones por año (solo como ejemplo)
CREATE TABLE ventas_2023 AS SELECT * FROM ventas WHERE strftime('%Y', fecha) = '2023';
CREATE TABLE ventas_2024 AS SELECT * FROM ventas WHERE strftime('%Y', fecha) = '2024';

CREATE VIEW vw_ventas_all AS
SELECT * FROM ventas_2023
UNION ALL
SELECT * FROM ventas_2024;
```

## 4) Generar datos sintéticos (si se requiere escala)
Puedes generar datos con Python (pandas) o con un script SQL que duplique filas.

Ejemplo rápido con Python (pseudocódigo):

```python
import pandas as pd
v = pd.read_csv('data/ventas.csv')
# Repetir 1000 veces con pequeñas variaciones en fecha para simular 1M filas
frames = []
for i in range(1000):
    tmp = v.copy()
    tmp['fecha'] = pd.to_datetime(tmp['fecha']) + pd.to_timedelta(i, unit='d')
    frames.append(tmp)
big = pd.concat(frames, ignore_index=True)
big.to_csv('data/ventas_big.csv', index=False)
```

## 5) Buenas prácticas de datos para el curso
- Mantén una copia original de `retail_plus.db` antes de hacer transformaciones.
-- Documenta cualquier script que genere datos sintéticos y añádelo a `scripts/seed/`.
- Para ejercicios de índice y EXPLAIN, crea datasets medianos (100k-500k filas) que permitan ver diferencias de tiempo sin necesitar infraestructuras pesadas.

## 6) Resumen y recomendación
- Los datos actuales son adecuados para el contenido del curso tal como está. Para incluir lecciones de rendimiento a gran escala, añade un módulo opcional que genere datos sintéticos y enseñe particionado lógico.

---

Archivo creado automáticamente por la sesión de enriquecimiento de la documentación.
