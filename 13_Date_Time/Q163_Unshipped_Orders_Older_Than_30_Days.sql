/* =====================================================================
   Q163 · Unshipped Orders Older Than 30 Days
   Category : Date & Time (Aging with Fixed Reference Date)          Difficulty : Medium
   Concepts : NULL Filtering · DATE ± Integer · Fixed Reference Date · Boolean Expression
   ---------------------------------------------------------------------
   PROBLEM : Return unshipped orders with order_date more than 30 days before 1998-12-31, with days open and an overdue flag.
   APPROACH:
     1. Filter shipped_date IS NULL.
     2. Keep rows where order_date < DATE '1998-12-31' - 30.
     3. Compute days_open and a boolean past_required_date.
     4. Sort oldest first (days_open DESC), tie-break on order_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.required_date,
    (DATE '1998-12-31' - o.order_date) AS days_open,
    (DATE '1998-12-31' > o.required_date) AS past_required_date
FROM orders o
WHERE o.shipped_date IS NULL
  AND o.order_date < DATE '1998-12-31' - 30
ORDER BY days_open DESC, order_id;
