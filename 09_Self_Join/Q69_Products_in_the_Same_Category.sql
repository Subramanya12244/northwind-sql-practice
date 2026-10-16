/* =====================================================================
   Q69 · Products in the Same Category
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · LEFT JOIN (name lookup) · dedup
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of products sharing the same
             category_id, plus the category name. No self/duplicate pairs.
   APPROACH:
     1. Self-join products p1 to p2.
     2. ON p1.product_id < p2.product_id (dedup)
        AND p1.category_id = p2.category_id (same category).
     3. LEFT JOIN categories on p1.category_id for the category name.
   MISTAKES I MADE:
     • omitted AND p1.category_id = p2.category_id → Cartesian product
       (same as Q68) → add the same-category condition.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (missing same-category → Cartesian product) ──
-- SELECT p1.product_name AS product_1_name,
--        p2.product_name AS product_2_name,
--        c.category_name
-- FROM products p1
-- JOIN products p2
--     ON p1.product_id < p2.product_id
-- LEFT JOIN categories c ON c.category_id = p1.category_id;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT p1.product_name AS product_1_name,
       p2.product_name AS product_2_name,
       c.category_name
FROM products p1
JOIN products p2
    ON p1.product_id < p2.product_id
    AND p1.category_id = p2.category_id
LEFT JOIN categories c ON c.category_id = p1.category_id;
