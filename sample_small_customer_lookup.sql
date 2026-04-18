-- Small sample SQL for minimal workflow testing
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email_address
FROM crm.customers AS c
WHERE c.is_active = 1
  AND c.country_code = 'US';
