-- queries/funnel.sql : Example funnel from synthetic 'status' (created->paid)
-- In a production system you would model events; here we proxy with order status.
WITH stages AS (
  SELECT strftime('%Y-%W', order_date) AS week,
         SUM(CASE WHEN status IN ('created','paid','cancelled','refunded') THEN 1 ELSE 0 END) AS created,
         SUM(CASE WHEN status='paid' THEN 1 ELSE 0 END) AS paid
  FROM orders
  GROUP BY 1
)
SELECT week, created, paid,
       ROUND(100.0 * paid/NULLIF(created,0),2) AS pay_conv_pct
FROM stages
ORDER BY week;
