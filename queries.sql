-- Query to find products that generate the most revenue
SELECT product_id, SUM(revenue) AS total_revenue 
FROM sales 
GROUP BY product_id 
ORDER BY total_revenue DESC;

-- Query to identify the highest-value customers
SELECT customer_id, SUM(revenue) AS total_spent 
FROM sales 
GROUP BY customer_id 
ORDER BY total_spent DESC;

-- Query to analyze revenue trends over time
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month, SUM(revenue) AS total_revenue 
FROM sales 
GROUP BY month 
ORDER BY month;

-- Query to determine markets that perform the best
SELECT market, SUM(revenue) AS total_revenue 
FROM sales 
GROUP BY market 
ORDER BY total_revenue DESC;

-- Query for repeat customer analysis
SELECT customer_id, COUNT(DISTINCT order_id) AS number_of_orders 
FROM sales 
GROUP BY customer_id 
HAVING number_of_orders > 1;