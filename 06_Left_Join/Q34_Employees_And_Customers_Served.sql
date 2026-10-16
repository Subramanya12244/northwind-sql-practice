/* =====================================================================
   Q34 · Employees and Customers Served
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN · GROUP BY · COUNT DISTINCT
              · String Concatenation · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Number of distinct customers served per employee, with
             employees who handled no orders shown as 0.
   APPROACH:
     1. LEFT JOIN employees -> orders on employee_id (keep every employee).
     2. COUNT(DISTINCT o.customer_id) — DISTINCT avoids counting the same
        customer once per order (breadth, not volume).
     3. COUNT returns 0 for empty groups, so no COALESCE needed.
     4. Concatenate first_name + last_name for a single display name.
     5. GROUP BY employee_id (+ name columns, since selected).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT o.customer_id) AS customers_served
FROM employees e
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY customers_served DESC;
