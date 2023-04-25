# B. Data Analysis Questions

 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT(customer_id)) AS unique_customers
FROM subscriptions 
