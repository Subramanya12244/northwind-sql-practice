/* =====================================================================
   Q63 · Employees Reporting to the Same Manager
   Category : Self Join          Difficulty : Medium
   Concepts : SELF JOIN (triple alias) · INNER JOIN · dedup (id < id)
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of employees sharing the same
             reports_to, plus their manager's name. No self/duplicate pairs.
   APPROACH:
     1. Three aliases: e1, e2 (the peers), m (their shared manager).
     2. Join e1-e2 on e1.reports_to = e2.reports_to.
     3. Join m on m.employee_id = e1.reports_to for the manager name.
     4. Keep e1.employee_id < e2.employee_id to dedup.
   MISTAKES I MADE:
     • Attempt 1: showed e1 as the manager_name → e1 is an employee;
       need a third alias m joined on m.employee_id = e1.reports_to.
     • Attempt 2: joined m on m.employee_id = e1.employee_id → makes
       manager = employee 1; correct is m.employee_id = e1.reports_to.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT 1 (manager shown as employee 1) ─────────────
-- SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
--        CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
--        CONCAT(e1.first_name,' ',e1.last_name) AS manager_name
-- FROM employees e1
-- JOIN employees e2
--     ON e1.reports_to = e2.reports_to
--     AND e1.employee_id < e2.employee_id;

-- ── MY SUBMITTED ATTEMPT 2 (manager joined on wrong column) ──────────
-- SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
--        CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
--        CONCAT(m.first_name,' ',m.last_name)   AS manager_name
-- FROM employees e1
-- JOIN employees e2
--     ON e1.reports_to = e2.reports_to
-- JOIN employees m
--     ON m.employee_id = e1.employee_id
--     AND e1.employee_id < e2.employee_id;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       CONCAT(m.first_name,' ',m.last_name)   AS manager_name
FROM employees e1
JOIN employees e2
    ON e1.reports_to = e2.reports_to
JOIN employees m
    ON m.employee_id = e1.reports_to
WHERE e1.employee_id < e2.employee_id;
