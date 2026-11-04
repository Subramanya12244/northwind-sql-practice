/* =====================================================================
   Q115 · Employee Age At Hire And Tenure
   Category : Date & Time (AGE & Intervals)          Difficulty : Medium
   Concepts : AGE() · EXTRACT from INTERVAL · DATE Subtraction · Fixed Reference Date
   ---------------------------------------------------------------------
   PROBLEM : Return each employee's age at hire, tenure in completed years and tenure in days as of 1998-12-31.
   APPROACH:
     1. AGE(hire_date, birth_date) gives an interval in years/months/days; extract YEAR for completed years.
     2. AGE(DATE '1998-12-31', hire_date) for tenure years.
     3. DATE '1998-12-31' - hire_date for tenure in days.
     4. Sort youngest hire first, tie-break on employee_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.birth_date,
    e.hire_date,
    EXTRACT(YEAR FROM AGE(e.hire_date, e.birth_date))::int AS age_at_hire,
    EXTRACT(YEAR FROM AGE(DATE '1998-12-31', e.hire_date))::int AS tenure_years,
    (DATE '1998-12-31' - e.hire_date) AS tenure_days
FROM employees e
WHERE e.birth_date IS NOT NULL
  AND e.hire_date IS NOT NULL
ORDER BY age_at_hire, employee_id;
