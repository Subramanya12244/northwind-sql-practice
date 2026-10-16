/* =====================================================================
   Q67 · Customers from the Same City
   Category : Self Join          Difficulty : Easy
   Concepts : SELF JOIN · INNER JOIN · dedup (id < id)
   ---------------------------------------------------------------------
   PROBLEM : Return every unique pair of customers sharing the same
             city, plus that city. No self/duplicate pairs.
   APPROACH:
     1. Self-join customers c1 to c2 (reuse the Q66 template).
     2. ON c1.customer_id < c2.customer_id (dedup) AND c1.city = c2.city.
     3. Select both names and c1.city.
   MISTAKES I MADE:
     • join condition correct, but SELECT showed c1.country instead of
       c1.city (copy-paste from Q66) → right rows, wrong column → select city.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (wrong SELECT column: country, not city) ─────
-- SELECT c1.contact_name AS customer_1_name,
--        c2.contact_name AS customer_2_name,
--        c1.country
-- FROM customers c1
-- JOIN customers c2
--     ON c1.customer_id < c2.customer_id
--     AND c1.city = c2.city;

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
SELECT c1.contact_name AS customer_1_name,
       c2.contact_name AS customer_2_name,
       c1.city
FROM customers c1
JOIN customers c2
    ON c1.customer_id < c2.customer_id
    AND c1.city = c2.city;
