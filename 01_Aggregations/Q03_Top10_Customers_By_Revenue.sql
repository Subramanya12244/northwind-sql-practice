/* =====================================================================
   Q03 · Top 10 Customers by Revenue
   Category : Aggregations & Revenue Analysis     Difficulty : Easy
   Concepts : INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Top 10 customers by total discounted revenue.
   APPROACH:
     1. customers -> orders (customer_id) -> order_details (order_id).
     2. SUM revenue grouped by customer.
     3. ORDER BY revenue DESC, then LIMIT 10.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY total_revenue DESC
LIMIT 10;
