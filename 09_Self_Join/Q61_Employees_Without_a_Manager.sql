/* =====================================================================
   Q61 · Employees Without a Manager
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · LEFT JOIN · NULL handling (anti-join)
   ---------------------------------------------------------------------
   PROBLEM : Return the full name of every employee who has no manager
             assigned (their reports_to is NULL / matches no manager).
   APPROACH:
     1. LEFT JOIN employees (e) to employees (m) on e.reports_to = m.employee_id.
     2. Keep every employee row so non-matches surface as NULL on m.*.
     3. Filter for employees with no manager match.
   MISTAKES I MADE:
     • none — clean on first attempt
       (optimal filters on m.employee_id IS NULL — more robust anti-join)
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct on this dataset) ───────────────────
-- SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name
-- FROM employees e
-- LEFT JOIN employees m
--     ON e.reports_to = m.employee_id
-- WHERE e.reports_to IS NULL;

-- ── FINAL CORRECT SOLUTION (robust anti-join on joined PK) ───────────
SELECT CONCAT(e.first_name,' ',e.last_name) AS employee_name
FROM employees e
LEFT JOIN employees m
    ON e.reports_to = m.employee_id
WHERE m.employee_id IS NULL;
