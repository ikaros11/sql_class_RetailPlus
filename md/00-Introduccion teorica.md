# Introducción a SQL y Bases de Datos

## 1. ¿Qué es una base de datos?

Una **base de datos** es un sistema que permite **almacenar, organizar y consultar información** de forma estructurada.

### Elementos principales
- **Tabla:** conjunto de datos sobre un tema (por ejemplo, *Clientes*, *Productos* o *Ventas*).
- **Fila (registro):** una observación individual (por ejemplo, un cliente).
- **Columna (campo):** una característica o atributo (por ejemplo, *nombre*, *precio*).

### Ejemplo

| id_cliente | nombre        | ciudad    |
|-------------|---------------|------------|
| 1           | Ana García    | Madrid     |
| 2           | Carlos López  | Valencia   |

Cada tabla se asocia con otras mediante **claves**:
- **Clave primaria (PK):** identifica de forma única cada fila.
- **Clave foránea (FK):** enlaza una tabla con otra.

---

## 2. ¿Qué es SQL?

**SQL (Structured Query Language)** es el lenguaje estándar para **interactuar con bases de datos relacionales**.

Permite:
- Crear estructuras (`CREATE TABLE`)
- Insertar datos (`INSERT INTO`)
- Consultar información (`SELECT`)
- Actualizar o eliminar registros (`UPDATE`, `DELETE`)

Es un lenguaje **declarativo**, lo que significa que decimos *qué queremos obtener*, no *cómo hacerlo*.

---

## 3. Tipos de comandos SQL

SQL se organiza en diferentes **subgrupos de sentencias**, según su propósito:

| Tipo | Significado | Ejemplos | Descripción |
|------|--------------|-----------|--------------|
| **DDL** | *Data Definition Language* | `CREATE`, `ALTER`, `DROP` | Define la estructura de la base de datos (tablas, vistas, índices). |
| **DML** | *Data Manipulation Language* | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | Manipula los datos dentro de las tablas. |
| **DCL** | *Data Control Language* | `GRANT`, `REVOKE` | Controla permisos de acceso. *(no lo usaremos en SQLite)* |
| **TCL** | *Transaction Control Language* | `COMMIT`, `ROLLBACK` | Administra transacciones y confirmaciones. *(no lo usaremos en profundidad)* |

---

## 4. ¿Qué es una *query*?

Una **query** (consulta) es una instrucción SQL que pide datos a la base.

**Ejemplo:**

```sql
SELECT nombre, ciudad
FROM clientes
WHERE ciudad = 'Madrid';
````

📋 **Explicación:**

1. `SELECT` → indica las columnas que queremos ver.
2. `FROM` → indica la tabla de donde vienen los datos.
3. `WHERE` → filtra los registros.

🧩 **Resultado:**

| nombre     | ciudad |
| ---------- | ------ |
| Ana García | Madrid |

---

## 5. Orden lógico de ejecución de una query SQL

Aunque escribimos la consulta de arriba hacia abajo, el motor de base de datos **no ejecuta en ese orden**.

**Orden interno de ejecución:**

1. `FROM` → Se localizan las tablas.
2. `JOIN` → Se combinan tablas relacionadas.
3. `WHERE` → Se filtran registros.
4. `GROUP BY` → Se agrupan resultados.
5. `HAVING` → Se filtran grupos.
6. `SELECT` → Se eligen las columnas finales.
7. `ORDER BY` → Se ordenan los resultados.
8. `LIMIT` → Se restringe el número de filas.

Ejemplo práctico:

````sql
SELECT sucursal, SUM(cantidad * precio) AS total_ventas
FROM ventas
WHERE fecha >= '2024-01-01'
GROUP BY sucursal
ORDER BY total_ventas DESC;
````

---

## 6. Buenas prácticas básicas en SQL

* Escribe las **palabras clave en mayúsculas** (`SELECT`, `FROM`, `WHERE`).
* Usa **comentarios** para explicar partes del código:

  ````sql
  -- Ventas totales por sucursal
  ````
* Termina las sentencias con **punto y coma `;`**.
* Usa **alias** (`AS`) para mejorar la legibilidad de las columnas.
* Evita los `SELECT *` en bases grandes (consume más recursos).

---

## 7. Conceptos complementarios

### 7.1. Relación entre tablas

Las bases de datos relacionales conectan información mediante claves:

* **Uno a muchos:** un cliente puede tener muchas ventas.
* **Muchos a uno:** muchas ventas pertenecen a una sucursal.
* **Muchos a muchos:** productos que aparecen en muchas campañas (requieren tablas intermedias).

### 7.2. Integridad referencial

Evita que existan datos huérfanos (por ejemplo, una venta que apunte a un cliente que no existe).

---

## 8. Ejercicio conceptual

1. ¿Qué diferencia hay entre DDL y DML?
2. ¿Qué comando usarías para crear una tabla?
3. ¿Qué parte del SQL define qué datos se filtran?
4. Ordena correctamente: `SELECT`, `GROUP BY`, `FROM`, `WHERE`, `ORDER BY`.

---

## 9. Mini práctica inicial

En DB Browser for SQLite, abre una base nueva y prueba:

````sql
CREATE TABLE clientes (
  id INTEGER PRIMARY KEY,
  nombre TEXT,
  ciudad TEXT
);

INSERT INTO clientes (nombre, ciudad) VALUES
('Ana García', 'Madrid'),
('Carlos López', 'Valencia'),
('Lucía Pérez', 'Madrid');

SELECT * FROM clientes WHERE ciudad = 'Madrid';
````

Si ves dos resultados en la tabla, tu entorno está listo. 🎉

---

## 10. Resumen visual

| Concepto          | Descripción                                            |
| ----------------- | ------------------------------------------------------ |
| **Base de datos** | Colección de tablas relacionadas.                      |
| **Tabla**         | Conjunto de registros sobre un tema.                   |
| **SQL**           | Lenguaje para interactuar con la base de datos.        |
| **DDL**           | Define la estructura.                                  |
| **DML**           | Manipula los datos.                                    |
| **Query**         | Instrucción SQL para consultar información.            |
| **Orden lógico**  | `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY` |

---

**Próximo paso:**
Abrir *DB Browser for SQLite*, cargar `retail_plus.db` y practicar con las primeras consultas en el **Día 1** del curso.