/* =====================================================================
   Q15 · Customers Above Average Orders (Correlated Subquery)
   Category : Correlated Subqueries     Difficulty : Medium
   Concepts : INNER JOIN · GROUP BY · HAVING · Subquery (non-correlated) · Aggregates (COUNT, AVG)
   ---------------------------------------------------------------------
   PROBLEM : Return customers whose order count exceeds the average order
             count across all customers, via a subquery inside HAVING.
   APPROACH:
     1. Join customers -> orders and COUNT orders per customer.
     2. In HAVING, compare that count against a subquery computing AVG(order_count).
     3. Aggregates can't nest, so that subquery wraps a derived table that first
        computes COUNT(order_id) GROUP BY customer_id.
     4. Sort by order count descending.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        GROUP BY customer_id
    ) sub
)
ORDER BY order_count DESC;
