/* =====================================================================
   Q169 · Employee Full Name And Initials
   Category : String Functions (Concatenation + Case)     Difficulty : Easy
   Concepts : || Concatenation · CONCAT · UPPER · LOWER · LEFT
   ---------------------------------------------------------------------
   PROBLEM : For every employee, return the full name (first_name last_name), upper-case initials, and the last name in lower case.
   APPROACH:
     1. Concatenate first_name || ' ' || last_name for the full name.
     2. Take LEFT(..., 1) of each name, concatenate and wrap in UPPER().
     3. Apply LOWER(last_name) and order by employee_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    employee_id,
    first_name || ' ' || last_name                    AS full_name,
    UPPER(LEFT(first_name, 1) || LEFT(last_name, 1))  AS initials,
    LOWER(last_name)                                  AS login_stem
FROM employees
ORDER BY employee_id;
