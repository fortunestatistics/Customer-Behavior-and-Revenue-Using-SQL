-- Comprehensive SQL Queries for Revenue Analysis

-- Query 1: Total Revenue
SELECT SUM(amount) AS total_revenue
FROM sales;

-- Query 2: Revenue by Product
SELECT product_id, SUM(amount) AS revenue
FROM sales
GROUP BY product_id
ORDER BY revenue DESC;

-- Query 3: Monthly Revenue
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month, SUM(amount) AS monthly_revenue
FROM sales
GROUP BY month
ORDER BY month;

-- Query 4: Top 5 Products by Revenue
SELECT product_id, SUM(amount) AS revenue
FROM sales
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 5;

-- Query 5: Revenue by Customer Segment
SELECT customer_segment, SUM(amount) AS revenue
FROM sales
JOIN customers ON sales.customer_id = customers.id
GROUP BY customer_segment;
