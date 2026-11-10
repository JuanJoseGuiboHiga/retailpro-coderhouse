-- Consulta 1 — Resumen ejecutivo mensual
SELECT 
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;

-- Consulta 2 — Ranking de productos
SELECT 
    id_producto, 
    SUM(cantidad * precio_unitario) AS total_generado, 
    SUM(cantidad) AS unidades_vendidas 
FROM ventas 
GROUP BY id_producto 
ORDER BY total_generado DESC 
LIMIT 5;

-- Consulta 3 — Clientes recurrentes
SELECT 
    id_cliente, 
    COUNT(*) AS cantidad_pedidos, 
    SUM(cantidad * precio_unitario) AS total_gastado 
FROM ventas  
GROUP BY id_cliente 
HAVING COUNT(*) > 1 
ORDER BY total_gastado DESC;

-- Consulta 4 — Meses por encima/por debajo del promedio
WITH ventas_mensuales AS (
    SELECT 
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por debajo'
        ELSE 'Igual'
    END AS promedio_mensual
FROM ventas_mensuales
ORDER BY mes;

-- ==========================================
-- BLOQUE DE CIERRE: HALLAZGOS DE NEGOCIO
-- ==========================================
-- 1. Concentración de ventas: Los productos con id 1 y 3 representan el 76% de las ventas del mes 3.
-- 2. Clientes que gastaron más: Los clientes con id 1 y 5 son los clientes frecuentes que generaron el 73% de los ingresos brutos del mes 3.
-- 3. Promedio mensual: La facturación del mes 3 no incrementó ni disminuyó con respecto al promedio mensual.Los resultados del mes 3 sirven como punto de partida o línea base (baseline). Se recomienda integrar los datos de los meses siguientes para monitorear variaciones y detectar patrones temporales de demanda.
