

---------------------------------------------------- A PIZZA METRICS---------------------------------------------------

--1. How many pizzas were ordered?--

SELECT COUNT(order_id) 
FROM cleaned_customer_orders

--2. How many unique customer orders were made?--

SELECT COUNT(DISTINCT (order_id) )
FROM cleaned_customer_orders

--3. How many successful orders were delivered by each runner?--

SELECT *
FROM cleaned_runner_orders

SELECT runner_id, COUNT(order_id) AS successful_order
FROM cleaned_runner_orders
WHERE cancellation is NULL
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?--




--5. How many Vegetarian and Meatlovers were ordered by each customer?--

SELECT
	customer_id,
	SUM(CASE
			WHEN c.pizza_id = 1 THEN 1 
			ELSE 0
			END) AS meat_lover,
	SUM(CASE
			WHEN c.pizza_id = 2 THEN 1 
			ELSE 0
			END) AS vegetarian

FROM 
	cleaned_customer_orders c
	
GROUP BY 
	customer_id

	------//-----

SELECT
		customer_id,
		pizza_name,
		COUNT(c.order_id) as ordered
FROM 
	cleaned_customer_orders c,
	pizza_names p

WHERE c.pizza_id = p.pizza_id

GROUP BY 
	customer_id,
	pizza_name

ORDER BY customer_id

--6. What was the maximum number of pizzas delivered in a single order?--

SELECT 
		TOP 1 c.order_id,
		COUNT(c.pizza_id) AS max_ordered

FROM
		cleaned_customer_orders c,
		cleaned_runner_orders r

WHERE	
		c.order_id=r.order_id
		AND
		r.cancellation IS NULL

GROUP BY c.order_id
ORDER BY max_ordered DESC

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
		c.customer_id,
		SUM(CASE
				WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1
				ELSE 0
				END) AS at_least_one_change,
		SUM(CASE
				WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1
				ELSE 0
				END) AS no_change

FROM 
			cleaned_customer_orders c,
			cleaned_runner_orders r
			
WHERE	
		c.order_id=r.order_id
		AND
		r.cancellation IS NULL

GROUP BY c.customer_id

--8. How many pizzas were delivered that had both exclusions and extras?--

SELECT 
		SUM(CASE 
				WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1
				ELSE 0
		END) AS have_both

FROM 
			cleaned_customer_orders c,
			cleaned_runner_orders r
			
WHERE	
		c.order_id=r.order_id
		AND
		r.cancellation IS NULL

--//////////---

SELECT 
		COUNT(pizza_id) AS have_both

FROM 
			cleaned_customer_orders c,
			cleaned_runner_orders r
			
WHERE	
		c.order_id=r.order_id
		AND
		r.cancellation IS NULL
		AND
		c.exclusions IS NOT NULL
		AND 
		c.extras IS NOT NULL

-- 9.What was the total volume of pizzas ordered for each hour of the day?--

SELECT 
	DATEPART(HOUR, order_time) as hour_of_day,
	COUNT(pizza_id) as total_orders

FROM cleaned_customer_orders c

GROUP BY DATEPART(HOUR, order_time)

--10. What was the volume of orders for each day of the week?

SELECT 
	FORMAT(order_time, 'dddd') as day_of_week,
	COUNT(pizza_id) as total_orders

FROM cleaned_customer_orders c

GROUP BY FORMAT(order_time, 'dddd')

