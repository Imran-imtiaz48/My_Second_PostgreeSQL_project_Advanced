-- Title: Client Revenue by Cohort (Without Time Alignment)
SELECT 
    cohort_year,
    SUM(client_revenue) AS client_total_revenue,
    COUNT(DISTINCT customerkey) AS client_count,
    ROUND(SUM(client_revenue)::numeric / COUNT(DISTINCT customerkey), 2) AS avg_client_revenue
FROM cohort_table 
GROUP BY cohort_year
ORDER BY cohort_year;


-- Title: Total Client Revenue by the Year of Their First Order
WITH order_years AS (
    SELECT
        customerkey,
        client_revenue,
        EXTRACT(YEAR FROM AGE(orderdate, MIN(orderdate) OVER (PARTITION BY customerkey)))::int AS years_since_first_order
    FROM cohort_table
)
SELECT
    years_since_first_order,
    SUM(client_revenue) AS client_total_revenue,
    ROUND(SUM(client_revenue) * 100.0 / (SELECT SUM(client_revenue) FROM cohort_table), 2) AS total_revenue_percentage
FROM order_years
GROUP BY years_since_first_order
ORDER BY years_since_first_order;


-- Title: Cohort-Based Client Revenue Adjusted for Time Since Initial Order
WITH first_orders AS (
    SELECT
        customerkey,
        cohort_year,
        MIN(orderdate) AS first_order
    FROM cohort_table
    GROUP BY customerkey, cohort_year
)
SELECT
    f.cohort_year,
    SUM(c.client_revenue) AS cohort_revenue,
    COUNT(DISTINCT f.customerkey) AS client_count,
    ROUND(SUM(c.client_revenue)::numeric / COUNT(DISTINCT f.customerkey), 2) AS avg_client_revenue
FROM cohort_table c
INNER JOIN first_orders f
    ON c.customerkey = f.customerkey
   AND c.orderdate = f.first_order
GROUP BY f.cohort_year
ORDER BY f.cohort_year;
