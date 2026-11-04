/* =====================================================================
   Q112 · Late Shipments With Days Late
   Category : Date & Time (Date Arithmetic)          Difficulty : Easy
   Concepts : DATE Subtraction · NULL Filtering · Comparison
   ---------------------------------------------------------------------
   PROBLEM : Return all shipped orders where shipped_date > required_date, with the number of days late.
   APPROACH:
     1. Keep only orders with a non-NULL shipped_date.
     2. Filter shipped_date > required_date.
     3. Compute shipped_date - required_date as days_late.
     4. Sort by days_late DESC, then order_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    (o.shipped_date - o.required_date) AS days_late
FROM orders o
WHERE o.shipped_date IS NOT NULL
  AND o.shipped_date > o.required_date
ORDER BY days_late DESC, order_id;
