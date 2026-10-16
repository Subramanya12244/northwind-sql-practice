/* =====================================================================
   Q19 · Customers Above Average Revenue Using CTE
   Category : Common Table Expressions (CTEs)     Difficulty : Medium
   Concepts : CTE (multiple) · INNER JOIN · GROUP BY · SUM/AVG · Cross Join (implicit, scalar)
   ---------------------------------------------------------------------
   PROBLEM : Return customers whose total discounted revenue exceeds the
             overall average customer revenue, using a clean two-CTE structure.
   APPROACH:
     1. CTE customer_revenue: per-customer discounted revenue.
     2. CTE overall_avg: single scalar AVG(total_revenue) over the first CTE.
     3. Comma-join both (one-row scalar broadcast); filter revenue > avg.
     4. ORDER BY total_revenue DESC.
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
),
overall_avg AS (
    SELECT AVG(total_revenue) AS avg_revenue
    FROM customer_revenue
)
SELECT cr.*
FROM customer_revenue cr, overall_avg oa
WHERE cr.total_revenue > oa.avg_revenue
ORDER BY cr.total_revenue DESC;
