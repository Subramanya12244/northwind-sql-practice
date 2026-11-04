/* =====================================================================
   Q179 · Employee Shipping Status Counts
   Category : Conditional Aggregation     Difficulty : Medium
   Concepts : COUNT FILTER · SUM(CASE) · Conditional Aggregation · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : For each employee, count total orders, on-time shipments, late shipments (shipped after the required date) and unshipped orders.
   APPROACH:
     1. Join employees to orders.
     2. Use COUNT(*) FILTER (WHERE ...) for on-time and late.
     3. Use SUM(CASE WHEN shipped_date IS NULL THEN 1 ELSE 0 END) for unshipped (to show both styles).
     4. Group by employee and order by employee_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name                                     AS employee_name,
    COUNT(*)                                                               AS total_orders,
    COUNT(*) FILTER (WHERE o.shipped_date <= o.required_date)              AS on_time,
    COUNT(*) FILTER (WHERE o.shipped_date >  o.required_date)              AS late,
    SUM(CASE WHEN o.shipped_date IS NULL THEN 1 ELSE 0 END)                AS unshipped
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY e.employee_id;
