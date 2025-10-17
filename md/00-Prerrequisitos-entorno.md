# Preparación del entorno (GUI) — DB Browser for SQLite

**Objetivo:** Dejar listo el entorno para ejecutar consultas SQL usando **solo la interfaz gráfica (GUI)** de **DB Browser for SQLite** con la base de datos del curso *RetailPlus*.

> Nota: No es necesario instalar nada más ni usar línea de comandos. Trabajaremos exclusivamente con la GUI.

---

## 1) Instalar DB Browser for SQLite

1. Abre el sitio oficial de **DB Browser for SQLite** y descarga el instalador para tu sistema (Windows, macOS o Linux).
2. Ejecuta el instalador con opciones por defecto (Siguiente → Siguiente → Finalizar).
3. Abre la aplicación **DB Browser for SQLite**.

> Si ya lo tenías instalado, asegúrate de que abre correctamente antes de la clase.

---

## 2) Obtener los materiales del curso

Asegúrate de tener la carpeta: `sqlite_course_bundle_extended/` con esta estructura mínima:

```
sqlite_course_bundle_extended/
├── retail_plus.db
├── data/
│   ├── clientes.csv
│   ├── productos.csv
│   ├── ventas.csv
│   ├── sucursales.csv
│   ├── empleados.csv
│   ├── formas_pago.csv
│   ├── devoluciones.csv
│   ├── inventario.csv
│   ├── campanias_marketing.csv
│   ├── campanias_productos.csv
│   └── envios.csv
└── scripts/
    ├── 00_schema_extended.sql
    ├── 01_seed_from_csv.sql
    ├── 02_queries_analitica_basica.sql
    ├── 03_queries_avanzadas_olap.sql
    └── 04_proyecto_final_extend.sql
```

---

## 3) Abrir la base de datos del curso

1. En **DB Browser for SQLite**, clic en **“Open Database”** (Abrir base de datos).
2. Selecciona el archivo **`retail_plus.db`** dentro de la carpeta del curso.
3. Verás las tablas en el panel **“Database Structure”** (Estructura de la BD).

> Si prefieres crear una base vacía desde cero, usa **“New Database”**, luego ve a la pestaña **Execute SQL** y ejecuta el script `scripts/00_schema_extended.sql`, y después importa los CSV (paso 4).

Nota: los scripts ahora están organizados en subcarpetas dentro de `scripts/` (por ejemplo `scripts/schema/`, `scripts/seed/`, `scripts/queries/`, `scripts/olap/`). Si no encuentras un archivo en la raíz de `scripts/`, revisa las carpetas mencionadas.

---

## 4) (Opcional) Importar CSV desde la GUI

Si estás trabajando con una base vacía o quieres reconstruirla:

1. Ve a la pestaña **“Browse Data”** para verificar tablas (o créalas con el script 00 si no existen).
2. Menú **File → Import → Table from CSV file…**
3. Elige un CSV de la carpeta `data/` (por ejemplo, `clientes.csv`).
4. Configura:
   - **Field separator**: `,` (coma)
   - **First row is header**: ✓ (activado)
   - **Table name**: el nombre de la tabla (p. ej., `clientes`)
5. Repite para cada CSV: `productos`, `ventas`, `sucursales`, `empleados`, `formas_pago`, `devoluciones`, `inventario`, `campanias_marketing`, `campanias_productos`, `envios`.
6. Pulsa **Write Changes** (Guardar cambios) en la barra superior para confirmar.

> Consejo: importa primero las tablas “maestras” (dimensiones) como `categorias`, `productos`, `clientes`, `sucursales`, `empleados`, `formas_pago` y luego `ventas` y el resto.

---

## 5) Ejecutar los scripts de ejemplo (GUI)

1. Pestaña **“Execute SQL”**.
2. Abre el script con **File → Open SQL file…** y elige por ejemplo `scripts/queries/02_queries_analitica_basica.sql`.
3. Clic en **▶ Execute** para correr todas las consultas (o selecciona un bloque y ejecuta solo ese fragmento).
4. Los resultados aparecen en la parte inferior (pestaña **“Results”**).

> Cuando termines, pulsa **Write Changes** si has hecho modificaciones (por ejemplo, creado vistas).

---

## 6) Prueba rápida (sanity check)

En la pestaña **Execute SQL**, copia y ejecuta estas consultas:

```sql
-- ¿Cuántas ventas hay registradas?
SELECT COUNT(*) AS total_ventas FROM ventas;

Si obtienes resultados sin errores, ¡ya estás listo!
```
---

## 7) Problemas comunes y soluciones rápidas

- **No aparecen tablas:** asegúrate de haber abierto `retail_plus.db` correcto o de haber importado los CSV en tablas con el nombre correcto.  
- **Error al importar CSV:** revisa que **First row is header** esté marcado y que el separador sea coma.  
- **No ves cambios:** pulsa **Write Changes** para guardar.  
- **Consulta falla por nombre de tabla o columna:** verifica ortografía y mayúsculas/minúsculas en el panel **Database Structure**.

---

## 8) Recomendaciones para clase

- Ten la pestaña **Execute SQL** lista y la de **Browse Data** abierta en paralelo.  
- Ejecuta los scripts del curso en orden para que todo el grupo vea los mismos resultados.  
- Guarda una copia de **`retail_plus.db`** como respaldo por si necesitas volver al punto de partida.

---

## Uso desde línea de comandos (opcional)

Si prefieres usar la consola, `sqlite3` es una opción ligera. En Windows, puedes usar la versión incluida en algunas instalaciones o instalar SQLite y luego ejecutar desde PowerShell.

Ejemplos de comandos en PowerShell (asumiendo `sqlite3.exe` en PATH):

```powershell
# Abrir una sesión interactiva
sqlite3.exe .\retail_plus.db

# En la consola sqlite3: listar tablas
.tables

# Salir de sqlite3
.quit
```

Comandos útiles para inspección rápida sin entrar a sqlite3:

```powershell
# Consultar número de filas de ventas (usa sqlite3 para ejecutar la query directamente)
sqlite3.exe .\retail_plus.db "SELECT COUNT(*) FROM ventas;"

# Exportar lista de tablas
sqlite3.exe .\retail_plus.db ".schema" > esquema.sql
```

---

## Comprobaciones de integridad simples

Antes de empezar las prácticas grandes, es útil validar que los datos principales existen y tienen sentido:

- Verifica que hay registros en `ventas` y `productos`.
- Revisa que `ventas` tenga fechas válidas y montos positivos.
- Comprueba que las claves foráneas (product_id, cliente_id, sucursal_id) aparecen en las tablas maestras.

Ejemplo (sqlite3):

```sql
-- Ventas con monto nulo o negativo
SELECT * FROM ventas WHERE total IS NULL OR total <= 0 LIMIT 10;

-- Productos referenciados por ventas pero no encontrados en productos
SELECT v.* FROM ventas v LEFT JOIN productos p ON v.producto_id = p.producto_id WHERE p.producto_id IS NULL LIMIT 10;
```

---

## Soporte y contacto

Si detectas datos corruptos o archivos CSV faltantes, guarda los mensajes de error y abre un issue o contacta al instructor con los logs y las consultas que fallan.
