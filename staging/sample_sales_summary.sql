-- Sample SQL demonstrating:
-- 1) Aggregation and grouping
-- 2) Join logic across dimensions
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2654279
-- 3) HAVING filters
-- 4) Derived business metrics

WITH monthly_sales AS (
    SELECT
        o.store_id,
        o.customer_id,
        DATE_TRUNC('month', o.order_date) AS sales_month,
        o.order_id,
        o.total_amount
    FROM sales.orders AS o
    WHERE o.order_date >= DATE '2026-01-01'
      AND o.order_date < DATE '2027-01-01'
      AND o.status_code IN ('S', 'D')
),
customer_segments AS (
    SELECT
        c.customer_id,
        c.segment_code,
        CASE c.segment_code
            WHEN 'ENT' THEN 'Enterprise'
            WHEN 'SMB' THEN 'Small Business'
            WHEN 'RET' THEN 'Retail'
            ELSE 'Other'
        END AS segment_name
    FROM crm.customers AS c
    WHERE c.is_active = 1
)
SELECT
    s.store_name,
    ms.sales_month,
    cs.segment_name,
    COUNT(DISTINCT ms.order_id) AS total_orders,
    COUNT(DISTINCT ms.customer_id) AS unique_customers,
    SUM(ms.total_amount) AS gross_revenue,
    ROUND(SUM(ms.total_amount) / NULLIF(COUNT(DISTINCT ms.order_id), 0), 2) AS avg_order_value
FROM monthly_sales AS ms
INNER JOIN retail.stores AS s
    ON ms.store_id = s.store_id
LEFT JOIN customer_segments AS cs
    ON ms.customer_id = cs.customer_id
WHERE s.region_code IN ('NORTH', 'WEST')
GROUP BY
    s.store_name,
    ms.sales_month,
    cs.segment_name
HAVING SUM(ms.total_amount) >= 600000
ORDER BY
    ms.sales_month,
    s.store_name,
    cs.segment_name;
