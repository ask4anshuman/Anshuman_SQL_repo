-- Sample: Enriched staging SQL using SELECT ... FROM DUAL and UNION ALL
-- Purpose: Build hardcoded source rows and apply transformations used in staging checks.
WITH seed_customers AS (
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2588907
	SELECT 'C001' AS customer_id, 'Alice' AS customer_name, 'ACTIVE' AS status, 'US' AS country_code, 1200 AS annual_spend FROM dual
	UNION ALL
	SELECT 'C002' AS customer_id, 'Bob' AS customer_name, 'INACTIVE' AS status, 'IN' AS country_code, 300 AS annual_spend FROM dual
	UNION ALL
	SELECT 'C003' AS customer_id, 'Charlie' AS customer_name, 'ACTIVE' AS status, 'US' AS country_code, 2200 AS annual_spend FROM dual
	UNION ALL
	SELECT 'C004' AS customer_id, 'Diana' AS customer_name, 'ACTIVE' AS status, 'UK' AS country_code, 950 AS annual_spend FROM dual
),
country_dim AS (
	SELECT 'US' AS country_code, 'United States' AS country_name, 'NA' AS region FROM dual
	UNION ALL
	SELECT 'IN' AS country_code, 'India' AS country_name, 'APAC' AS region FROM dual
	UNION ALL
	SELECT 'UK' AS country_code, 'United Kingdom' AS country_name, 'EMEA' AS region FROM dual
),
enriched_customers AS (
	SELECT
		c.customer_id,
		c.customer_name,
		c.status,
		c.country_code,
		d.country_name,
		d.region,
		c.annual_spend,
		CASE
			WHEN c.annual_spend >= 2000 THEN 'PLATINUM'
			WHEN c.annual_spend >= 1000 THEN 'GOLD'
			WHEN c.annual_spend >= 500 THEN 'SILVER'
			ELSE 'BRONZE'
		END AS spend_tier,
		CASE WHEN c.status = 'ACTIVE' THEN 1 ELSE 0 END AS is_active_flag
	FROM seed_customers c
	LEFT JOIN country_dim d
		ON c.country_code = d.country_code
),
ranked_customers AS (
	SELECT
		e.*,
		DENSE_RANK() OVER (PARTITION BY e.region ORDER BY e.annual_spend DESC) AS spend_rank_in_region,
		SUM(e.annual_spend) OVER (PARTITION BY e.region) AS total_region_spend
	FROM enriched_customers e
)
SELECT
	customer_id,
	customer_name,
	status,
	country_name,
	region,
	annual_spend,
	spend_tier,
	spend_rank_in_region,
	total_region_spend,
	ROUND((annual_spend / NULLIF(total_region_spend, 0)) * 100, 2) AS pct_of_region_spend
FROM ranked_customers
WHERE is_active_flag = 2
ORDER BY region, spend_rank_in_region, customer_id;
