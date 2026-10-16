/* =====================================================================
   Q82 · Contact Directory with Type Label
   Category : Set Operators (UNION with literal columns)   Difficulty : Medium
   Concepts : UNION · Set Operators · Literal String Columns · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Return a unified contact directory combining customers and
             employees — name, city, and a type label for each row.
   APPROACH:
     1. SELECT 1 — customers: contact_name, city, literal 'Customer'.
     2. SELECT 2 — employees: CONCAT(first_name,' ',last_name), city,
        literal 'Employee'. CONCAT joins the two employee name columns
        into one to match the customers' single contact_name column.
     3. UNION combines both 3-column result sets (compatible types).
   MISTAKES I MADE:
     • 'employee' (lowercase) used instead of 'Employee' (title case) →
       case-sensitive comparison breaks downstream WHERE type = 'Employee'
       → fix: use 'Employee' to match 'Customer' and the expected output.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (buggy: 'employee' should be 'Employee') ────
-- select c.contact_name, c.city, 'Customer' as type
-- from customers c
-- union
-- select concat(e.first_name,' ',e.last_name) as employee_name, e.city, 'employee' as type
-- from employees e;

-- ── FINAL CORRECT SOLUTION (consistent capitalisation + ORDER BY) ────
SELECT c.contact_name AS name, c.city, 'Customer' AS type
FROM customers c
UNION
SELECT CONCAT(e.first_name, ' ', e.last_name), e.city, 'Employee' AS type
FROM employees e
ORDER BY type, name;
