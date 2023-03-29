SELECT *
FROM menu

--1. How much each customer spent on eating?--

SELECT 
	customer_id, 
	sum(price) AS total_spent

FROM 
	sales s,
	menu m

WHERE s.product_id = m.product_id
GROUP BY customer_id


--2.How many days has each customers visited the restaurant?--

SELECT 
	customer_id, 
	COUNT(DISTINCT(order_date)) AS visit_count

FROM sales
GROUP BY customer_id

--3.What was the first item from the menu purchased by each customer?--
WITH CTE_first_purchased AS
(
SELECT customer_id, order_date, sales.product_id, product_name,
	DENSE_RANK() OVER(PARTITION BY sales.customer_id
    ORDER BY (sales.order_date)) AS rank
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
)
SELECT customer_id, product_name
FROM CTE_first_purchased
WHERE RANK = 1
GROUP BY customer_id, product_name



--4. What is the most purchased item on the menu and how many times was it purchased by all customers?--
SELECT TOP 1 COUNT(sales.product_id) AS most_purchased, menu.product_name
FROM dbo.sales
JOIN dbo.menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id, menu.product_name
ORDER BY most_purchased DESC

--5. Which item was the most popular for each customer?--
WITH CTE_fav_items AS
(SELECT DISTINCT(customer_id), menu.product_name, COUNT(sales.product_id) AS order_count,
	DENSE_RANK() OVER(PARTITION BY sales.customer_id
      ORDER BY COUNT(sales.customer_id) DESC) AS rank
FROM dbo.sales
JOIN dbo.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id, menu.product_name
)

SELECT customer_id, product_name, order_count
FROM CTE_fav_items
WHERE rank = 1

--6. Which item was purchased first by the customer after they became a member?--
WITH CTE_members_sales AS
(
SELECT members.customer_id, join_date, order_date, product_id,
	DENSE_RANK() OVER(PARTITION BY members.customer_id
    ORDER BY sales.order_date) AS rank	
	FROM sales
JOIN members
ON sales.customer_id = members.customer_id
WHERE members.join_date <= sales.order_date
)
SELECT customer_id, join_date, order_date, product_name
FROM CTE_members_sales 
JOIN menu
ON CTE_members_sales.product_id = menu.product_id
WHERE RANK = 1

--7. Which item was purchased just before the customer became a member?--
WITH CTE_purchased_items AS
(
SELECT sales.customer_id, join_date, order_date, product_id,
	DENSE_RANK () OVER(PARTITION BY sales.customer_id
	ORDER BY sales.order_date DESC) AS rank	
FROM sales
JOIN members
ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)
SELECT customer_id, order_date, product_name
FROM CTE_purchased_items
JOIN menu
ON CTE_purchased_items.product_id = menu.product_id
WHERE rank = 1

--8. What is the total items and amount spent for each member before they became a member?--

SELECT 
		s.customer_id, 
		COUNT (s.product_id) AS items,
		SUM(price) AS total_spent

FROM	sales s,
		members mem,
		menu men

WHERE 
		mem.customer_id = s.customer_id
		AND
		men.product_id = s.product_id
		AND 
		order_date < join_date

GROUP BY s.customer_id
		

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?--

SELECT
		s.customer_id,
		SUM( CASE 
					WHEN s.product_id = 1 THEN price*20
					ELSE price*10
			END) AS total_points

FROM
		sales s,
		menu m

WHERE s.product_id = m.product_id
GROUP BY s.customer_id

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS (
		SELECT *, 
		DATEADD(DAY, 6, join_date) AS valid_date, 
		EOMONTH('2021-01-1') AS last_date
	FROM members
)

SELECT
		s.customer_id,
			SUM( CASE
					WHEN s.product_id = 1 THEN price*20
					WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN price*20
					ELSE price*10
				END) AS total_points
FROM 
		dates_cte d,
		sales s,
		menu m

	WHERE d.customer_id = s.customer_id
	AND
	m.product_id = s.product_id
	AND
	s.order_date <= d.last_date
GROUP BY s.customer_id




