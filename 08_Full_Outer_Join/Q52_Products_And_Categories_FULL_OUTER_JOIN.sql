/* =====================================================================
   Q52 · Products and Categories (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Medium
   Concepts : FULL OUTER JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return the product name and category name for every product
             and every category — no product and no category excluded.
   APPROACH:
     1. FULL OUTER JOIN products to categories on category_id.
     2. Matched rows: product belongs to a category — both sides populated.
     3. Left-only rows: product with no matching category — category_name NULL.
     4. Right-only rows: category with no products — product_name NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   NOTE: UNION workaround (engines without FULL OUTER JOIN support):
     LEFT JOIN products → categories UNION RIGHT JOIN products → categories.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select p.product_name, c.category_name
from products p
full outer join categories c on c.category_id = p.category_id;
