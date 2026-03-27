# Data Dictionary

## Database Schema and Tables

### 1. Customers
- **customer_id**: Unique identifier for each customer.
- **first_name**: Customer's first name.
- **last_name**: Customer's last name.
- **email**: Customer's email address.
- **signup_date**: Date when the customer signed up.
- **status**: Current status (active, inactive).

### 2. Orders
- **order_id**: Unique identifier for each order.
- **customer_id**: ID of the customer who made the order.
- **order_date**: Date when the order was placed.
- **amount**: Total amount of the order.
- **status**: Current status of the order (pending, completed, refunded).

### 3. Products
- **product_id**: Unique identifier for each product.
- **product_name**: Name of the product.
- **category**: Category of the product.
- **price**: Price of the product.

### 4. Reviews
- **review_id**: Unique identifier for each review.
- **product_id**: ID of the product being reviewed.
- **customer_id**: ID of the customer who wrote the review.
- **rating**: Rating given by the customer.
- **comment**: Review comments.

### 5. Transactions
- **transaction_id**: Unique identifier for each transaction.
- **order_id**: ID of the order associated with the transaction.
- **transaction_date**: Date of the transaction.
- **payment_method**: Method used for payment (credit card, PayPal).

### Summary
This data dictionary provides a clear description of the schema and each table utilized within the customer behavior and revenue database, facilitating understanding and maintenance of the database structure.