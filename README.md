# Customer-Behavior-and-Revenue-Using-SQL

-- ================================================================
-- SETUP: Derived revenue column (Quantity * UnitPrice)
-- ================================================================

-- ================================================================
-- 1. TOTAL REVENUE & ORDERS OVERVIEW
-- ================================================================
SELECT
  COUNT(DISTINCT InvoiceNo)                        AS total_orders,
  COUNT(DISTINCT CustomerID)                        AS total_customers,
  ROUND(SUM(Quantity * UnitPrice), 2)              AS total_revenue,
  ROUND(AVG(Quantity * UnitPrice), 2)              AS avg_order_value,
  MIN(InvoiceDate)                                  AS first_sale,
  MAX(InvoiceDate)                                  AS last_sale
FROM online_retail
WHERE Quantity > 0
  AND UnitPrice > 0
  AND CustomerID IS NOT NULL;

-- ================================================================
-- 2. MONTHLY REVENUE TREND
-- ================================================================
SELECT
  DATE_FORMAT(InvoiceDate, '%Y-%m')               AS month,
  COUNT(DISTINCT InvoiceNo)                        AS orders,
  COUNT(DISTINCT CustomerID)                       AS active_customers,
  ROUND(SUM(Quantity * UnitPrice), 2)             AS revenue,
  ROUND(AVG(Quantity * UnitPrice), 2)             AS avg_order_value
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- ================================================================
-- 3. REVENUE BY COUNTRY
-- ================================================================
SELECT
  Country,
  COUNT(DISTINCT CustomerID)                       AS customers,
  COUNT(DISTINCT InvoiceNo)                        AS orders,
  ROUND(SUM(Quantity * UnitPrice), 2)             AS revenue,
  ROUND(SUM(Quantity * UnitPrice)
        / COUNT(DISTINCT CustomerID), 2)           AS revenue_per_customer
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
GROUP BY Country
ORDER BY revenue DESC;

-- ================================================================
-- 4. NEW vs RETURNING CUSTOMERS (Monthly)
-- ================================================================
WITH first_purchase AS (
  SELECT CustomerID, DATE_FORMAT(MIN(InvoiceDate), '%Y-%m') AS cohort_month
  FROM online_retail
  WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
  GROUP BY CustomerID
)
SELECT
  DATE_FORMAT(o.InvoiceDate, '%Y-%m')             AS month,
  COUNT(DISTINCT CASE
    WHEN DATE_FORMAT(o.InvoiceDate, '%Y-%m') = f.cohort_month
    THEN o.CustomerID END)                          AS new_customers,
  COUNT(DISTINCT CASE
    WHEN DATE_FORMAT(o.InvoiceDate, '%Y-%m') > f.cohort_month
    THEN o.CustomerID END)                          AS returning_customers
FROM online_retail o
JOIN first_purchase f ON o.CustomerID = f.CustomerID
WHERE o.Quantity > 0 AND o.UnitPrice > 0
GROUP BY 1
ORDER BY 1;

-- ================================================================
-- 5. REPEAT PURCHASE RATE
-- ================================================================
WITH customer_freq AS (
  SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS order_count
  FROM online_retail
  WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
  GROUP BY CustomerID
)
SELECT
  COUNT(*)                                          AS total_customers,
  SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
  SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
  ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2)                              AS repeat_rate_pct
FROM customer_freq;

-- ================================================================
-- 6. CUSTOMER LIFETIME VALUE (CLV)
-- ================================================================
SELECT
  CustomerID,
  Country,
  COUNT(DISTINCT InvoiceNo)                        AS total_orders,
  ROUND(SUM(Quantity * UnitPrice), 2)             AS lifetime_value,
  ROUND(AVG(Quantity * UnitPrice), 2)             AS avg_order_value,
  MIN(InvoiceDate)                                  AS first_order,
  MAX(InvoiceDate)                                  AS last_order,
  DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate))     AS customer_lifespan_days
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
GROUP BY CustomerID, Country
ORDER BY lifetime_value DESC
LIMIT 50;

