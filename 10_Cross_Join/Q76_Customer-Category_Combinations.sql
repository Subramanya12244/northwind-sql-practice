/* =====================================================================
   Q76 · Customer–Category Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause
   ---------------------------------------------------------------------
   PROBLEM : Every customer paired with every product category
             (every customer × every category).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only customers and categories.
     3. CROSS JOIN with no ON clause -> N × M = 91 × 8 = 728 rows.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select cu.contact_name, c.category_name
from customers cu
cross join categories c;
