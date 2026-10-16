/* =====================================================================
   Q29 · Products Never Ordered
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
   ---------------------------------------------------------------------
   PROBLEM : List only products that have never appeared in any order.
   APPROACH:
     1. LEFT JOIN products -> order_details on product_id (keep every product).
     2. Keep rows where od.order_id IS NULL (no matching line item at all).
     3. Alternative shown below: NOT EXISTS (equally valid, often faster).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.order_id IS NULL;

-- Equivalent alternative using NOT EXISTS:
-- SELECT
--     p.product_id,
--     p.product_name
-- FROM products p
-- WHERE NOT EXISTS (
--     SELECT 1 FROM order_details od WHERE od.product_id = p.product_id
-- );
