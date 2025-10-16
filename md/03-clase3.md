# Extensión analítica

## Escenario y petición
El director de marketing quiere medir el impacto de la última campaña: "Lanzamos una campaña el mes pasado; necesito saber si aumentó las ventas de los productos promocionados y si su tasa de devolución cambió".

Hoy nos ponemos del lado del analista que cruza múltiples fuentes (ventas, campañas, devoluciones e inventario) para medir impacto y riesgos.

## Fundamentos teóricos
En esta sesión repasaremos conceptos analíticos y temporales que facilitan la transformación de eventos transaccionales en métricas:

- Agregaciones por periodo y comparación de ventanas temporales (p. ej. 30 días antes vs 30 días después).
- Métricas derivadas: tasas (devoluciones/ventas), rotación de inventario (ventas / promedio_inventario) y CLTV básico.
- Uso de Expresión de Tabla Común (CTEs) para organizar pasos de transformación y hacer el SQL más legible y auditable.
- Consideraciones de sesgo y normalización: por qué comparar tasas y no solo totales cuando los volúmenes cambian.

## Objetivos
1. Modelar tablas analíticas: `campanas_marketing`, `campanas_productos`, `devoluciones`, `inventario`, `envios`.
2. Calcular métricas: tasa de devoluciones, rotación de inventario, y efecto de campañas.
3. Aprender a conectar temporalidad con eventos de campaña (windowing / periodos antes/después).

## Concepto explicado con ejemplo
Para medir el efecto de una campaña necesitas comparar métricas antes y después del inicio de la campaña. La técnica más simple es una comparación de ventanas temporales (p. ej. 30 días antes vs 30 días después). También conviene normalizar por volumen (tasas) para evitar sesgos.

## Plan de trabajo
1. Crear o revisar tablas: `campanas_marketing(campana_id, nombre, fecha_inicio, fecha_fin)`, `campanas_productos(campana_id, producto_id)`, `devoluciones`, `inventario`.
2. Calcular ventas de productos en ventanas temporales y comparar.
3. Calcular tasa de devoluciones por producto y por campaña.

## Ejercicios guiados

1) Ventas de productos en campaña (30 días)

- Acción: usa CTEs para seleccionar productos de la campaña y filtrar ventas en la ventana de 30 días.
- Pista: crea una CTE `productos_campana` y una CTE `ventas_campana`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
WITH productos_campana AS (
  SELECT producto_id FROM campanias_productos WHERE campana_id = 1
), ventas_campana AS (
  SELECT v.* FROM ventas v
  JOIN productos_campana pc ON v.producto_id = pc.producto_id
  JOIN campanias_marketing c ON c.campana_id = 1
  WHERE date(v.fecha) BETWEEN date(c.fecha_inicio) AND date(c.fecha_inicio, '+30 days')
)
SELECT SUM(cantidad) AS unidades_vendidas, SUM(total) AS ingresos
FROM ventas_campana;
```

</details>

2) Tasa de devoluciones por producto

- Acción: calcula unidades devueltas vs unidades vendidas en la ventana.
- Pista: usa `LEFT JOIN` y maneja `NULL` con `NULLIF`.

<details>
<summary>Solución guía (desplegar)</summary>

```sql
SELECT pc.producto_id,
       SUM(d.cantidad) AS unidades_devueltas,
       SUM(v.cantidad) AS unidades_vendidas,
       CAST(SUM(d.cantidad) AS FLOAT) / NULLIF(SUM(v.cantidad), 0) AS tasa_devoluciones
FROM campanias_productos pc
LEFT JOIN ventas v ON v.producto_id = pc.producto_id
LEFT JOIN devoluciones d ON d.venta_id = v.venta_id
WHERE date(v.fecha) BETWEEN date('2025-08-01') AND date('2025-08-31')
GROUP BY pc.producto_id;
```

</details>

---

## Ejercicios (dificultad creciente))

Soluciones: `scripts/solutions/03_clase3_solution.sql`

Nivel 1 (básico)
1. Ventas totales de productos de la campaña en 30 días posteriores al inicio.
2. Unidades vendidas por producto en la misma ventana.

Nivel 2 (intermedio)
3. Tasa de devoluciones por producto en la ventana seleccionada.
4. Rotación de inventario (ventas / promedio inventario) por producto.

Nivel 3 (avanzado)
5. Construir una vista que cruce ventas, devoluciones e inventario y permita filtrar por sucursal y campaña.
