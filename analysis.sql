USE ecommerce_db;

-- Monthly Revenue Trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

-- Top 5 Customers by Lifetime Value
SELECT
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC
LIMIT 5;

-- Revenue Contribution % by Product Category
SELECT
    p.category,
    ROUND(
        SUM(oi.quantity * p.price) /
        (SELECT SUM(oi2.quantity * p2.price)
         FROM order_items oi2
         JOIN products p2 ON oi2.product_id = p2.product_id) * 100, 2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category;

-- Running Total of Revenue
SELECT
    o.order_date,
    SUM(oi.quantity * p.price) AS daily_revenue,
    SUM(SUM(oi.quantity * p.price))
        OVER (ORDER BY o.order_date) AS running_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Rank Products by Revenue
SELECT
    p.product_name,
    SUM(oi.quantity * p.price) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name;
 
-- Average Order Value
SELECT
    ROUND(
        SUM(oi.quantity * p.price) / COUNT(DISTINCT o.order_id), 2
    ) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Most Popular Payment Method by Usage
SELECT
    payment_method,
    COUNT(*) AS usage_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank
FROM payments
GROUP BY payment_method;

-- Top 10 Customers by Spending
SELECT 
    c.name,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 10;
 
