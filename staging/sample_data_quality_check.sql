-- Sample: Data quality check - Duplicate orders in staging
-- Purpose: Identify potential duplicate orders before loading to production
SELECT
    order_id,
    customer_id,
    order_date,
    COUNT(*) AS occurrence_count,
    MAX(created_at) AS last_seen
FROM staging.raw_orders
GROUP BY order_id, customer_id, order_date
HAVING COUNT(*) > 10
ORDER BY occurrence_count DESC, order_date DESC;
