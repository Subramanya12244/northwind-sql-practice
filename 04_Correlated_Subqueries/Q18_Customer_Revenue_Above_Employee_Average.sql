/* =====================================================================
   Q18 · Customer Revenue Above Employee Average
   Category : Correlated Subqueries     Difficulty : Hard
   Concepts : CTE · Correlated Subquery · GROUP BY · Aggregates (SUM, AVG)
   ---------------------------------------------------------------------
   PROBLEM : For each employee, return customers whose revenue (from orders
             handled by that employee) exceeds the average revenue of all
             customers handled by that same employee.
   APPROACH:
     1. Build a CTE (employee_customer_revenue) aggregating revenue per employee-customer pair.
     2. Select from that CTE in the outer query.
     3. Filter via a correlated subquery computing AVG(revenue) for only the
        rows matching the current row's employee_id.
     4. Sort by employee, then revenue descending.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH employee_customer_revenue AS (
    SELECT
        o.employee_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.employee_id, o.customer_id
)
SELECT
    ecr.employee_id,
    ecr.customer_id,
    ROUND(ecr.revenue::numeric, 2) AS revenue
FROM employee_customer_revenue ecr
WHERE ecr.revenue > (
    SELECT AVG(ecr2.revenue)
    FROM employee_customer_revenue ecr2
    WHERE ecr2.employee_id = ecr.employee_id   -- correlation
)
ORDER BY ecr.employee_id, ecr.revenue DESC;
