/* =====================================================================
   Q16 · Customers Above Average Revenue (Correlated Subquery)
   Category : Correlated Subqueries     Difficulty : Medium
   Concepts : INNER JOIN (multi-table) · GROUP BY · HAVING · Subquery (non-correlated) · Aggregates (SUM, AVG)
   ---------------------------------------------------------------------
   PROBLEM : Return customers whose total revenue exceeds the average
             revenue across all customers, via a HAVING + subquery.
   APPROACH:
     1. Join customers, orders, order_details; aggregate discounted revenue per customer.
     2. In HAVING, compare that total against a subquery that independently
        recomputes revenue per customer and averages it.
     3. Sort by total revenue descending.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    cu.customer_id,
    cu.company_name,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY cu.customer_id, cu.company_name
HAVING SUM(od.unit_price * od.quantity * (1 - od.discount)) > (
    SELECT AVG(rev)
    FROM (
        SELECT SUM(od2.unit_price * od2.quantity * (1 - od2.discount)) AS rev
        FROM orders o2
        JOIN order_details od2 ON od2.order_id = o2.order_id
        GROUP BY o2.customer_id
    ) sub
)
ORDER BY total_revenue DESC;
