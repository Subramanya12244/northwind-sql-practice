/* =====================================================================
   Q65 · Employees Hired in the Same Year
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · date functions (EXTRACT) · dedup
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of employees hired in the same
             year, plus that year. No self/duplicate pairs.
   APPROACH:
     1. Self-join employees e1 to e2.
     2. Compare EXTRACT(YEAR FROM hire_date) on both sides.
     3. Keep e1.employee_id < e2.employee_id to dedup.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       EXTRACT(YEAR FROM e1.hire_date) AS hire_year
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date);
