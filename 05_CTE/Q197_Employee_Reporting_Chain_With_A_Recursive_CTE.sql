/* =====================================================================
   Q197 · Employee Reporting Chain With A Recursive CTE
   Category : Common Table Expressions (Recursive Hierarchy)     Difficulty : Hard
   Concepts : WITH RECURSIVE · Anchor + recursive member · UNION ALL · Depth · Path building
   ---------------------------------------------------------------------
   PROBLEM : Return every employee with their depth below the top manager (0 for the top) and the full path of names from the top, sorted so each manager is followed by their team.
   APPROACH:
     1. Anchor: employees with no manager, depth 0, path = their name.
     2. Recursive member: join employees to the previous level on reports_to, depth + 1, path || ' > ' || name.
     3. Order by path so the tree reads top-down.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH RECURSIVE chain AS (
    SELECT employee_id, first_name, last_name, reports_to,
           0 AS depth,
           (first_name || ' ' || last_name)::text AS path
    FROM employees
    WHERE reports_to IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.reports_to,
           ch.depth + 1,
           ch.path || ' > ' || e.first_name || ' ' || e.last_name
    FROM employees e
    JOIN chain ch ON e.reports_to = ch.employee_id
)
SELECT employee_id, first_name, last_name, depth, path
FROM chain
ORDER BY path;
