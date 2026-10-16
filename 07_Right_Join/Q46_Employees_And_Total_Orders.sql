/* =====================================================================
   Q46 · Employees and Total Orders
   Category : RIGHT JOIN          Difficulty : Medium
   Concepts : RIGHT JOIN · GROUP BY · COUNT DISTINCT
              · String Concatenation (CONCAT) · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return all employees with the number of orders they handled,
             showing 0 for employees with no orders.
   APPROACH:
     1. Place orders on the LEFT, employees on the RIGHT.
     2. RIGHT JOIN preserves every employee regardless of order history.
     3. COUNT(DISTINCT order_id) — returns 0 for empty groups (no COALESCE);
        DISTINCT future-proofs against row multiplication if order_details joins in.
     4. GROUP BY employee_id, first_name, last_name.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
RIGHT JOIN employees e
    ON e.employee_id = o.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name;
