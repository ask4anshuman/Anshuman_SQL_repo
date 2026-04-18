-- Sample: Data quality check - Duplicate orders in staging
-- Purpose: Identify potential duplicate orders before loading to production
SELECT
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2588838
    order_id,
    customer_id,
    order_date,
    COUNT(*) AS occurrence_count,
    MAX(created_at) AS last_seen
FROM staging.raw_orders
GROUP BY order_id, customer_id, order_date
HAVING COUNT(*) > 10
ORDER BY occurrence_count DESC, order_date DESC;
