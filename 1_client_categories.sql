
WITH ltv_table AS 
(
	SELECT 
		customerkey,
		SUM(client_revenue) AS client_ltv
	FROM cohort_table
	GROUP BY 
		customerkey
), pct_values AS 
(
	SELECT 
		(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY client_ltv)) AS pct_25,
		(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY client_ltv)) AS pct_75
	FROM ltv_table
), ltv_categorized AS
(
	SELECT 
		l.*,
		CASE
			WHEN l.client_ltv <= pct_25 THEN '1 - Low LTV'
			WHEN l.client_ltv >= pct_75 THEN '3 - High LTV'
			ELSE '2 - Medium LTV'
		END AS ltv_category
		
	FROM ltv_table l, pct_values p
)

SELECT 
	ltv_category,
	SUM(client_ltv) AS total_ltv,
	SUM(client_ltv) / (SELECT SUM(client_ltv) FROM ltv_categorized) * 100 AS ltv_pctg,
	COUNT(customerkey) AS client_count,
	SUM(client_ltv) / COUNT(customerkey) AS avg_ltv
FROM ltv_categorized 
GROUP BY 
	ltv_category
ORDER BY 
	total_ltv DESC
