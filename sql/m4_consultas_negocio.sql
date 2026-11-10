-- Consulta 1 — Resumen ejecutivo mensual
SELECT 
    EXTRACT(MONTH FROM v.fecha_venta) AS mes,
    SUM(v.cantidad * p.precio) AS total_facturado,
    COUNT(v.id_venta) AS cantidad_pedidos,
    ROUND(AVG(v.cantidad * p.precio), 2) AS ticket_promedio
FROM ventas AS v
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
GROUP BY EXTRACT(MONTH FROM v.fecha_venta)
ORDER BY mes;


-- Consulta 2 — Ranking de productos
SELECT 
    p.id_producto,
    p.nombre_producto,
    SUM(v.cantidad * p.precio) AS total_generado, 
    SUM(v.cantidad) AS unidades_vendidas 
FROM ventas AS v
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre_producto
ORDER BY total_generado DESC 
LIMIT 5;

-- Consulta 3 — Clientes recurrentes
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    COUNT(v.id_venta) AS cantidad_pedidos,
    SUM(v.cantidad * p.precio) AS total_gastado
FROM ventas AS v
INNER JOIN clientes AS c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
GROUP BY 
    c.id_cliente, 
    c.nombre
HAVING 
    COUNT(v.id_venta) > 1
ORDER BY 
    total_gastado DESC;

-- Consulta 4 — Meses por encima/por debajo del promedio
WITH ventas_mensuales AS (
    SELECT 
        EXTRACT(YEAR FROM v.fecha_venta)::INT AS anio,
        EXTRACT(MONTH FROM v.fecha_venta)::INT AS mes,
        TO_CHAR(v.fecha_venta, 'TMMonth YYYY') AS periodo,
        SUM(v.cantidad * p.precio) AS total_facturado
    FROM ventas AS v
    INNER JOIN productos AS p 
        ON v.id_producto = p.id_producto
    GROUP BY 
        EXTRACT(YEAR FROM v.fecha_venta),
        EXTRACT(MONTH FROM v.fecha_venta),
        TO_CHAR(v.fecha_venta, 'TMMonth YYYY')
)
SELECT 
    anio,
    mes,
    periodo,
    total_facturado,
    CASE 
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por debajo'
        ELSE 'Igual'
    END AS comparacion_promedio
FROM ventas_mensuales
ORDER BY 
    anio, 
    mes;
-- ==========================================
-- BLOQUE DE CIERRE: HALLAZGOS DE NEGOCIO
-- ==========================================
-- 1. Concentración de ventas: Los productos con id 1 y 3 representan el 76% de las ventas del mes 3.
-- 2. Clientes que gastaron más: Los clientes con id 1 y 5 son los clientes frecuentes que generaron el 73% de los ingresos brutos del mes 3.
-- 3. Promedio mensual: La facturación del mes 3 no incrementó ni disminuyó con respecto al promedio mensual.Los resultados del mes 3 sirven como punto de partida o línea base (baseline). Se recomienda integrar los datos de los meses siguientes para monitorear variaciones y detectar patrones temporales de demanda.
