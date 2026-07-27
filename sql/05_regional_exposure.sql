---------------------------------------------------------------------------------------------------------------------------------------------------------
--Q1: Do specific states show structurally worse delivery performance, and does that correlate with higher freight cost as a percentage of order value?
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	COUNT (*) AS total_orders,
	seller_state,
	ROUND(AVG(od.order_delivered_customer_date :: DATE - od.order_estimated_delivery_date :: DATE) :: NUMERIC,2) AS avg_delay ,
	ROUND(COUNT(DISTINCT CASE WHEN(od.order_delivered_customer_date :: DATE - 
		 od.order_estimated_delivery_date :: DATE) > 7 
		 THEN  od.order_id END ) * 100.0 / COUNT (DISTINCT od.order_id),2) AS high_delay_orders_percent,
	ROUND(SUM(oi.price + oi.freight_value) :: NUMERIC,2) AS total_revenue,
	ROUND(SUM(CASE WHEN (od.order_delivered_customer_date :: DATE - 
		 od.order_estimated_delivery_date :: DATE) > 7 THEN (oi.price + oi.freight_value) END)::NUMERIC,2) AS revenue_for_high_delay_orders,
	ROUND(AVG(oi.freight_value / (oi.price + oi.freight_value) * 100)::NUMERIC, 2) AS avg_freight_pct
FROM order_items as oi
JOIN
orders_delivered AS od
ON
oi.order_id = od.order_id
JOIN
sellers AS s
ON
oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY ROUND(SUM(oi.price + oi.freight_value) :: NUMERIC,2) NULLS LAST
;


------------------------------------------------------------------------------------------------------------------------------------------------
--Q2: Which individual sellers contribute a disproportionate share of high-delay orders relative to their order volume?
------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	s.seller_id,
	COUNT (*) AS total_orders,
	COUNT(seller_state) AS state_count,
	ROUND(AVG(od.order_delivered_customer_date :: DATE - od.order_estimated_delivery_date :: DATE) :: NUMERIC,2) AS avg_delay ,
	ROUND(COUNT(DISTINCT CASE WHEN(od.order_delivered_customer_date :: DATE - 
		 od.order_estimated_delivery_date :: DATE) > 7 
		 THEN  od.order_id END ) * 100.0 / COUNT (DISTINCT od.order_id),2) AS high_delay_orders_percent,
	ROUND(SUM(oi.price + oi.freight_value) :: NUMERIC,2) AS total_revenue,
	ROUND(SUM(CASE WHEN (od.order_delivered_customer_date :: DATE - 
		 od.order_estimated_delivery_date :: DATE) > 7 THEN (oi.price + oi.freight_value) END)::NUMERIC,2) AS revenue_for_high_delay_orders,
	ROUND(AVG(oi.freight_value / (oi.price + oi.freight_value) * 100)::NUMERIC, 2) AS avg_freight_pct
FROM order_items as oi
JOIN
orders_delivered AS od
ON
oi.order_id = od.order_id
JOIN
sellers AS s
ON
oi.seller_id = s.seller_id
GROUP BY s.seller_id
HAVING COUNT(*) >= 20
ORDER BY high_delay_orders_percent DESC
;