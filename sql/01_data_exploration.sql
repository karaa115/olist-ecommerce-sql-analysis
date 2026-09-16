-- Preview customer data
SELECT *
FROM customers
LIMIT 10;

-- Total number of customer records
SELECT
    COUNT(*) AS total_customer_records
FROM customers;


-- Number of unique customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- Number of customer records and unique customers by state
SELECT
    customer_state,
    COUNT(*) AS customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_state
ORDER BY customer_records DESC;


-- Top 10 cities by number of customer records
SELECT
    customer_city,
    COUNT(*) AS customer_records
FROM customers
GROUP BY customer_city
ORDER BY customer_records DESC
LIMIT 10;