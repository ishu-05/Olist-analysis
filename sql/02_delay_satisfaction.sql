-------------------------------------------------------------------------------------------------------------------------------------------------
--Q1: does the delay–satisfaction relationship hold consistently across categories, or are some categories more sensitive to delay than others?
-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    CASE
        WHEN (order_delivered_customer_date::date - order_estimated_delivery_date::date) <= 0
            THEN 'On-time or Early'
        WHEN (order_delivered_customer_date::date - order_estimated_delivery_date::date) BETWEEN 1 AND 3
            THEN 'A bit Late'
        WHEN (order_delivered_customer_date::date - order_estimated_delivery_date::date) BETWEEN 4 AND 7
            THEN 'Moderately Late'
        ELSE 'Very Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_review_score
FROM orders_delivered AS od
JOIN order_reviews AS r ON od.order_id = r.order_id
GROUP BY delivery_status
ORDER BY avg_review_score;


-------------------------------------------------------------------------------------------------------------------------------------------------
--Q2:  Is customer tolerance for delay uniform across product categories, or do some categories punish lateness more severely than others?
-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	p.product_category_name,
	ct.product_category_name_english,
	COUNT(*) AS total_orders,
	COUNT(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) > 7 THEN 1 END) AS late_order_count,
	ROUND(AVG(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) <= 0 THEN review_score END)::NUMERIC,2) AS ontime_avg,
	ROUND(AVG(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) > 7 THEN review_score END)::NUMERIC,2) AS late_avg,
	ROUND(AVG(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) <= 0 THEN review_score END)::NUMERIC,2) - 
	ROUND(AVG(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) > 7 THEN review_score END)::NUMERIC,2) AS sensitivity_gap
FROM orders_delivered AS od
JOIN
order_reviews AS r
ON od.order_id = r.order_id
JOIN 
order_items AS oi
ON od.order_id = oi.order_id
JOIN 
products AS p
ON oi.product_id = p.product_id
JOIN
category_translation as ct
ON p.product_category_name = ct.product_category_name
GROUP BY p.product_category_name,ct.product_category_name_english
ORDER BY sensitivity_gap DESC NULLS LAST;


-------------------------------------------------------------------------------------------------------------------------------------------------
--Q3 Is customer tolerance for delay uniform across regions, or are some states more sensitive to delay than others?
-------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
c.customer_state,
COUNT(*) AS total_orders,
COUNT(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) > 7 THEN 1 END) AS late_order_count,
ROUND(AVG(CASE WHEN(od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE)>7 THEN review_score END)::NUMERIC,2) AS late_avg,
ROUND(AVG(CASE WHEN(od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE)<=0 THEN review_score END)::NUMERIC,2) AS ontime_avg,
ROUND(AVG(CASE WHEN(od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE)<=0 THEN review_score END)::NUMERIC,2) -
ROUND(AVG(CASE WHEN(od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE)>7 THEN review_score END)::NUMERIC,2) as sensitivity_gap
FROM 
orders_delivered AS od
JOIN
customers AS c
ON
od.customer_id = c.customer_id
JOIN
order_reviews AS r
ON 
od.order_id = r.order_id
GROUP BY customer_state 
HAVING COUNT(*) >= 30
   AND COUNT(CASE WHEN (od.order_delivered_customer_date::DATE - od.order_estimated_delivery_date::DATE) > 7 THEN 1 END) >= 10
ORDER BY sensitivity_gap DESC NULLS LAST;

