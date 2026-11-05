/* =====================================================================
   Q206 · Product Pairs Frequently Bought Together
   Category : SELF JOIN (Market Basket Pairs)     Difficulty : Hard
   Concepts : Self join · Pair generation with a < b · GROUP BY · HAVING · Market basket analysis
   ---------------------------------------------------------------------
   PROBLEM : List product pairs that appear together in two or more orders, with both names and the number of shared orders, most frequent first.
   APPROACH:
     1. Self-join order_details a and b on the same order_id with b.product_id > a.product_id.
     2. Join products twice for the names.
     3. Group by the pair and keep pairs with COUNT(*) >= 2.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT a.product_id AS product_a, pa.product_name AS name_a,
       b.product_id AS product_b, pb.product_name AS name_b,
       COUNT(*)     AS orders_together
FROM order_details a
JOIN order_details b ON b.order_id = a.order_id AND b.product_id > a.product_id
JOIN products pa ON pa.product_id = a.product_id
JOIN products pb ON pb.product_id = b.product_id
GROUP BY a.product_id, pa.product_name, b.product_id, pb.product_name
HAVING COUNT(*) >= 2
ORDER BY orders_together DESC, product_a, product_b;
