/* =====================================================================
   Q162 · Average Days To Ship Per Shipper
   Category : Date & Time (Lead-Time Analysis)          Difficulty : Medium
   Concepts : DATE Subtraction · AVG · MAX · JOIN · NULL Exclusion · ROUND
   ---------------------------------------------------------------------
   PROBLEM : Per shipper, return shipped order count, average and maximum days between order_date and shipped_date.
   APPROACH:
     1. Join shippers to orders on ship_via = shipper_id.
     2. Filter shipped_date IS NOT NULL.
     3. Aggregate COUNT, AVG and MAX of shipped_date - order_date.
     4. Round the average and sort fastest first, tie-break on shipper_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    s.shipper_id,
    s.company_name,
    COUNT(o.order_id)                                         AS shipped_orders,
    ROUND(AVG(o.shipped_date - o.order_date)::numeric, 2)     AS avg_days_to_ship,
    MAX(o.shipped_date - o.order_date)                        AS max_days_to_ship
FROM shippers s
JOIN orders o ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.shipper_id, s.company_name
ORDER BY avg_days_to_ship, shipper_id;
