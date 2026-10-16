/* =====================================================================
   Q07 · Employees Above Average Revenue
   Category : GROUP BY & HAVING     Difficulty : Medium
   Concepts : INNER JOIN · GROUP BY · CTE · SUM/AVG · Scalar Subquery
   ---------------------------------------------------------------------
   PROBLEM : Return all employees whose total revenue exceeds the average
             total revenue across all employees.
   APPROACH:
     1. CTE (employee_revenue): each employee's total discounted revenue.
     2. Select from the CTE in the outer query.
     3. Filter with a scalar subquery computing AVG(total_revenue)
        over the whole CTE.
     4. ORDER BY total_revenue DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM employees e
    JOIN orders o ON o.employee_id = e.employee_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT *
FROM employee_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM employee_revenue)
ORDER BY total_revenue DESC;
