/* =====================================================================
   Q75 · Employee–Shipper Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Every employee paired with every shipper
             (every employee × every shipper).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only employees and shippers.
     3. CROSS JOIN with no ON clause -> N × M = 9 × 3 = 27 rows.
     4. Build employee_name with CONCAT(first_name,' ',last_name).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select concat(e.first_name,' ',e.last_name) as employee_name,
s.company_name
from employees e
cross join shippers s;
