WITH last_orderdate AS (
	SELECT 
		customerkey,
		cohort_year ,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS last_order_date,
		first_order 
	FROM cohort_table 	
), status_table AS (
	SELECT 
	customerkey,
	cohort_year,
	orderdate,
		CASE 
			WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 month' THEN 'Churned'
			ELSE 'Active'
		END AS client_status
	FROM last_orderdate 
	WHERE 
		last_order_date = 1 AND
		first_order < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 month'
		
)

SELECT 
	client_status,
	cohort_year,
	COUNT(customerkey) AS total_clients,
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) * 100, 2) AS active_rate
FROM status_table 
GROUP BY
	cohort_year,
	client_status
	