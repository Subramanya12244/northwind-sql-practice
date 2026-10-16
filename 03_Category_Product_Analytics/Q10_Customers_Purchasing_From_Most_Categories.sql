/* =====================================================================
   Q10 · Customers Purchasing from Most Categories
   Category : Category & Product Analytics     Difficulty : Medium
   Concepts : INNER JOIN (multi-table) · GROUP BY · COUNT(DISTINCT) · ORDER BY · LIMIT
   ---------------------------------------------------------------------
   PROBLEM : Find the 10 customers who purchased from the highest number
             of distinct product categories (cross-sell breadth).
   APPROACH:
     1. Join customers -> orders -> order_details -> products.
     2. COUNT(DISTINCT p.category_id) per customer.
     3. GROUP BY customer.
     4. ORDER BY category_count DESC, LIMIT 10.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT p.category_id) AS category_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
JOIN products p ON p.product_id = od.product_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY category_count DESC
LIMIT 10;
