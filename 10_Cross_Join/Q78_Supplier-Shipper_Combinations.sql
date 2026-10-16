/* =====================================================================
   Q78 · Supplier–Shipper Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause · company_name vs contact_name
   ---------------------------------------------------------------------
   PROBLEM : Every supplier paired with every shipper
             (every supplier × every shipper).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only suppliers and shippers.
     3. CROSS JOIN with no ON clause -> N × M = 29 × 3 = 87 rows.
     4. "Supplier Name" = company_name (not contact_name).
   MISTAKES I MADE:
     • Submitted s.contact_name instead of s.company_name -> use s.company_name.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (wrong column — contact_name) ──────────────
-- select s.contact_name, sh.company_name from shippers sh cross join suppliers s

-- ── FINAL CORRECT SOLUTION ──────────────────────────────────────────
SELECT
    s.company_name AS supplier_name,
    sh.company_name AS shipper_name
FROM suppliers s
CROSS JOIN shippers sh;
