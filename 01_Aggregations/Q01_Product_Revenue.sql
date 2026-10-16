/* =====================================================================
   Q01 · Product Revenue
   Category : Aggregations & Revenue Analysis     Difficulty : Easy
   Concepts : INNER JOIN · GROUP BY · SUM · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Total discounted revenue per product
             (unit_price * quantity * (1 - discount), summed per product).
   APPROACH:
     1. Join products -> order_details on product_id.
     2. Compute per-line revenue, SUM() grouped by product.
     3. ROUND to 2 dp; ORDER BY revenue DESC.
   MISTAKES I MADE:
     • none recorded
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM products p
JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;
