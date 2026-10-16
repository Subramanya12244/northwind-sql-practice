/* =====================================================================
   Q68 · Products with the Same Supplier
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · dedup (id < id)
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of products sharing the same
             supplier_id, plus that supplier ID. No self/duplicate pairs.
   APPROACH:
     1. Self-join products p1 to p2.
     2. ON p1.product_id < p2.product_id (dedup)
        AND p1.supplier_id = p2.supplier_id (same supplier).
   MISTAKES I MADE:
     • omitted AND p1.supplier_id = p2.supplier_id → id < id alone only
       deduplicates, producing a Cartesian product → add the same-supplier
       condition.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (missing same-supplier → Cartesian product) ──
-- SELECT p1.product_name AS product_1_name,
--        p2.product_name AS product_2_name,
--        p1.supplier_id
-- FROM products p1
-- JOIN products p2
--     ON p1.product_id < p2.product_id;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       p1.supplier_id
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id
    AND p1.supplier_id = p2.supplier_id;
