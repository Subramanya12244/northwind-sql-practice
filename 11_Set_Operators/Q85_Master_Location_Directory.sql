/* =====================================================================
   Q85 · Master Location Directory
   Category : Set Operators (UNION — dedup across sources)  Difficulty : Medium
   Concepts : UNION (three-way) · Set Operators · Deduplication across sources
   ---------------------------------------------------------------------
   PROBLEM : Return every unique city-country combination across customers,
             suppliers, and employees — each location appearing only once.
   APPROACH:
     1. SELECT city, country FROM customers.
     2. UNION SELECT city, country FROM suppliers.
     3. UNION SELECT city, country FROM employees.
     4. UNION (not UNION ALL) deduplicates the entire combined result at
        the row level — both city AND country must match to be a duplicate.
        No Entity_Type column (it would break location-level dedup).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT c.city,
       c.country
FROM customers c
UNION
SELECT s.city,
       s.country
FROM suppliers s
UNION
SELECT e.city,
       e.country
FROM employees e;
