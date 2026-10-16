/* =====================================================================
   Q62 · Employees Who Are Managers
   Category : Self Join          Difficulty : Medium
   Concepts : SELF JOIN · LEFT JOIN · GROUP BY · HAVING · COUNT · DISTINCT
   ---------------------------------------------------------------------
   PROBLEM : Return the full name of every employee who appears in at
             least one other employee's reports_to field.
   APPROACH:
     1. Join employees e (managed) to employees m (managers)
        on e.reports_to = m.employee_id.
     2. GROUP BY the manager, keep those with >= 1 direct report.
   MISTAKES I MADE:
     • counted COUNT(e.reports_to) (the FK column) instead of
       COUNT(e.employee_id) (the subordinate entity) → correct result
       but imprecise → count the employee, not the reference column.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct result, imprecise COUNT) ───────────
-- SELECT CONCAT(m.first_name,' ',m.last_name) AS employee_name
-- FROM employees e
-- LEFT JOIN employees m
--     ON e.reports_to = m.employee_id
-- GROUP BY m.first_name, m.last_name
-- HAVING COUNT(e.reports_to) > 0;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT CONCAT(m.first_name,' ',m.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
GROUP BY m.first_name, m.last_name
HAVING COUNT(e.employee_id) > 0;
