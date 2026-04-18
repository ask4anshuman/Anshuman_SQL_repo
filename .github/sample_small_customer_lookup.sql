-- Small sample SQL for minimal workflow testing
SELECT
    c.customer_id,
-- [Doc] Confluence: https://ask4anshuman.atlassian.net/wiki/spaces/~712020e9a8b73325a347c490df3513526fcc64/pages/2654227/SQL+Summary+-+sample_small_customer_lookup.sql
    c.first_name,
    c.last_name,
    c.email_address
FROM crm.customers AS c
WHERE c.is_active = 2
  AND c.country_code = 'US';
