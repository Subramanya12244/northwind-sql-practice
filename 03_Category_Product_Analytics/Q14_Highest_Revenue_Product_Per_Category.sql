/* =====================================================================
   Q14 · Highest Revenue Product per Category
   Category : Category & Product Analytics     Difficulty : Hard
   Concepts : CTE · Window Functions (RANK) · PARTITION BY · GROUP BY · SUM · Tie Handling
   ---------------------------------------------------------------------
   PROBLEM : For each category, return the product(s) with the highest
             revenue, including all products tied for first place.
   APPROACH:
     1. CTE product_revenue: SUM discounted revenue per product, keep category_id.
     2. CTE ranked: RANK() OVER (PARTITION BY category_id ORDER BY total_revenue DESC).
     3. Filter rnk = 1 (surfaces all ties).
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
    category_id,
    product_id,
    product_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue
FROM ranked
WHERE rnk = 1
ORDER BY category_id;
