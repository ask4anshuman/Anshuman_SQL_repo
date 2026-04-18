-- Sample SQL demonstrating:
-- 1) Multiple CTE transformations
-- 2) Window functions
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2654263
-- 3) LEFT joins and anti-churn logic
-- 4) Final business classification output

WITH eligible_customers AS (
    SELECT
        c.customer_id,
        c.signup_date,
        c.country_code,
        c.marketing_opt_in
    FROM crm.customers AS c
    WHERE c.is_active = 1
      AND c.signup_date < DATE '2026-10-01'
),
order_history AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date DESC
        ) AS recency_rank
    FROM sales.orders AS o
    WHERE o.status_code IN ('S', 'D')
),
latest_order AS (
    SELECT
        oh.customer_id,
        oh.order_date AS latest_order_date,
        oh.total_amount AS latest_order_amount
    FROM order_history AS oh
    WHERE oh.recency_rank = 1
),
order_stats AS (
    SELECT
        o.customer_id,
        COUNT(*) AS completed_order_count,
        SUM(o.total_amount) AS lifetime_value,
        MAX(o.order_date) AS most_recent_completed_order
    FROM sales.orders AS o
    WHERE o.status_code IN ('S', 'D')
    GROUP BY o.customer_id
)
SELECT
    ec.customer_id,
    ec.signup_date,
    ec.country_code,
    os.completed_order_count,
    os.lifetime_value,
    lo.latest_order_date,
    lo.latest_order_amount,
    CASE
        WHEN os.most_recent_completed_order >= DATE '2026-09-01' THEN 'Active'
        WHEN os.most_recent_completed_order >= DATE '2026-06-01' THEN 'At Risk'
        ELSE 'Churned'
    END AS retention_status,
    CASE
        WHEN ec.marketing_opt_in = 1 THEN 'Eligible for campaign'
        ELSE 'Do not contact'
    END AS marketing_action
FROM eligible_customers AS ec
LEFT JOIN order_stats AS os
    ON ec.customer_id = os.customer_id
LEFT JOIN latest_order AS lo
    ON ec.customer_id = lo.customer_id
WHERE COALESCE(os.completed_order_count, 0) >= 5
  AND ec.country_code IN ('US')
ORDER BY
    retention_status,
    os.lifetime_value DESC,
    ec.customer_id;
