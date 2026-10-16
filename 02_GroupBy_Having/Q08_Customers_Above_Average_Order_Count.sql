/* =====================================================================
   Q08 · Customers Above Average Order Count
   Category : GROUP BY & HAVING     Difficulty : Medium
   Concepts : INNER JOIN · GROUP BY · CTE · COUNT/AVG · Scalar Subquery
   ---------------------------------------------------------------------
   PROBLEM : Return all customers whose order count exceeds the average
             order count across all customers.
   APPROACH:
     1. CTE (customer_orders): count orders per customer.
     2. Select from the CTE.
     3. Filter with a scalar subquery computing AVG(order_count)
        over the whole CTE.
     4. ORDER BY order_count DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

WITH customer_orders AS (
    SELECT
        cu.customer_id,
        cu.company_name,
        COUNT(o.order_id) AS order_count
    FROM customers cu
    JOIN orders o ON o.customer_id = cu.customer_id
    GROUP BY cu.customer_id, cu.company_name
)
SELECT *
FROM customer_orders
WHERE order_count > (SELECT AVG(order_count) FROM customer_orders)
ORDER BY order_count DESC;
