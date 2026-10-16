/* =====================================================================
   Q25 · Customers and Order Count
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN · GROUP BY · COUNT · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Every customer and their order count, with zero-order
             customers shown as 0 rather than excluded.
   APPROACH:
     1. LEFT JOIN customers -> orders on customer_id (keep every customer).
     2. COUNT(o.order_id) — counts the joined column, so no-order
        customers correctly show 0 (not COUNT(*), which would show 1).
     3. GROUP BY customer; ORDER BY order_count DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(o.order_id) AS order_count
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC;
