/* =====================================================================
   Q24 · Highest Revenue Product per Category (CTE + Window Function)
   Category : Common Table Expressions (CTEs)     Difficulty : Hard
   Concepts : CTE (multiple) · Window Functions (RANK) · PARTITION BY
              · GROUP BY · SUM · Tie Handling · INNER JOIN
   ---------------------------------------------------------------------
   PROBLEM : For every category, return the product(s) generating the
             highest revenue within that category, including all ties.
   APPROACH:
     1. CTE product_revenue: discounted revenue per product, keep category_id.
     2. CTE ranked: RANK() OVER (PARTITION BY category_id
        ORDER BY total_revenue DESC).
     3. Join ranked to categories for category_name; filter rnk = 1.
     4. ORDER BY category_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
    FROM products p
    JOIN order_details od ON od.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
ranked AS (
    SELECT
        pr.*,
        RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC) AS rnk
    FROM product_revenue pr
)
SELECT
    c.category_id,
    c.category_name,
    r.product_id,
    r.product_name,
    ROUND(r.total_revenue::numeric, 2) AS total_revenue
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.rnk = 1
ORDER BY c.category_id;
