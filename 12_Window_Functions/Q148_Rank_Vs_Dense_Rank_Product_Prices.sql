/* =====================================================================
   Q148 · Rank Vs Dense Rank Product Prices
   Category : Window Functions (Ranking)     Difficulty : Easy
   Concepts : RANK · DENSE_RANK · PARTITION BY · Tie Handling
   ---------------------------------------------------------------------
   PROBLEM : For each product, show its price rank within its category using both RANK() and DENSE_RANK() (highest price = 1).
   APPROACH:
     1. Join products to categories.
     2. Compute RANK() and DENSE_RANK() over the same window: PARTITION BY category_id ORDER BY unit_price DESC.
     3. Sort by category, rank, then product_id as the tie-breaker.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    c.category_name,
    p.product_id,
    p.product_name,
    p.unit_price,
    RANK()       OVER (PARTITION BY c.category_id ORDER BY p.unit_price DESC) AS price_rank,
    DENSE_RANK() OVER (PARTITION BY c.category_id ORDER BY p.unit_price DESC) AS price_dense_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id
ORDER BY category_name, price_rank, product_id;
