/* =====================================================================
   Q83 · Master Contact Directory
   Category : Set Operators (UNION — three-way, typed)   Difficulty : Medium
   Concepts : UNION (three-way) · Set Operators · Literal String Columns · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Return a unified Master Contact Directory combining customers,
             suppliers, and employees into one three-column result with
             name, city, and an entity-type label.
   APPROACH:
     1. SELECT 1 — customers: contact_name, city, literal 'Customer'.
     2. SELECT 2 — employees: CONCAT(first_name,' ',last_name), city,
        literal 'Employee' (CONCAT because employees split the name column).
     3. SELECT 3 — suppliers: contact_name, city, literal 'Supplier'.
     4. Three-way UNION combines all three and deduplicates; output column
        names (Name, City, Entity_Type) come from the first SELECT.
   MISTAKES I MADE:
     • 'employee' (lowercase) used instead of 'Employee' (title case) →
       case-sensitive comparison makes WHERE Entity_Type = 'Employee'
       return ZERO rows → fix: use 'Employee' to match the other branches.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (buggy: 'employee' should be 'Employee') ────
-- select c.contact_name as Name,
-- c.city,
-- 'Customer' as Entity_Type
-- from customers c
-- union
-- select concat(e.first_name,' ',e.last_name) as Name,
-- e.city,
-- 'employee' as Entity_Type
-- from employees e
-- Union
-- select s.contact_name as Name,
-- s.city,
-- 'Supplier' as Entity_Type
-- from suppliers s;

-- ── FINAL CORRECT SOLUTION (consistent capitalisation + ORDER BY) ────
SELECT c.contact_name AS Name, c.city, 'Customer' AS Entity_Type
FROM customers c
UNION
SELECT CONCAT(e.first_name,' ',e.last_name), e.city, 'Employee'
FROM employees e
UNION
SELECT s.contact_name, s.city, 'Supplier'
FROM suppliers s
ORDER BY Entity_Type, Name;
