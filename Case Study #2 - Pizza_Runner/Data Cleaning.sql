

----------------------------------------------- DATA CLEANING & TRANSFORMATIONS----------------------------------------

---1. CLEANED CUSTOMER TABLE----

SELECT 
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions = 'null' OR exclusions LIKE '' THEN NULL
		ELSE exclusions
	END AS exclusions,
	CASE
		WHEN extras = 'null' OR extras = '' THEN NULL
		ELSE extras
	END AS extras,
	order_time

INTO cleaned_customer_orders
FROM customer_orders


SELECT *
FROM cleaned_customer_orders



---2. CLEANSED RUNNER ORDER---

SELECT *
FROM runner_orders

DROP TABLE IF EXISTS cleaned_runner_orders

SELECT
	
	order_id,
	runner_id,
	CASE
		WHEN pickup_time = 'null' THEN NULL
		ELSE pickup_time
		END AS pickup_time,
	CASE
		WHEN distance = 'null' THEN NULL
		ELSE distance
		END AS distance,
	CASE	
		WHEN duration = 'null' THEN NULL
		ELSE duration
		END AS duration,
	CASE
		WHEN cancellation IN ( 'null', 'NULL', ' ')  THEN NULL
		ELSE cancellation
		END AS cancellation


INTO cleaned_runner_orders
FROM runner_orders

SELECT *
FROM cleaned_runner_orders


-----to trim km from distance column--
UPDATE cleaned_runner_orders
SET distance = TRIM ('km'  FROM distance)

---to make change float(decimals)---


