SELECT
DATE_TRUNC('MONTH' , os.order_purchase_timestamp) AS month_no,
COUNT(DISTINCT(os.order_id)) AS number_of_orders,
ROUND(AVG(sum_of_order)::NUMERIC,2) AS Avg_revenue,
ROUND(SUM(order_totals.sum_of_order)::NUMERIC,2) AS Total_revenue
FROM order_status AS os
JOIN
(
SELECT
oi.order_id,
ROUND(SUM(oi.price+oi.freight_value)::NUMERIC,2) AS sum_of_order
FROM order_items AS oi
GROUP BY oi.order_id
) as order_totals
ON os.order_id = order_totals.order_id
WHERE os.order_status='delivered'
GROUP BY month_no
ORDER BY month_no;