/* =====================================================================
   Q105 · Customer Share Of Total Revenue
   Category : Window Functions (Aggregate Windows)     Difficulty : Medium
   Concepts : SUM() OVER () · Percent of Total · GROUP BY · CTE
   ---------------------------------------------------------------------
   PROBLEM : For each customer, return their net revenue, the company-wide total, and their share as a percentage (2 dp), largest first.
   APPROACH:
     1. CTE customer_revenue: net revenue per customer.
     2. Outer query: SUM(revenue) OVER () gives the grand total on every row.
     3. Share = 100.0 * revenue / SUM(revenue) OVER (); round and order by share descending, then customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.customer_id
)
SELECT
    cr.customer_id,
    c.company_name,
    ROUND(cr.revenue::numeric, 2) AS customer_revenue,
    ROUND((SUM(cr.revenue) OVER ())::numeric, 2) AS total_revenue,
    ROUND((100.0 * cr.revenue / SUM(cr.revenue) OVER ())::numeric, 2) AS revenue_share_pct
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
ORDER BY revenue_share_pct DESC, customer_id;
