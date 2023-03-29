


-------------------------------------B. Runner and Customer Experience----------------------------------------------------


--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)---

SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?--

SELECT
		r.runner_id,
		AVG(DATEDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_date_to_HQ

FROM
		cleaned_runner_orders r,
		cleaned_customer_orders c

WHERE r.order_id= c.order_id
GROUP BY r.runner_id

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?--






-- NEED TO CHANGE FROM VARCHAR TO INT FIRST!!!!4. What was the average distance travelled for each customer?--

SELECT	
		customer_id,
		ROUND(AVG(distance),2) AS avg_distance_travelled

FROM	
		cleaned_customer_orders c,
		cleaned_runner_orders r

WHERE	c.order_id=r.order_id
GROUP BY customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?--

SELECT 
			MAX(duration) AS max_delivery_time,
			MIN(duration) AS min_delivery_time,
			MAX(duration) - MIN(duration) AS time_diff

FROM cleaned_runner_orders

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?--

SELECT
		runner_id,
		AVG(distance) AS avg_distance,
		AVG(duration) AS avg_duration,
		ROUND(AVG(distance)/ AVG(duration) *60,2) AS avg_speed_km_hr

FROM cleaned_runner_orders 
WHERE cancellation IS NULL
GROUP BY runner_id 

--7. What is the successful delivery percentage for each runner?--

SELECT
		runner_id,
		COUNT(order_id) AS total_ordered,
		COUNT(pickup_time) AS total_delivered,
		CAST(COUNT(pickup_time) AS FLOAT)/CAST (COUNT(order_id) AS FLOAT) * 100 AS percentage

FROM cleaned_runner_orders
GROUP BY runner_id

