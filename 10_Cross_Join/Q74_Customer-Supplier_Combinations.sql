/* =====================================================================
   Q74 · Customer–Supplier Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause
   ---------------------------------------------------------------------
   PROBLEM : Every customer paired with every supplier
             (every customer × every supplier).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only customers and suppliers (no FK relationship exists).
     3. CROSS JOIN with no ON clause -> N × M = 91 × 29 = 2,639 rows.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.contact_name AS customer_name,
    s.company_name AS supplier_name
FROM customers cu
CROSS JOIN suppliers s;
