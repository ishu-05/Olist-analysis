-------------------------------------------------------------------------------------------------------------------------------------------------
--Q1: Does a late first delivery reduce the likelihood of a customer returning for a second order?
-------------------------------------------------------------------------------------------------------------------------------------------------

WITH numbered_orders AS (
    SELECT
        c.customer_unique_id,
        od.order_id,
        od.order_purchase_timestamp,
        od.order_delivered_customer_date,
        od.order_estimated_delivery_date,
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY od.order_purchase_timestamp) AS order_sequence
    FROM customers AS c
    JOIN orders_delivered AS od ON od.customer_id = c.customer_id
),
customer_summary AS (
	SELECT
		customer_unique_id,
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date,
		order_sequence,
		MAX(order_sequence) OVER (PARTITION BY customer_unique_id) AS max_order_sequence
	FROM numbered_orders
),
first_order_status AS (
SELECT 
    cs.order_purchase_timestamp,
	cs.customer_unique_id,
    cs.order_id,
	order_sequence,
	cs.max_order_sequence,
	CASE 
		WHEN 
			(cs.order_delivered_customer_date::DATE - cs.order_estimated_delivery_date::DATE) <=0
		THEN 'early or on-time'
		WHEN 
			(cs.order_delivered_customer_date::DATE - cs.order_estimated_delivery_date::DATE) BETWEEN 1 AND 3
		THEN 'a bit late'
		WHEN
			(cs.order_delivered_customer_date::DATE - cs.order_estimated_delivery_date::DATE) BETWEEN 4 AND 7
		THEN 'moderately late'
		ELSE
		'very late'
	END AS delivery_status
FROM customer_summary AS cs 
WHERE order_sequence = 1
)

SELECT
	delivery_status,
	COUNT(*) AS total_customers,
	COUNT(CASE WHEN max_order_sequence >1 THEN 1 END) AS returned_customers,
	ROUND(COUNT(CASE WHEN max_order_sequence >1 THEN 1 END)::NUMERIC / COUNT(*) * 100,2) AS return_rate_percent
FROM first_order_status AS fo
GROUP BY delivery_status
ORDER BY return_rate_percent DESC;