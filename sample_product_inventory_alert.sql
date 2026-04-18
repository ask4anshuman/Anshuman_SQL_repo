-- Sample SQL demonstrating:
-- 1) Inventory threshold analysis
-- 2) Multiple joins across inventory and supplier tables
-- 3) CASE-based alert classification
-- 4) Aggregated restock recommendation output

WITH current_inventory AS (
    SELECT
        i.product_id,
        i.warehouse_id,
        i.on_hand_quantity,
        i.reserved_quantity,
        (i.on_hand_quantity - i.reserved_quantity) AS available_quantity,
        i.reorder_point,
        i.max_stock_level
    FROM inventory.stock_balances AS i
    WHERE i.is_active = 1
),
recent_demand AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS last_30_day_demand
    FROM sales.order_items AS oi
    INNER JOIN sales.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 day'
      AND o.status_code IN ('S', 'D')
    GROUP BY oi.product_id
),
primary_supplier AS (
    SELECT
        s.product_id,
        s.supplier_id,
        s.lead_time_days,
        s.unit_cost,
        ROW_NUMBER() OVER (
            PARTITION BY s.product_id
            ORDER BY s.is_primary DESC, s.updated_at DESC
        ) AS supplier_rank
    FROM procurement.product_suppliers AS s
    WHERE s.is_active = 1
)
SELECT
    p.product_id,
    p.product_name,
    w.warehouse_name,
    ci.available_quantity,
    ci.reorder_point,
    ci.max_stock_level,
    COALESCE(rd.last_30_day_demand, 0) AS last_30_day_demand,
    sup.supplier_id,
    sup.lead_time_days,
    sup.unit_cost,
    CASE
        WHEN ci.available_quantity <= 0 THEN 'Critical'
        WHEN ci.available_quantity < ci.reorder_point THEN 'Reorder Required'
        WHEN ci.available_quantity < (ci.reorder_point * 1.25) THEN 'Monitor'
        ELSE 'Healthy'
    END AS inventory_alert_status,
    CASE
        WHEN ci.available_quantity < ci.reorder_point
            THEN GREATEST(ci.max_stock_level - ci.available_quantity, 0)
        ELSE 0
    END AS recommended_restock_qty
FROM current_inventory AS ci
INNER JOIN inventory.products AS p
    ON ci.product_id = p.product_id
INNER JOIN inventory.warehouses AS w
    ON ci.warehouse_id = w.warehouse_id
LEFT JOIN recent_demand AS rd
    ON ci.product_id = rd.product_id
LEFT JOIN primary_supplier AS sup
    ON ci.product_id = sup.product_id
   AND sup.supplier_rank = 1
WHERE p.is_discontinued = 0
  AND w.region_code IN ('EAST', 'CENTRAL', 'SOUTH')
  AND (
      ci.available_quantity < ci.reorder_point
      OR COALESCE(rd.last_30_day_demand, 0) > 100
  )
ORDER BY
    inventory_alert_status,
    recommended_restock_qty DESC,
    p.product_name;
