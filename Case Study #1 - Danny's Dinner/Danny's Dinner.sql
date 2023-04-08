

--1. How much each customer spent on eating?--

SELECT
		customer_id,
		SUM(price) AS total_spent

FROM 
		sales s,
		menu m

WHERE s.product_id = m.product_id
GROUP BY customer_id


--2.How many days has each customers visited the restaurant?--

SELECT 
		customer_id,
		COUNT(DISTINCT (order_date)) AS total_visited_days

FROM sales
GROUP BY customer_id

--3.What was the first item from the menu purchased by each customer?--

WITH CTE_Customer_Order AS
(
SELECT 
		customer_id,
		order_date,
		product_name,
		DENSE_RANK () OVER (PARTITION BY customer_id
		ORDER BY order_date ) AS RANK

FROM	
		sales s,
		menu m

WHERE s.product_id = m.product_id
)

SELECT
		customer_id,
		product_name

FROM CTE_Customer_Order
WHERE RANK = 1
GROUP BY customer_id,
		product_name

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?--

SELECT 
		TOP 1 COUNT(s.product_id) AS total_ordered, 
		product_name

FROM 
	sales s,
	menu m

WHERE s.product_id = m.product_id
GROUP BY product_name 
ORDER BY COUNT(s.product_id) DESC

--5. Which item was the most popular for each customer?--

WITH CTE_most_popular_item AS
(
SELECT 
		customer_id,
		product_name,
		COUNT(s.product_id) AS ordered,
		DENSE_RANK () OVER (PARTITION BY customer_id
		ORDER BY COUNT(s.product_id)DESC) AS RANK

FROM 
	sales s,
	menu m

WHERE s.product_id = m.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, ordered, product_name
FROM CTE_most_popular_item
WHERE RANK = 1

--6. Which item was purchased first by the customer after they became a member?--

WITH CTE_first_purchased_item AS 
(
SELECT 
		s.customer_id,
		order_date,
		join_date,
		product_id,
		DENSE_RANK () OVER ( PARTITION BY s.customer_id
		ORDER BY order_date) AS RANK

FROM 
	sales s,
	members mm

WHERE 
		s.customer_id = mm.customer_id
		AND s.order_date >= mm.join_date
)

SELECT 
		customer_id,
		product_name,
		order_date,
		join_date,
		rank
FROM 
		CTE_first_purchased_item cc,
		menu m

WHERE cc.product_id = m.product_id
		AND RANK =1

--8. What is the total items and amount spent for each member before they became a member?--

WITH CTE_total AS 
( 
SELECT 
		s.customer_id,
		product_id
		

FROM		
		sales s,
		members mm

WHERE s.customer_id= mm.customer_id
		AND order_date < join_date

)
 SELECT 
		customer_id,
		COUNT(CTE.product_id) AS total_items,
		SUM(price) AS total_spent

FROM	CTE_total AS CTE,
		menu m

WHERE CTE.product_id= m.product_id
GROUP BY customer_id

--OTHERS SOLUTION ( JOIN 3 KALI)

SELECT
		s.customer_id,
		COUNT(s.product_id) AS total_items,
		SUM(price) AS total_spent

FROM 
		sales s,
		menu m,
		members mm

WHERE	s.product_id=m.product_id
		AND
		s.customer_id=mm.customer_id
		AND 
		order_date < join_date

GROUP BY s.customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?--	
		
SELECT
			customer_id,
			SUM(CASE
					WHEN s.product_id = 1 THEN price*20
					ELSE price*10
			END) AS total_points

FROM sales s,
	menu m

WHERE s.product_id=m.product_id
GROUP BY customer_id


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS 

 ( SELECT		*,
			DATEADD (DAY,6, join_date) AS valid_date,
			EOMONTH ('2021-01-1') AS last_date
	
	FROM members mm
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
WHERE 
			s.customer_id= d.customer_id
			AND
			s.product_id= m.product_id
			AND
			s.order_date < d.last_date
			
GROUP BY s.customer_id

--BONUS: JOIN ALL 


WITH join_all_cte AS

(SELECT
		s.customer_id,
		product_name,
		price,
		order_date,
		join_date,
		CASE 
		WHEN order_date >= join_date THEN 'Y'
			ELSE 'N'
			END AS member

FROM
		
		
		menu men,
		sales s
		LEFT JOIN members mem
		ON s.customer_id=mem.customer_id
		WHERE men.product_id=s.product_id
)

SELECT *
FROM join_all_cte





		
