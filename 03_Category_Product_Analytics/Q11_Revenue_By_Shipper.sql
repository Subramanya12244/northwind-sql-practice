/* =====================================================================
   Q11 · Revenue by Shipper
   Category : Category & Product Analytics     Difficulty : Easy
   Concepts : INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY
   ---------------------------------------------------------------------
   PROBLEM : Total discounted order revenue handled by each shipping company.
   APPROACH:
     1. Join shippers -> orders on ship_via = shipper_id.
     2. Join orders -> order_details for line-item revenue.
     3. SUM(unit_price * quantity * (1 - discount)) per shipper.
     4. ORDER BY total_revenue DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    s.shipper_id,
    s.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM shippers s
JOIN orders o ON o.ship_via = s.shipper_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY s.shipper_id, s.company_name
ORDER BY total_revenue DESC;
