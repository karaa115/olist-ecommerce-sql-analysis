-- category sales ranking
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
    RANK() OVER (ORDER BY sales DESC) AS sales_rank
FROM category_sales
ORDER BY sales_rank;