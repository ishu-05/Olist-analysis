-------------------------------------------------------------------------------------------------------------------------------------------------
--Q1: What share of orders and revenue is concentrated in the "high delay" tier , monthly?
------------------------------------------------------------------------------------------------------------------------------------------------.
WITH monthly_revenue AS(
	SELECT
		od.order_id,
		order_totals.sum_of_orders
	FROM orders_delivered AS od
	JOIN
	(
		SELECT                                                                                                                                                          
		oi.order_id,
		ROUND(SUM(oi.price+oi.freight_value)::NUMERIC,2) AS sum_of_orders
		FROM order_items AS oi
		GROUP BY oi.order_id
	) as order_totals
	ON od.order_id = order_totals.order_id
)
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month_no,
    COUNT(DISTINCT mr.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN (od.order_delivered_customer_date::date -
              od.order_estimated_delivery_date::date) > 7
        THEN od.order_id
    END) AS high_delay_orders,
	SUM(mr.sum_of_orders) AS total_revenue,
	SUM(CASE WHEN (od.order_delivered_customer_date::date -
    od.order_estimated_delivery_date::date) > 7 THEN mr.sum_of_orders END) AS high_delay_revenue,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN (od.order_delivered_customer_date::date -
                  od.order_estimated_delivery_date::date) > 7
            THEN od.order_id
        END) * 100.0
        / COUNT(DISTINCT od.order_id),
        2
    ) AS order_share,
	ROUND(
        SUM (CASE
            WHEN (od.order_delivered_customer_date::date -
                  od.order_estimated_delivery_date::date) > 7
            THEN mr.sum_of_orders
        END) * 100.0
        / SUM( mr.sum_of_orders),
        2
    ) AS revenue_share
	
FROM orders_delivered AS od
JOIN
monthly_revenue AS mr
ON
od.order_id = mr.order_id
GROUP BY DATE_TRUNC('month', od.order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', od.order_purchase_timestamp); 







-------------------------------------------------------------------------------------------------------------------------------------------------
--Q2: What is the estimated annual revenue exposure attributable to delay-driven customer loss?
-------------------------------------------------------------------------------------------------------------------------------------------------
WITH numbered_orders AS(
	SELECT
	c.customer_unique_id,
	od.order_id,
	od.order_purchase_timestamp,
	od.order_delivered_customer_date,
	od.order_estimated_delivery_date,
	ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY od.order_purchase_timestamp) AS order_sequence
FROM customers AS c
JOIN
orders_delivered AS od
ON
c.customer_id = od.customer_id
),

second_order_status AS (
	SELECT
		no.order_id,
		no.customer_unique_id,
		no.order_delivered_customer_date,
		no.order_estimated_delivery_date,
		no.order_sequence
FROM numbered_orders AS no
WHERE order_sequence=2
)

SELECT 
	COUNT(*) AS total_customers,
	ROUND(SUM(sum_of_order):: NUMERIC,2) AS total_revenue,
	ROUND(AVG(sum_of_order):: NUMERIC,2) AS avg_revenue
FROM second_order_status AS so
JOIN
(
SELECT 
	oi.order_id, 
	ROUND(SUM(oi.price + oi.freight_value)::NUMERIC,2) AS sum_of_order
FROM order_items AS oi
GROUP BY oi.order_id 
) AS order_totals
ON so.order_id = order_totals.order_id
;