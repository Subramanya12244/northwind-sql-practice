/* =====================================================================
   Q17 · Employees Above Average Revenue (Correlated Subquery)
   Category : Correlated Subqueries     Difficulty : Medium
   Concepts : INNER JOIN (multi-table) · GROUP BY · HAVING · Subquery (non-correlated) · Aggregates (SUM, AVG)
   ---------------------------------------------------------------------
   PROBLEM : Return employees whose total revenue exceeds the average
             revenue across all employees, via a HAVING + subquery.
   APPROACH:
     1. Join employees, orders, order_details; aggregate discounted revenue per employee.
     2. In HAVING, compare that total against a subquery that recomputes
        revenue per employee and averages it.
     3. Sort by total revenue descending.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING SUM(od.unit_price * od.quantity * (1 - od.discount)) > (
    SELECT AVG(rev)
    FROM (
        SELECT SUM(od2.unit_price * od2.quantity * (1 - od2.discount)) AS rev
        FROM orders o2
        JOIN order_details od2 ON od2.order_id = o2.order_id
        GROUP BY o2.employee_id
    ) sub
)
ORDER BY total_revenue DESC;
