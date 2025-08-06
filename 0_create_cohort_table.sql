CREATE OR REPLACE VIEW public.cohort_table
AS WITH customer_info AS (
         SELECT c.customerkey,
            s.orderdate,
            sum(s.exchangerate * s.netprice * s.quantity::double precision) AS client_revenue,
            count(*) AS items_purchased,
            c.countryfull,
            c.age,
            concat(TRIM(BOTH FROM c.givenname), ' ', TRIM(BOTH FROM c.surname)) AS full_name
           FROM sales s
             JOIN customer c ON s.customerkey = c.customerkey
          GROUP BY c.customerkey, s.orderdate
          ORDER BY c.customerkey
        )
 SELECT customerkey,
    orderdate,
    client_revenue,
    items_purchased,
    countryfull,
    age,
    full_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_order,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_info;