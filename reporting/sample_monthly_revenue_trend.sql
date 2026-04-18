-- Sample: Monthly revenue trend analysis
-- Purpose: Track revenue trends across months with YoY comparison
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month_num,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(order_amount) AS total_revenue,
    AVG(order_amount) AS avg_order_value,
    SUM(order_amount) / COUNT(DISTINCT customer_id) AS revenue_per_customer
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '24 months'
GROUP BY DATE_TRUNC('month', order_date), year, month_num
ORDER BY year DESC, month_num DESC;
