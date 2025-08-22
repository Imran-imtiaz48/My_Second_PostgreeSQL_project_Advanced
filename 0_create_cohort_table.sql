CREATE OR REPLACE VIEW public.cohort_table AS
WITH customer_info AS (
    SELECT 
        c.customerkey,
        s.orderdate,
        SUM(s.exchangerate * s.netprice * s.quantity::double precision) AS client_revenue,
        COUNT(*) AS items_purchased,
        c.countryfull,
        c.age,
        CONCAT(TRIM(c.givenname), ' ', TRIM(c.surname)) AS full_name
    FROM sales s
    INNER JOIN customer c 
        ON s.customerkey = c.customerkey
    GROUP BY c.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
)
SELECT 
    customerkey,
    orderdate,
    client_revenue,
    items_purchased,
    countryfull,
    age,
    full_name,
    MIN(orderdate) OVER (PARTITION BY customerkey) AS first_order,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_info;
