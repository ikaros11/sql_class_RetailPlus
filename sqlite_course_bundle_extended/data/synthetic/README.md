Generación de datos sintéticos para RetailPlus

Este directorio contiene un script para generar datasets sintéticos que permiten a l@s alumn@s escalar el volumen de datos localmente sin subir archivos pesados al repositorio.

Archivos:
- `generate_synthetic_data.py` — Script Python que genera CSV para `ventas`, `clientes`, `productos`, `inventario` y `devoluciones`.

Cómo usar (Windows PowerShell):
1. Asegúrate de tener Python 3.8+ instalado.
2. Abre PowerShell en la raíz del proyecto.
3. Ejecuta:

```powershell
python .\data\synthetic\generate_synthetic_data.py --rows 100000 --outdir .\data\synthetic\output
```

Parámetros:
- `--rows`: cantidad aproximada de filas para `ventas` (default: 100000).
- `--outdir`: directorio donde se escribirán los CSV generados.

Notas:
- El script es intencionalmente simple y utiliza distribuciones aleatorias para fechas, productos y sucursales.
- No está pensado para producción; es una herramienta de enseñanza para mostrar efectos de volumen, índices y particionado.

Si quieres, puedo generar un archivo de ejemplo (`ventas_big.csv`) aquí, pero recomiendo que cada alumno lo ejecute localmente para evitar subir archivos pesados al repositorio.
