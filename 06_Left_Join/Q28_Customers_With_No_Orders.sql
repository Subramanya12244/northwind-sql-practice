/* =====================================================================
   Q28 · Customers with No Orders
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
   ---------------------------------------------------------------------
   PROBLEM : List only customers who have never placed an order.
   APPROACH:
     1. LEFT JOIN customers -> orders on customer_id (keep every customer).
     2. Keep rows where o.order_id IS NULL (no matching order at all).
     3. Alternative shown below: NOT EXISTS (often faster, NULL-safe).
        Avoid NOT IN — a single NULL in the subquery empties the result.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;

-- Equivalent, often better-performing alternative using NOT EXISTS:
-- SELECT
--     cu.customer_id,
--     cu.company_name
-- FROM customers cu
-- WHERE NOT EXISTS (
--     SELECT 1 FROM orders o WHERE o.customer_id = cu.customer_id
-- );
