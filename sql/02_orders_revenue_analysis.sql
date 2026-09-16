--Preview payment data
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM payments
LIMIT 10;

-- payment summary
SELECT
    COUNT(*) AS payments,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_value), 2) AS avg_payment,
    MIN(payment_value) AS min_payment,
    MAX(payment_value) AS max_payment
FROM payments;

-- payments by type
SELECT
    payment_type,
    COUNT(*) AS payments,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

-- orders with payments
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    p.payment_type,
    p.payment_value
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
LIMIT 10;

-- monthly revenue
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- monthly revenue change
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(p.payment_value), 2) AS revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    GROUP BY month
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
FROM monthly_sales
ORDER BY month;

-- monthly revenue growth
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(p.payment_value), 2) AS revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    GROUP BY month
),
revenue_change AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly_sales
)

SELECT
    month,
    revenue,
    previous_revenue,
    ROUND(
        (revenue - previous_revenue) * 100.0 / previous_revenue,
        2
    ) AS revenue_change_pct
FROM revenue_change
ORDER BY month;