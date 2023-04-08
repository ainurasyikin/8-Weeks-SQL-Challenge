
# B. Data Analysis Questions

 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT(customer_id)) AS unique_customers
FROM subscriptions 



2. What is the monthly distribution of trial plan start_date values for our dataset 
	- use the start of the month as the group by value (month, total_trials_customer)

SELECT DATEPART(MONTH, start_date) AS month, COUNT(customer_id) AS trials_customer
FROM subscriptions
WHERE plan_id = 0
GROUP BY DATEPART(MONTH, start_date)
ORDER BY month


3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT plan_name, COUNT(s.plan_id) AS total
FROM plans p, subscriptions s
WHERE DATEPART(YEAR,start_date) > '2020' AND p.plan_id = s.plan_id
GROUP BY plan_name
ORDER BY COUNT(s.plan_id)


4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?


DECLARE @total_cust float = 
(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)

SELECT COUNT(customer_id) AS total_churned, (COUNT(customer_id) / @total_cust) * 100 as churned_perct
FROM subscriptions
WHERE plan_id = 4


5. How many customers have churned STRAIGHT AFTER their initial free trial - what percentage is this rounded to the nearest whole number? (from plan_id 0 to 4)

WITH churned_after_trial AS (

		SELECT customer_id,
		CASE 
		WHEN plan_id = 4 AND LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0 THEN 1
		ELSE 0
		END AS is_churned
		FROM subscriptions
		)

SELECT SUM(is_churned) AS customer_churned, (SUM(is_churned) / CAST(COUNT(DISTINCT customer_id)AS FLOAT) * 100) AS total_percentage
FROM churned_after_trial

6. What is the number and percentage of customer plans after their initial free trial?

DECLARE @total_customer float = (
	SELECT COUNT(DISTINCT customer_id) 
	FROM subscriptions) ;

WITH customer_plans AS (

	SELECT customer_id, plan_id,
	ROW_NUMBER() OVER (PARTITION BY customer_id
	ORDER BY start_date) AS RANK
	FROM subscriptions s
	WHERE plan_id > 0
)

SELECT p.plan_name, COUNT(cp.plan_id) AS total_customer, COUNT(cp.plan_id) / @total_customer * 100 AS customers_percentage
FROM customer_plans cp, plans p
WHERE RANK = 1 AND cp.plan_id = p.plan_id
GROUP BY p.plan_name



7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

DECLARE @total_customers float = (
	SELECT COUNT(DISTINCT(customer_id))
	FROM subscriptions) ;

WITH customers_plan AS (

	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY customer_id
	ORDER BY (start_date)DESC) AS RANK
	FROM subscriptions
	WHERE start_date <= '2020-12-31'

	)

SELECT p.plan_name, COUNT(cp.plan_id) AS total_customer, COUNT(cp.plan_id) / @total_customers * 100 AS customers_percentage
FROM customers_plan cp, plans p
WHERE RANK =1 AND cp.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY p.plan_name


8. How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(DISTINCT(customer_id)) AS customers_count
FROM subscriptions s
WHERE plan_id = 3 AND start_date <= '2020-12-31'


9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?


# 1st step join both tables (no need to do this step, just for better understanding)

WITH CTE_annual_plan AS (

SELECT customer_id, start_date AS annual_start_date, plan_id
FROM subscriptions s
WHERE plan_id = 3 
)

SELECT *
FROM CTE_annual_plan cte, subscriptions s
WHERE s.plan_id = 0 AND cte.customer_id = s.customer_id


# 2nd steps, find the average (start - end) 

WITH CTE_annual_plan AS (

SELECT customer_id, start_date AS annual_start_date, plan_id
FROM subscriptions s
WHERE plan_id = 3 
)

SELECT AVG(DATEDIFF(DAY,s.start_date, cte.annual_start_date)*1.0) AS avg_days
FROM CTE_annual_plan cte, subscriptions s
WHERE s.plan_id = 0 AND cte.customer_id = s.customer_id


10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)



11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? (FROM plan 2 --->1 )

WITH downgraded_customer AS (

SELECT customer_id,
		CASE
		WHEN plan_id =1 AND LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 2 THEN 1
		ELSE 0
		END AS is_downgraded
		FROM subscriptions s
)
SELECT SUM(is_downgraded) AS total_downgraded
FROM downgraded_customer


