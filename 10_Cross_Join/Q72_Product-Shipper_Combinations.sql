/* =====================================================================
   Q72 · Product–Shipper Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause
   ---------------------------------------------------------------------
   PROBLEM : Every product paired with every shipper
             (every product × every shipper).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only products and shippers (no direct relationship exists).
     3. CROSS JOIN with no ON clause -> N × M = 77 × 3 = 231 rows.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_name,
    sh.company_name
FROM products p
CROSS JOIN shippers sh;
