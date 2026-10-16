/* =====================================================================
   Q81 · Company Name Directory
   Category : Set Operators (UNION — three-way)     Difficulty : Easy
   Concepts : UNION (three-way) · Set Operators
   ---------------------------------------------------------------------
   PROBLEM : Return one unified list of company names from customers,
             suppliers, and shippers combined, with duplicates removed.
   APPROACH:
     1. SELECT company_name FROM customers — 91 customer company names.
     2. UNION SELECT company_name FROM suppliers — 29 supplier names.
     3. UNION SELECT company_name FROM shippers — 3 shipper names.
     4. UNION deduplicates across the ENTIRE combined result (not pairwise).
     5. All three tables share column company_name — no aliasing needed.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT company_name
FROM customers
UNION
SELECT company_name
FROM suppliers
UNION
SELECT company_name
FROM shippers;
