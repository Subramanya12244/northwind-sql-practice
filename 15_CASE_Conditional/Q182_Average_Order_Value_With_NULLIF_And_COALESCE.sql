/* =====================================================================
   Q182 · Average Order Value With NULLIF And COALESCE
   Category : NULL Handling (COALESCE / NULLIF)     Difficulty : Medium
   Concepts : COALESCE · NULLIF · LEFT JOIN · Safe Division · COUNT DISTINCT
   ---------------------------------------------------------------------
   PROBLEM : For all customers in Germany, return order count, total net revenue (0 if none) and average order value (NULL if no orders), plus a status label.
   APPROACH:
     1. LEFT JOIN customers to orders and order_details so customers without orders stay.
     2. COUNT(DISTINCT o.order_id) and SUM net revenue.
     3. COALESCE(SUM(...), 0) for revenue; SUM(...) / NULLIF(COUNT(DISTINCT ...), 0) for the average.
     4. Label with CASE and order by customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    c.customer_id,
    c.company_name,
    COUNT(DISTINCT o.order_id)                                               AS order_count,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)), 0)::numeric, 2) AS total_revenue,
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount))
           / NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric, 2)             AS avg_order_value,
    CASE WHEN COUNT(o.order_id) = 0 THEN 'no orders' ELSE 'active' END       AS status
FROM customers c
LEFT JOIN orders o         ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id   = o.order_id
WHERE c.country = 'Germany'
GROUP BY c.customer_id, c.company_name
ORDER BY c.customer_id;
