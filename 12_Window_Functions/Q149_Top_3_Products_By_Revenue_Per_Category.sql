/* =====================================================================
   Q149 · Top 3 Products By Revenue Per Category
   Category : Window Functions (Ranking + Filter)     Difficulty : Medium
   Concepts : DENSE_RANK · PARTITION BY · GROUP BY · SUM · CTE · Top-N per Group
   ---------------------------------------------------------------------
   PROBLEM : For each category, return the top 3 revenue positions (using DENSE_RANK), where revenue = unit_price * quantity * (1 - discount) from order_details.
   APPROACH:
     1. CTE product_revenue: sum net revenue per product (with its category_id).
     2. CTE ranked: DENSE_RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC).
     3. Filter revenue_rank <= 3, join categories for the name, and round.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH product_revenue AS (
    SELECT
        p.category_id,
        p.product_id,
        p.product_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM order_details od
    JOIN products p ON p.product_id = od.product_id
    GROUP BY p.category_id, p.product_id, p.product_name
),
ranked AS (
    SELECT
        pr.*,
        DENSE_RANK() OVER (PARTITION BY pr.category_id ORDER BY pr.revenue DESC) AS revenue_rank
    FROM product_revenue pr
)
SELECT
    c.category_name,
    r.revenue_rank,
    r.product_id,
    r.product_name,
    ROUND(r.revenue::numeric, 2) AS revenue
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.revenue_rank <= 3
ORDER BY category_name, revenue_rank, product_id;
