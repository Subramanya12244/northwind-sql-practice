/* =====================================================================
   Q26 · Customers and Latest Order Date
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN · GROUP BY · MAX · NULL Handling · ORDER BY NULLS
   ---------------------------------------------------------------------
   PROBLEM : Every customer and their most recent order date, with NULL
             for customers who have never ordered.
   APPROACH:
     1. LEFT JOIN customers -> orders on customer_id.
     2. MAX(o.order_date) — returns NULL naturally for no-order customers.
     3. GROUP BY customer.
     4. ORDER BY latest_order_date DESC NULLS LAST (keep never-ordered last).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    MAX(o.order_date) AS latest_order_date
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY latest_order_date DESC NULLS LAST;
