/* =====================================================================
   Q77 · Product–Employee Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Every product paired with every employee
             (every product × every employee).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only products and employees.
     3. CROSS JOIN with no ON clause -> N × M = 77 × 9 = 693 rows.
     4. Build employee_name with CONCAT(first_name,' ',last_name).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select p.product_name,
concat(e.first_name,' ',e.last_name) as employee_name
from employees e
cross join products p;
