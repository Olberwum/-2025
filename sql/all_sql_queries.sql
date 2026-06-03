/*
                           E‑COMMERCE SALES ANALYTICS 2025                      
                       Аналитические SQL-запросы для дашборда                    
*/

-- =============================================================================
-- Запрос 1. Общие KPI (ключевые показатели эффективности)
-- =============================================================================

SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_order_value,
    ROUND(AVG(customer_rating), 2) AS avg_rating,
    ROUND(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_percent
FROM ecommerce_sales_cleaned;


-- =============================================================================
-- Запрос 2. Выручка по категориям товаров
-- =============================================================================

SELECT 
    product_category,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS orders_count,
    ROUND(AVG(customer_rating), 2) AS avg_rating,
    ROUND(AVG(discount_percent), 1) AS avg_discount_percent
FROM ecommerce_sales_cleaned
GROUP BY product_category
ORDER BY total_revenue DESC;


-- =============================================================================
-- Запрос 3. Динамика по месяцам
-- =============================================================================

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(revenue) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS orders_count,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
    ROUND(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_percent
FROM ecommerce_sales_cleaned
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- =============================================================================
-- Запрос 4. Возвраты по регионам и категориям
-- =============================================================================

SELECT 
    region,
    product_category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returns_count,
    ROUND(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_percent
FROM ecommerce_sales_cleaned
GROUP BY region, product_category
HAVING COUNT(*) > 50  -- Исключаем комбинации с малым количеством заказов
ORDER BY return_rate_percent DESC;


-- =============================================================================
-- Запрос 5. Связь скидки и возвратов
-- =============================================================================

SELECT 
    CASE 
        WHEN discount_percent = 0 THEN '0%'
        WHEN discount_percent BETWEEN 1 AND 10 THEN '1-10%'
        WHEN discount_percent BETWEEN 11 AND 20 THEN '11-20%'
        ELSE '20%+'
    END AS discount_group,
    COUNT(*) AS orders_count,
    ROUND(AVG(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) * 100, 2) AS return_rate_percent,
    ROUND(AVG(customer_rating), 2) AS avg_rating,
    ROUND(AVG(revenue), 2) AS avg_order_value
FROM ecommerce_sales_cleaned
GROUP BY discount_group
ORDER BY discount_group;


-- =============================================================================
-- Запрос 6. Net revenue (выручка с учётом возвратов)
-- =============================================================================

SELECT 
    product_category,
    ROUND(SUM(revenue), 2) AS gross_revenue,
    ROUND(SUM(CASE WHEN is_returned = 1 THEN revenue ELSE 0 END), 2) AS returned_revenue,
    ROUND(SUM(CASE WHEN is_returned = 0 THEN revenue ELSE 0 END), 2) AS net_revenue,
    ROUND(SUM(CASE WHEN is_returned = 0 THEN revenue ELSE 0 END) * 100.0 / SUM(revenue), 1) AS net_revenue_percent
FROM ecommerce_sales_cleaned
GROUP BY product_category
ORDER BY net_revenue DESC;


-- =============================================================================
-- Дополнительный запрос. Топ-5 регионов по выручке
-- =============================================================================

SELECT 
    region,
    ROUND(SUM(revenue), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS orders_count,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM ecommerce_sales_cleaned
GROUP BY region
ORDER BY total_revenue DESC
LIMIT 5;
