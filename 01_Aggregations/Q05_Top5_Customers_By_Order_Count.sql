/* =====================================================================
   Q05 · Top 5 Customers by Number of Orders
   Category : Aggregations & Revenue Analysis     Difficulty : Easy
   Concepts : INNER JOIN · GROUP BY · COUNT · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Top 5 customers by number of distinct orders placed.
   APPROACH:
     1. customers -> orders (customer_id).
     2. COUNT(DISTINCT order_id) grouped by customer.
     3. ORDER BY order_count DESC, then LIMIT 5.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC
LIMIT 5;
