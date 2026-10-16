/* =====================================================================
   Q64 · Employees Having the Same Job Title
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · dedup (id < id)
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of employees sharing the same
             title, plus that title. No self/duplicate pairs.
   APPROACH:
     1. Self-join employees e1 to e2.
     2. ON e1.employee_id < e2.employee_id (dedup) AND e1.title = e2.title.
     3. Select both names and e1.title (already identical to e2.title).
   MISTAKES I MADE:
     • added an unnecessary third join (employees j) just to read the
       title → e1.title is already accessible once e1.title = e2.title
       is in the ON clause → redundant join removed.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (unnecessary third join) ────────────────────
-- SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
--        CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
--        j.title
-- FROM employees e1
-- JOIN employees e2
--     ON e1.employee_id < e2.employee_id
--     AND e1.title = e2.title
-- JOIN employees j
--     ON e1.employee_id = j.employee_id;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       e1.title
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND e1.title = e2.title;
