--Title: Client Revenue by Cohort (Without Time Alignment)
SELECT 
	cohort_year,
	SUM(client_revenue) AS client_total_revenue,
	COUNT(DISTINCT customerkey) AS client_count,
	SUM(client_revenue) / COUNT(DISTINCT customerkey) AS avg_client_revenue
FROM cohort_table 
GROUP BY
	cohort_year
ORDER BY 
	cohort_year;


-- Title: Total Client Revenue by the Year of Their First Order
WITH order_years AS (
    SELECT
        customerkey,
        client_revenue,
        (orderdate - MIN(orderdate) OVER (PARTITION BY customerkey)) / 365 AS years_since_first_order
    FROM cohort_table
)

SELECT
    years_since_first_order,
    SUM(client_revenue) as client_total_revenue,
    SUM(client_revenue) / (SELECT SUM(client_revenue) FROM cohort_table) * 100 as total_revenue_percentage
FROM order_years
GROUP BY years_since_first_order
ORDER BY years_since_first_order;


-- Title: Cohort-Based Client Revenue Adjusted for Time Since Initial Order
SELECT
	cohort_year,
	SUM(client_revenue) AS cohort_profit,
	COUNT(DISTINCT customerkey) AS client_count,
	SUM(client_revenue) / COUNT(DISTINCT customerkey) AS avg_client_revenue
FROM cohort_table 
WHERE
	orderdate = first_order 
GROUP BY
	cohort_year 