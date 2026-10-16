/* =====================================================================
   Q73 · Supplier–Category Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause · company_name vs contact_name
   ---------------------------------------------------------------------
   PROBLEM : Every supplier paired with every product category
             (every supplier × every category).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only suppliers and categories.
     3. CROSS JOIN with no ON clause -> N × M = 29 × 8 = 232 rows.
     4. "Supplier Name" = company_name (not contact_name).
   MISTAKES I MADE:
     • Selected s.contact_name instead of s.company_name -> use s.company_name.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (wrong column — contact_name) ──────────────
-- SELECT s.contact_name, c.category_name FROM categories c CROSS JOIN suppliers s;

-- ── FINAL CORRECT SOLUTION ──────────────────────────────────────────
SELECT
    s.company_name AS supplier_name,
    c.category_name
FROM suppliers s
CROSS JOIN categories c;
