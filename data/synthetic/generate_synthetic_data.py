"""Generador sintético para RetailPlus
Genera CSV para ventas, clientes, productos, inventario y devoluciones.
Uso: python generate_synthetic_data.py --rows 100000 --outdir ./output
"""
import argparse
import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

PRODUCT_CATEGORIES = ['Electrónica','Hogar','Oficina','Moda','Juguetes','Deportes','Libros','Jardín','Alimentación']

def gen_products(n_products=500):
    products = []
    for i in range(1, n_products+1):
        products.append({
            'producto_id': i,
            'sku': f'SKU-{i:06d}',
            'nombre': f'Producto_{i}',
            'categoria': random.choice(PRODUCT_CATEGORIES),
            'precio': round(random.uniform(5.0, 200.0),2),
            'costo': round(random.uniform(2.0, 150.0),2)
        })
    return products

def gen_clients(n_clients=2000):
    clients = []
    for i in range(1, n_clients+1):
        clients.append({
            'id': i,
            'nombre': f'Cliente_{i}',
            'ciudad': random.choice(['Madrid','Barcelona','Valencia','Sevilla','Zaragoza','Málaga','Bilbao','Murcia']),
            'region': 'Region',
            'fecha_alta': (datetime(2022,1,1) + timedelta(days=random.randint(0,900))).date().isoformat()
        })
    return clients


def gen_ventas(n_rows, products, clients, n_sucursales=10, n_empleados=50):
    rows = []
    start_date = datetime(2023,1,1)
    for i in range(1, n_rows+1):
        prod = random.choice(products)
        client = random.choice(clients)
        fecha = (start_date + timedelta(days=random.randint(0, 700))).date().isoformat()
        cantidad = random.choices([1,1,1,2,3],weights=[0.6,0.6,0.6,0.15,0.05])[0]
        descuento = random.choice([0.0,0.05,0.1]) if random.random() < 0.1 else 0.0
        total = round(prod['precio']*cantidad*(1-descuento),2)
        rows.append({
            'id': i,
            'fecha': fecha,
            'cliente_id': client['id'],
            'producto_id': prod['producto_id'],
            'cantidad': cantidad,
            'descuento_pct': descuento,
            'empleado_id': random.randint(1,n_empleados),
            'sucursal_id': random.randint(1,n_sucursales),
            'forma_pago_id': random.randint(1,4),
            'total': total
        })
    return rows


def gen_inventario(products, n_sucursales=10, months=24):
    rows = []
    start = datetime(2023,1,1)
    for s in range(1, n_sucursales+1):
        for p in products:
            stock = random.randint(10,200)
            for m in range(months):
                fecha = (start + timedelta(days=30*m)).date().isoformat()
                rows.append({'sucursal_id': s, 'producto_id': p['producto_id'], 'fecha': fecha, 'stock': stock})
    return rows


def gen_devoluciones(ventas_rows, pct=0.02):
    devs = []
    vid_sample = random.sample(ventas_rows, max(1,int(len(ventas_rows)*pct)))
    id_seq = 1
    for v in vid_sample:
        devs.append({'devolucion_id': id_seq, 'venta_id': v['id'], 'producto_id': v['producto_id'], 'cantidad': 1, 'fecha': v['fecha']})
        id_seq += 1
    return devs


def write_csv(rows, outpath, fieldnames):
    Path(outpath).parent.mkdir(parents=True, exist_ok=True)
    with open(outpath, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            w.writerow(r)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rows', type=int, default=100000, help='Número de filas en ventas')
    parser.add_argument('--outdir', type=str, default='./data/synthetic/output', help='Directorio de salida')
    args = parser.parse_args()

    products = gen_products(800)
    clients = gen_clients(2000)
    ventas = gen_ventas(args.rows, products, clients)
    inventario = gen_inventario(products)
    devoluciones = gen_devoluciones(ventas, pct=0.02)

    outdir = Path(args.outdir)
    write_csv(products, outdir / 'productos_synthetic.csv', ['producto_id','sku','nombre','categoria','precio','costo'])
    write_csv(clients, outdir / 'clientes_synthetic.csv', ['id','nombre','ciudad','region','fecha_alta'])
    write_csv(ventas, outdir / 'ventas_synthetic.csv', ['id','fecha','cliente_id','producto_id','cantidad','descuento_pct','empleado_id','sucursal_id','forma_pago_id','total'])
    write_csv(inventario, outdir / 'inventario_synthetic.csv', ['sucursal_id','producto_id','fecha','stock'])
    write_csv(devoluciones, outdir / 'devoluciones_synthetic.csv', ['devolucion_id','venta_id','producto_id','cantidad','fecha'])

    print(f'Generados archivos en {outdir.resolve()}')

if __name__ == '__main__':
    main()
