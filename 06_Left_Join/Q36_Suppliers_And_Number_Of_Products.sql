/* =====================================================================
   Q36 · Suppliers and Number of Products
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · GROUP BY · COUNT · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Number of products per supplier, with suppliers who supply
             nothing shown as 0.
   APPROACH:
     1. LEFT JOIN suppliers -> products on supplier_id (keep every supplier).
     2. COUNT(p.product_id) — not COUNT(*) — so no-product suppliers
        return 0 rather than 1.
     3. COUNT returns 0 for empty groups, so no COALESCE needed.
     4. GROUP BY company_name, supplier_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select s.company_name,
count(p.product_id) as total_products
from suppliers s
left join products p on p.supplier_id = s.supplier_id
group by s.company_name, s.supplier_id;
