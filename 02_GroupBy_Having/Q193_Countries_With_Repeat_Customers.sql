/* =====================================================================
   Q193 · Countries With Repeat Customers
   Category : GROUP BY & HAVING (Two-Level Aggregation)     Difficulty : Medium
   Concepts : CTE · Two-level GROUP BY · COUNT FILTER · HAVING · Percentages
   ---------------------------------------------------------------------
   PROBLEM : For each country, count customers who ordered at all, how many of them ordered at least twice, and the repeat share in percent (1 dp). Only list countries with at least one repeat customer, highest share first.
   APPROACH:
     1. CTE: orders per customer (customer_id, country, COUNT).
     2. Outer query: group the CTE by country.
     3. COUNT(*) FILTER (WHERE order_count >= 2) gives repeat customers; HAVING keeps countries with at least one.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH customer_orders AS (
    SELECT c.customer_id, c.country, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT country,
       COUNT(*)                                    AS ordering_customers,
       COUNT(*) FILTER (WHERE order_count >= 2)    AS repeat_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE order_count >= 2) / COUNT(*), 1) AS repeat_pct
FROM customer_orders
GROUP BY country
HAVING COUNT(*) FILTER (WHERE order_count >= 2) >= 1
ORDER BY repeat_pct DESC, country;
