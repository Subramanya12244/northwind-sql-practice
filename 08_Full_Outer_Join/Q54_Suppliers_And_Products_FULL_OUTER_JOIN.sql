/* =====================================================================
   Q54 · Suppliers and Products (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Medium
   Concepts : FULL OUTER JOIN · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Return the supplier name and product name for every supplier
             and every product — no supplier and no product excluded.
   APPROACH:
     1. FULL OUTER JOIN suppliers to products on supplier_id.
     2. Matched rows: supplier-product pair linked — both sides populated.
     3. Left-only rows: supplier with no products — product_name NULL.
     4. Right-only rows: product with no supplier — company_name NULL.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   NOTE: Same structural template across Q51-Q54:
     SELECT <display_A>, <display_B>
     FROM <table_A> FULL OUTER JOIN <table_B> ON <shared_key>;
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select s.company_name, p.product_name
from suppliers s
full outer join products p on p.supplier_id = s.supplier_id;
