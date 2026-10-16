/* =====================================================================
   Q53 · Employees and Orders (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Medium
   Concepts : FULL OUTER JOIN · NULL Handling · String Concatenation (CONCAT)
   ---------------------------------------------------------------------
   PROBLEM : Return the employee name and order ID for every employee and
             every order — no employee and no order excluded.
   APPROACH:
     1. FULL OUTER JOIN orders to employees on employee_id.
     2. Build employee_name with CONCAT(first_name, ' ', last_name).
     3. Matched rows: employee handled an order — both sides populated.
     4. Left-only rows: employee never handled an order — order_id NULL.
     5. Right-only rows: order with no employee — employee_name NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   NOTE: Table order is irrelevant in FULL OUTER JOIN — both sides always
   preserved. CONCAT(NULL, ' ', NULL) returns ' ' (a space), not NULL;
   use NULLIF(CONCAT(...), ' ') if a clean NULL is required.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select concat(e.first_name,' ',e.last_name) as employee_name,
o.order_id
from orders o
full outer join employees e on e.employee_id = o.employee_id;
