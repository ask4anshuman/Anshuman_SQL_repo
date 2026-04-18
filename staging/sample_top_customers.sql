-- Sample: Top 5 customers by total order value in last 30 days
SELECT
    c.customer_id,
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2588816
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '300 days'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;
