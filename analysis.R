# Analysis of Customer Behavior and Revenue

## Load Libraries
library(ggplot2)  
library(dplyr)  
library(DBI)  
library(RSQLite)

## Connect to Database
conn <- dbConnect(RSQLite::SQLite(), 'path_to_your_database.db')


### SQL Query: Top Products
query_top_products <- 'SELECT product_name, SUM(quantity) as total_quantity FROM sales GROUP BY product_name ORDER BY total_quantity DESC LIMIT 10'

top_products <- dbGetQuery(conn, query_top_products)

### Summary Statistics for Top Products
summary_top_products <- summary(top_products)

### Visualization: Top Products
ggplot(top_products, aes(x=reorder(product_name, total_quantity), y=total_quantity)) +
  geom_bar(stat='identity') +
  coord_flip() +
  labs(title='Top 10 Products Sold', x='Product Name', y='Quantity Sold')


### SQL Query: Top Customers
query_top_customers <- 'SELECT customer_id, SUM(amount) as total_spent FROM sales GROUP BY customer_id ORDER BY total_spent DESC LIMIT 10'

top_customers <- dbGetQuery(conn, query_top_customers)

### Summary Statistics for Top Customers
summary_top_customers <- summary(top_customers)

### Visualization: Top Customers
ggplot(top_customers, aes(x=reorder(customer_id, total_spent), y=total_spent)) +
  geom_bar(stat='identity') +
  coord_flip() +
  labs(title='Top 10 Customers by Revenue', x='Customer ID', y='Total Revenue')


### SQL Query: Revenue Trends
query_revenue_trends <- 'SELECT strftime("%Y-%m", date) as month, SUM(amount) as total_revenue FROM sales GROUP BY month'

revenue_trends <- dbGetQuery(conn, query_revenue_trends)

### Visualization: Revenue Trends
ggplot(revenue_trends, aes(x=month, y=total_revenue)) +
  geom_line() +
  geom_point() +
  labs(title='Revenue Trends Over Time', x='Month', y='Total Revenue')


### SQL Query: Repeat Customer Behavior
query_repeat_customers <- 'SELECT customer_id, COUNT(DISTINCT(order_id)) as order_count FROM sales GROUP BY customer_id HAVING order_count > 1'

repeat_customers <- dbGetQuery(conn, query_repeat_customers)

### Summary Statistics for Repeat Customers
summary_repeat_customers <- summary(repeat_customers)  

# Close Database Connection
dbDisconnect(conn)  
