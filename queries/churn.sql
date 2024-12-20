-- queries/churn.sql : Churn/retention with 90‑day inactivity threshold
WITH paid AS (
  SELECT customer_id, date(order_date) AS d
  FROM orders WHERE status='paid'
),
activity AS (
  SELECT customer_id, d, 
         CASE WHEN julianday(LEAD(d) OVER (PARTITION BY customer_id ORDER BY d)) - julianday(d) > 90
              THEN 1 ELSE 0 END AS churn_event
  FROM paid
)
SELECT customer_id,
       SUM(churn_event) AS churn_events,
       CASE WHEN MAX(julianday('now') - julianday(MAX(d))) > 90 THEN 1 ELSE 0 END AS currently_churned
FROM activity
GROUP BY 1
ORDER BY 1;
