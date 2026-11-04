/* =====================================================================
   Q183 · Customer Value Segment Summary
   Category : CASE Expressions (Segmentation)     Difficulty : Hard
   Concepts : CASE Segmentation · LEFT JOIN · COALESCE · CTE · CASE in ORDER BY · Window SUM
   ---------------------------------------------------------------------
   PROBLEM : Segment all customers by total net revenue and return per segment: customer count, total revenue, average revenue per customer and share of total revenue (%), ordered High, Medium, Low, Inactive.
   APPROACH:
     1. CTE cust_rev: LEFT JOIN customers to orders/order_details and COALESCE(SUM(...), 0) per customer.
     2. CTE seg: bucket revenue with CASE (Inactive when 0).
     3. Group by segment; compute share with SUM(SUM(revenue)) OVER ().
     4. Order with a CASE mapping segments to 1–4.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH cust_rev AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)), 0) AS revenue
    FROM customers c
    LEFT JOIN orders o         ON o.customer_id = c.customer_id
    LEFT JOIN order_details od ON od.order_id   = o.order_id
    GROUP BY c.customer_id
),
seg AS (
    SELECT
        customer_id,
        revenue,
        CASE
            WHEN revenue >= 5000 THEN 'High'
            WHEN revenue >= 1000 THEN 'Medium'
            WHEN revenue >  0    THEN 'Low'
            ELSE 'Inactive'
        END AS segment
    FROM cust_rev
)
SELECT
    segment,
    COUNT(*)                                                         AS customers,
    ROUND(SUM(revenue)::numeric, 2)                                  AS segment_revenue,
    ROUND(AVG(revenue)::numeric, 2)                                  AS avg_revenue,
    ROUND((100 * SUM(revenue) / SUM(SUM(revenue)) OVER ())::numeric, 1) AS revenue_share_pct
FROM seg
GROUP BY segment
ORDER BY CASE segment
             WHEN 'High'     THEN 1
             WHEN 'Medium'   THEN 2
             WHEN 'Low'      THEN 3
             ELSE 4
         END;