-- ================================================================
-- 7. RFM SEGMENTATION (Recency, Frequency, Monetary)
-- ================================================================
WITH rfm_base AS (
  SELECT
    CustomerID,
    DATEDIFF('2011-12-09', MAX(InvoiceDate))        AS recency_days,
    COUNT(DISTINCT InvoiceNo)                        AS frequency,
    ROUND(SUM(Quantity * UnitPrice), 2)             AS monetary
  FROM online_retail
  WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
  GROUP BY CustomerID
),
rfm_scored AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency_days DESC)      AS r_score,
    NTILE(5) OVER (ORDER BY frequency)              AS f_score,
    NTILE(5) OVER (ORDER BY monetary)               AS m_score
  FROM rfm_base
)
SELECT
  CustomerID,
  recency_days,
  frequency,
  monetary,
  r_score, f_score, m_score,
  CONCAT(r_score, f_score, m_score)                AS rfm_segment,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
    ELSE 'Potential Loyalists'
  END                                               AS segment_label
FROM rfm_scored
ORDER BY monetary DESC;

-- ================================================================
-- 8. TOP 10 PRODUCTS BY REVENUE
-- ================================================================
SELECT
  StockCode,
  Description,
  SUM(Quantity)                                    AS units_sold,
  ROUND(SUM(Quantity * UnitPrice), 2)             AS revenue,
  COUNT(DISTINCT CustomerID)                       AS unique_buyers
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
GROUP BY StockCode, Description
ORDER BY revenue DESC
LIMIT 10;

-- ================================================================
-- 9. MONTHLY COHORT RETENTION
-- ================================================================
WITH cohort AS (
  SELECT
    CustomerID,
    DATE_FORMAT(MIN(InvoiceDate), '%Y-%m')         AS cohort_month
  FROM online_retail
  WHERE Quantity > 0 AND UnitPrice > 0 AND CustomerID IS NOT NULL
  GROUP BY CustomerID
),
activity AS (
  SELECT DISTINCT
    o.CustomerID,
    DATE_FORMAT(o.InvoiceDate, '%Y-%m')            AS active_month
  FROM online_retail o
  WHERE o.Quantity > 0 AND o.UnitPrice > 0 AND o.CustomerID IS NOT NULL
),
cohort_size AS (
  SELECT cohort_month, COUNT(DISTINCT CustomerID) AS cohort_customers
  FROM cohort GROUP BY cohort_month
)
SELECT
  c.cohort_month,
  a.active_month,
  PERIOD_DIFF(
    REPLACE(a.active_month, '-', ''),
    REPLACE(c.cohort_month, '-', '')
  )                                                 AS month_number,
  COUNT(DISTINCT a.CustomerID)                     AS retained_customers,
  cs.cohort_customers,
  ROUND(100.0 * COUNT(DISTINCT a.CustomerID)
        / cs.cohort_customers, 2)                   AS retention_pct
FROM cohort c
JOIN activity a    ON c.CustomerID = a.CustomerID
JOIN cohort_size cs ON c.cohort_month = cs.cohort_month
GROUP BY c.cohort_month, a.active_month, cs.cohort_customers
ORDER BY c.cohort_month, a.active_month;

-- ================================================================
-- 10. CANCELLED ORDERS IMPACT
-- ================================================================
SELECT
  CASE WHEN InvoiceNo LIKE 'C%' THEN 'Cancelled' ELSE 'Completed' END AS order_type,
  COUNT(DISTINCT InvoiceNo)                        AS orders,
  COUNT(DISTINCT CustomerID)                       AS customers,
  ROUND(SUM(Quantity * UnitPrice), 2)             AS revenue_impact
FROM online_retail
WHERE CustomerID IS NOT NULL
GROUP BY 1;
