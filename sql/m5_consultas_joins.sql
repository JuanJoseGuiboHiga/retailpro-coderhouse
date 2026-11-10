-- =============================================================================
-- NOTA IMPORTANTE PARA LA EJECUCIÓN:
-- Antes de ejecutar este script de consultas, por favor vuelva a correr el 
-- archivo ventas_tech_db.sql (o el script de creación del esquema).
--
-- Se han actualizado estructuras de tablas y agregado nuevos registros (inserts) 
-- de clientes y productos sin movimientos para validar correctamente los casos 
-- de LEFT JOIN y UNION ALL.
-- =============================================================================

-- Consulta 1 — Vista base del proyecto (INNER JOIN)
SELECT 
    -- 1. Datos de la Transacción
	v.id_venta,
    v.fecha_venta,


    -- 2. Dimensión Cliente
    c.nombre AS nombre_cliente,
    ci.nombre AS ciudad_cliente,
    s.nombre AS segmento_cliente,

    -- 3. Dimensión Producto
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria,
    sub.nombre_subcategoria,

    -- 4. Dimensión Geográfica / Territorial
    t.nombre_territorio,
    r.nombre_region,
    z.nombre_zona,

    -- 5. Métricas
    v.cantidad,
    p.precio AS precio_unitario,
    (v.cantidad * p.precio) AS total_venta

FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN ciudades AS ci
    ON c.id_ciudad = ci.id_ciudad
INNER JOIN segmentos AS s
    ON c.id_segmento = s.id_segmento
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
INNER JOIN subcategorias AS sub
    ON p.id_subcategoria = sub.id_subcategoria
INNER JOIN territorios AS t
    ON v.id_territorio = t.id_territorio
INNER JOIN regiones AS r
    ON t.id_region = r.id_region
INNER JOIN zonas AS z
    ON t.id_zona = z.id_zona
ORDER BY v.fecha_venta DESC;

-- Consulta 2 — Clientes sin ventas registradas (LEFT JOIN)

SELECT 
    -- 1. Dimensión Cliente
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email AS email_cliente,
    c.fecha_registro,

    -- 2. Clasificación y Geografía
    s.nombre AS segmento_cliente,
    ci.nombre AS ciudad_cliente

FROM clientes AS c
-- Relaciones obligatorias del cliente (INNER JOIN)
INNER JOIN segmentos AS s
    ON c.id_segmento = s.id_segmento
INNER JOIN ciudades AS ci
    ON c.id_ciudad = ci.id_ciudad

-- Unión externa para detectar registros huérfanos (LEFT JOIN)
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente

-- Filtro: conservar únicamente clientes que no tienen transacciones asociadas
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro DESC, c.nombre ASC;

-- Consulta 3 — Productos sin ventas registradas (LEFT JOIN)

SELECT 
    -- 1. Dimensión Producto
    p.id_producto,
    p.nombre_producto,
    p.precio,
    p.stock,

    -- 2. Clasificación de Producto
    cat.nombre_categoria,
    sub.nombre_subcategoria

FROM productos AS p
-- Relaciones obligatorias del catálogo (INNER JOIN)
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
INNER JOIN subcategorias AS sub
    ON p.id_subcategoria = sub.id_subcategoria

-- Unión externa para detectar productos sin venta (LEFT JOIN)
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto

-- Filtro: conservar únicamente productos que no registran transacciones
WHERE v.id_venta IS NULL
ORDER BY p.id_producto ASC;

-- Consulta 4 — Consolidación de ventas por canal y zona geográfica

SELECT 
    consolidado.canal,
    COUNT(consolidado.id_venta) AS numero_ventas,
    SUM(consolidado.cantidad_vendida) AS total_unidades_vendidas
FROM (
    -- 1. Ventas registradas en Zona Sur (Canal Online)
    SELECT 
        v.id_venta,
        v.fecha_venta,
        v.cantidad AS cantidad_vendida,
        c.nombre AS nombre_cliente,
        p.nombre_producto,
        t.nombre_territorio,
        z.nombre_zona,
        'Online' AS canal
    FROM ventas AS v 
    INNER JOIN clientes AS c
        ON v.id_cliente = c.id_cliente
    INNER JOIN productos AS p
        ON v.id_producto = p.id_producto
    INNER JOIN territorios AS t
        ON v.id_territorio = t.id_territorio
    INNER JOIN zonas AS z
        ON t.id_zona = z.id_zona
    WHERE z.nombre_zona = 'Sur'

    UNION ALL

    -- 2. Ventas registradas en Zona Centro (Canal Presencial)
    SELECT 
        v.id_venta,
        v.fecha_venta,
        v.cantidad AS cantidad_vendida,
        c.nombre AS nombre_cliente,
        p.nombre_producto,
        t.nombre_territorio,
        z.nombre_zona,
        'Presencial' AS canal
    FROM ventas AS v 
    INNER JOIN clientes AS c
        ON v.id_cliente = c.id_cliente
    INNER JOIN productos AS p
        ON v.id_producto = p.id_producto
    INNER JOIN territorios AS t
        ON v.id_territorio = t.id_territorio
    INNER JOIN zonas AS z
        ON t.id_zona = z.id_zona
    WHERE z.nombre_zona = 'Centro'
) AS consolidado

-- Agrupación final por origen/canal
GROUP BY consolidado.canal
ORDER BY total_unidades_vendidas DESC;
