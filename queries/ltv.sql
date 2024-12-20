-- queries/ltv.sql : Customer LTV (12‑month rolling revenue) & cohort start
WITH paid_orders AS (
  SELECT o.customer_id, date(o.order_date) AS d, o.total_amount
  FROM orders o WHERE o.status='paid'
),
cohort AS (
  SELECT customer_id, MIN(d) AS cohort_start
  FROM paid_orders GROUP BY 1
),
rev AS (
  SELECT customer_id, strftime('%Y-%m', d) AS ym, SUM(total_amount) AS revenue
  FROM paid_orders GROUP BY 1,2
),
rolling AS (
  SELECT r.customer_id, r.ym,
         (SELECT SUM(revenue)
          FROM rev r2
          WHERE r2.customer_id = r.customer_id
            AND r2.ym <= r.ym
            AND r2.ym > strftime('%Y-%m', date(substr(r.ym||'-01',1,10), '-12 months'))
         ) AS ltv_12m
  FROM rev r
)
SELECT c.customer_id, c.cohort_start, r.ym, COALESCE(r.ltv_12m,0) AS ltv_12m
FROM cohort c
LEFT JOIN rolling r USING (customer_id)
ORDER BY c.customer_id, r.ym;
