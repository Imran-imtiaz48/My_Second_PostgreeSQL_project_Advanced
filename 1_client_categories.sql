WITH ltv_table AS 
(
    SELECT 
        customerkey,
        SUM(client_revenue) AS client_ltv
    FROM cohort_table
    GROUP BY customerkey
), pct_values AS 
(
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY client_ltv) AS pct_25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY client_ltv) AS pct_75
    FROM ltv_table
), ltv_categorized AS
(
    SELECT 
        l.customerkey,
        l.client_ltv,
        CASE
            WHEN l.client_ltv <= p.pct_25 THEN '1 - Low LTV'
            WHEN l.client_ltv >= p.pct_75 THEN '3 - High LTV'
            ELSE '2 - Medium LTV'
        END AS ltv_category
    FROM ltv_table l
    CROSS JOIN pct_values p
), total_ltv_sum AS
(
    SELECT SUM(client_ltv) AS grand_total_ltv
    FROM ltv_categorized
)
SELECT 
    l.ltv_category,
    SUM(l.client_ltv) AS total_ltv,
    ROUND(SUM(l.client_ltv) * 100.0 / t.grand_total_ltv, 2) AS ltv_pctg,
    COUNT(l.customerkey) AS client_count,
    ROUND(SUM(l.client_ltv)::numeric / COUNT(l.customerkey), 2) AS avg_ltv
FROM ltv_categorized l
CROSS JOIN total_ltv_sum t
GROUP BY l.ltv_category, t.grand_total_ltv
ORDER BY total_ltv DESC;
