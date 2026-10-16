/* =====================================================================
   Q06 · Customers Above Average Revenue
   Category : GROUP BY & HAVING     Difficulty : Medium
   Concepts : INNER JOIN · GROUP BY · CTE · SUM/AVG · Scalar Subquery
   ---------------------------------------------------------------------
   PROBLEM : Return all customers whose total revenue is strictly greater
             than the average total revenue across all customers.
   APPROACH:
     1. CTE (customer_revenue): each customer's total discounted revenue.
     2. Select from the CTE in the outer query.
     3. Filter with a scalar subquery computing AVG(total_revenue)
        across the entire CTE.
     4. ORDER BY total_revenue DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

WITH customer_revenue AS (
    SELECT
        cu.customer_id,
        cu.company_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM customers cu
    JOIN orders o ON o.customer_id = cu.customer_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY cu.customer_id, cu.company_name
)
SELECT *
FROM customer_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM customer_revenue)
ORDER BY total_revenue DESC;
