-- product and category data
SELECT
    oi.order_id,
    oi.product_id,
    oi.price,
    oi.freight_value,
    p.product_category_name,
    ct.product_category_name_english
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
LIMIT 10;

-- top product categories by sales
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_sales,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY product_sales DESC
LIMIT 10;

-- shipping cost by category
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY avg_freight DESC
LIMIT 10;

-- sales share by category
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS product_sales,
    ROUND(
        SUM(oi.price) * 100.0 /
        (SELECT SUM(price) FROM order_items),
        2
    ) AS sales_share_pct
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY sales_share_pct DESC
LIMIT 10;

-- compare row_number and rank
WITH category_sales AS (
    SELECT
        ct.product_category_name_english AS category,
        ROUND(SUM(oi.price), 2) AS sales
    FROM order_items AS oi
    JOIN products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
)

SELECT
    category,
    sales,
    ROW_NUMBER() OVER (ORDER BY sales DESC) AS row_number,
    RANK() OVER (ORDER BY sales DESC) AS sales_rank
FROM category_sales
ORDER BY sales DESC;

-- monthly sales: previous and next month
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
    LAG(revenue) OVER (ORDER BY month) AS previous_month,
    LEAD(revenue) OVER (ORDER BY month) AS next_month
FROM monthly_sales
ORDER BY month;

-- month-over-month revenue change
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(p.payment_value), 2) AS revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    GROUP BY month
),
sales_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month
    FROM monthly_sales
)

SELECT
    month,
    revenue,
    previous_month,
    ROUND(
        (revenue - previous_month) * 100.0 / previous_month,
        2
    ) AS revenue_change_pct
FROM sales_with_previous
ORDER BY month;

-- top products within each category
WITH product_sales AS (
    SELECT
        ct.product_category_name_english AS category,
        oi.product_id,
        ROUND(SUM(oi.price), 2) AS sales
    FROM order_items AS oi
    JOIN products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY
        ct.product_category_name_english,
        oi.product_id
)

SELECT
    category,
    product_id,
    sales,
    RANK() OVER (
        PARTITION BY category
        ORDER BY sales DESC
    ) AS product_rank
FROM product_sales
ORDER BY category, product_rank;

-- top 3 products in each category
WITH product_sales AS (
    SELECT
        ct.product_category_name_english AS category,
        oi.product_id,
        ROUND(SUM(oi.price), 2) AS sales
    FROM order_items AS oi
    JOIN products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    WHERE ct.product_category_name_english IS NOT NULL
    GROUP BY
        ct.product_category_name_english,
        oi.product_id
),

ranked_products AS (
    SELECT
        category,
        product_id,
        sales,
        RANK() OVER (
            PARTITION BY category
            ORDER BY sales DESC
        ) AS product_rank
    FROM product_sales
)

SELECT
    category,
    product_id,
    sales,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;

-- order value segmentation
WITH order_values AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value), 2) AS order_value
    FROM payments
    GROUP BY order_id
)

SELECT
    order_id,
    order_value,
    CASE
        WHEN order_value < 100 THEN 'Low'
        WHEN order_value <= 300 THEN 'Medium'
        ELSE 'High'
    END AS value_segment
FROM order_values
ORDER BY order_value DESC
LIMIT 20;


-- order value segment distribution
WITH order_values AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value), 2) AS order_value
    FROM payments
    GROUP BY order_id
),

segmented_orders AS (
    SELECT
        order_id,
        order_value,
        CASE
            WHEN order_value < 100 THEN 'Low'
            WHEN order_value <= 300 THEN 'Medium'
            ELSE 'High'
        END AS value_segment
    FROM order_values
)

SELECT
    value_segment,
    COUNT(*) AS orders,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM segmented_orders),
        2
    ) AS orders_share_pct
FROM segmented_orders
GROUP BY value_segment
ORDER BY orders DESC;

-- categories with high sales volume
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS sales,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name_english IS NOT NULL
GROUP BY ct.product_category_name_english
HAVING COUNT(*) >= 1000
ORDER BY sales DESC;

-- unusually high-value orders
WITH order_values AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value), 2) AS order_value
    FROM payments
    GROUP BY order_id
),

stats AS (
    SELECT
        AVG(order_value) AS avg_order_value
    FROM order_values
)

SELECT
    ov.order_id,
    ov.order_value,
    ROUND(s.avg_order_value, 2) AS avg_order_value,
    ROUND(
        ov.order_value / s.avg_order_value,
        2
    ) AS times_above_average
FROM order_values AS ov
CROSS JOIN stats AS s
WHERE ov.order_value > s.avg_order_value * 5
ORDER BY ov.order_value DESC;