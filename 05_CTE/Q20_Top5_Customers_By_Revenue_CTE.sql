/* =====================================================================
   Q20 · Top 5 Customers by Revenue Using CTE
   Category : Common Table Expressions (CTEs)     Difficulty : Easy
   Concepts : CTE · INNER JOIN · GROUP BY · SUM · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Return the top 5 customers by total discounted revenue,
             expressed via a CTE for clarity.
   APPROACH:
     1. CTE customer_revenue: aggregate discounted revenue per customer.
     2. SELECT all columns from the CTE.
     3. ORDER BY total_revenue DESC; LIMIT 5.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
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
ORDER BY total_revenue DESC
LIMIT 5;
