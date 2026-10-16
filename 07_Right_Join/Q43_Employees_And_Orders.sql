/* =====================================================================
   Q43 · Employees and Orders
   Category : RIGHT JOIN          Difficulty : Easy
   Concepts : RIGHT JOIN · NULL Handling · String Concatenation (CONCAT)
   ---------------------------------------------------------------------
   PROBLEM : Return all orders with the handling employee's name,
             preserving every order even if it has no matching employee.
   APPROACH:
     1. Place employees on the LEFT, orders on the RIGHT.
     2. RIGHT JOIN preserves every order regardless of a matching employee.
     3. CONCAT(first, ' ', last) builds employee_name; all-NULL inputs
        yield a space in PostgreSQL (use NULLIF(CONCAT(...), ' ') for clean NULL).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    o.order_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM employees e
RIGHT JOIN orders o
    ON o.employee_id = e.employee_id;
