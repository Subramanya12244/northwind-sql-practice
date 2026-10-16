/* =====================================================================
   Q79 · Customer and Supplier Contact Directory
   Category : Set Operators (UNION)     Difficulty : Easy
   Concepts : UNION · Set Operators
   ---------------------------------------------------------------------
   PROBLEM : Return one unified list of contact names from customers
             and suppliers combined, with duplicates removed.
   APPROACH:
     1. SELECT contact_name FROM customers — all customer contacts.
     2. UNION SELECT contact_name FROM suppliers — all supplier contacts.
     3. UNION (not UNION ALL) removes duplicate names across both tables.
     4. Both SELECTs return one compatible column (varchar) — UNION rules met.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name from customers c
union
select s.contact_name from suppliers s;
