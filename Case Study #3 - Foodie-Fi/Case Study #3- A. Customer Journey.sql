


# A. Customer Journey

SELECT customer_id, s.plan_id, plan_name, price, start_date
FROM plans p, subscriptions s
WHERE p.plan_id = s.plan_id
ORDER BY customer_id