/* =====================================================================
   Q12 · Employees by Unique Customers Served
   Category : Category & Product Analytics     Difficulty : Easy
   Concepts : INNER JOIN · GROUP BY · COUNT(DISTINCT) · ORDER BY
   ---------------------------------------------------------------------
   PROBLEM : How many unique customers each employee has served,
             ranked highest to lowest (relationship breadth).
   APPROACH:
     1. Join employees -> orders on employee_id.
     2. COUNT(DISTINCT o.customer_id) per employee.
     3. GROUP BY employee.
     4. ORDER BY unique_customers DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY unique_customers DESC;
