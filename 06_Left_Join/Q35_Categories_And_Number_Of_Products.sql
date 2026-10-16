/* =====================================================================
   Q35 · Categories and Number of Products
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · GROUP BY · COUNT · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Number of products per category, with empty categories
             shown as 0.
   APPROACH:
     1. LEFT JOIN categories -> products on category_id (keep every category).
     2. COUNT(p.product_id) — not COUNT(*) — so empty categories return 0
        rather than 1 (the NULL-padded row would be counted by COUNT(*)).
     3. COUNT returns 0 for empty groups, so no COALESCE needed.
     4. GROUP BY category_name, category_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.category_name,
count(p.product_id) as total_products
from categories c
left join products p on p.category_id = c.category_id
group by c.category_name, c.category_id;
