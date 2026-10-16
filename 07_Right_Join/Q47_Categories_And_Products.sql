/* =====================================================================
   Q47 · Categories and Products
   Category : RIGHT JOIN          Difficulty : Easy
   Concepts : RIGHT JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return all products with their category name, preserving
             every product even if it has no matching category (NULL if none).
   APPROACH:
     1. Place categories on the LEFT, products on the RIGHT.
     2. RIGHT JOIN preserves every product regardless of a matching category.
     3. For unmatched products, category_name is NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_name,
    c.category_name
FROM categories c
RIGHT JOIN products p
    ON p.category_id = c.category_id;
