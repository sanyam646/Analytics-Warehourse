-- queries/seller_efficiency.sql : GMV, fill rate, on‑time %, unit economics
WITH paid_items AS (
  SELECT oi.seller_id, oi.qty, (oi.price - oi.discount) AS net_price, oi.order_id
  FROM order_items oi
  JOIN orders o ON o.order_id=oi.order_id
  WHERE o.status='paid'
),
gmv AS (
  SELECT seller_id, SUM(qty*net_price) AS gmv
  FROM paid_items GROUP BY 1
),
orders_seller AS (
  SELECT oi.seller_id,
         COUNT(DISTINCT oi.order_id) AS orders_total,
         SUM(CASE WHEN o.status='paid' THEN 1 ELSE 0 END) AS orders_filled
  FROM order_items oi JOIN orders o USING(order_id)
  GROUP BY 1
),
otd AS (
  SELECT oi.seller_id,
         AVG(CASE WHEN julianday(d.delivered_at) - julianday(d.shipped_at) <= 3 THEN 1.0 ELSE 0.0 END) AS on_time_pct,
         SUM(d.logistics_cost) AS logistics_cost
  FROM order_items oi
  JOIN deliveries d USING(order_id)
  GROUP BY 1
)
SELECT g.seller_id, g.gmv,
       o.orders_filled, o.orders_total,
       ROUND(100.0*o.orders_filled/NULLIF(o.orders_total,0),2) AS fill_rate_pct,
       ROUND(100.0*otd.on_time_pct,2) AS on_time_pct,
       otd.logistics_cost
FROM gmv g
JOIN orders_seller o USING(seller_id)
LEFT JOIN otd USING(seller_id)
ORDER BY gmv DESC;
