
---C. Ingredient Optimisation (INCOMPLETE)-----------------


--1. What are the standard ingredients for each pizza?--

SELECT 
	p.pizza_name,
	STRING_AGG(t.topping_name, ', ') AS ingredients
FROM 
	pizza_names p,
	cleaned_toppings t
WHERE p.pizza_id = t.pizza_id
GROUP BY p.pizza_name

--2. What was the most commonly added extra?--

SELECT 
		topping_name,
		COUNT(e.topping_id) AS no_of_added
FROM 
		extras e,
		cleaned_toppings c


WHERE e.topping_id=c.topping_id
GROUP BY topping_name

--3. Generate an order item for each record in the customers_orders table in the format of one of the following--

