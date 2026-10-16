/* =====================================================================
   Q70 · Customers Sharing the Same Postal Code
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · dedup (id < id)
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of customers sharing the same
             postal code, plus that code. No self/duplicate pairs.
   APPROACH:
     1. Self-join customers c1 to c2.
     2. ON c1.customer_id < c2.customer_id (dedup)
        AND c1.postal_code = c2.postal_code (same code).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT c1.contact_name,
       c2.contact_name,
       c1.postal_code
FROM customers c1
JOIN customers c2
    ON c1.customer_id < c2.customer_id
    AND c1.postal_code = c2.postal_code;
