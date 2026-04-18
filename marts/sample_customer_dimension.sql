-- Sample: Customer dimension mart
-- Purpose: Denormalized customer master data for reporting
SELECT
    customer_id,
    customer_name,
    email,
    country,
    state,
    CASE WHEN last_order_date >= CURRENT_DATE - INTERVAL '90 days' THEN 'Active'
         WHEN last_order_date >= CURRENT_DATE - INTERVAL '365 days' THEN 'Inactive'
         ELSE 'Dormant' END AS customer_status,
    total_lifetime_orders,
    total_lifetime_spend,
    avg_order_value,
    CURRENT_TIMESTAMP AS last_updated
FROM mart_customers
ORDER BY total_lifetime_spend DESC;
