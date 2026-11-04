/* =====================================================================
   Q155 · Customer Revenue Quartiles
   Category : Window Functions (Distribution)     Difficulty : Medium
   Concepts : NTILE · Bucketing · GROUP BY · CTE
   ---------------------------------------------------------------------
   PROBLEM : Assign every customer to a revenue quartile (1 = highest revenue) using NTILE(4).
   APPROACH:
     1. CTE customer_revenue: net revenue per customer.
     2. NTILE(4) OVER (ORDER BY revenue DESC, customer_id) to bucket customers.
     3. Join customers; order by quartile, revenue descending, customer_id.
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
    NTILE(4) OVER (ORDER BY cr.revenue DESC, cr.customer_id) AS revenue_quartile
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
ORDER BY revenue_quartile, customer_revenue DESC, customer_id;
