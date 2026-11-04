/* =====================================================================
   Q128 · Product Price Bands
   Category : CASE Expressions (Bucketing)     Difficulty : Easy
   Concepts : Searched CASE · WHEN Order · ELSE · Bucketing
   ---------------------------------------------------------------------
   PROBLEM : Return each product with its price and price band.
   APPROACH:
     1. Write a searched CASE with WHEN unit_price < 20, then < 50, then ELSE.
     2. Order by product_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    product_id,
    product_name,
    unit_price,
    CASE
        WHEN unit_price < 20 THEN 'Budget'
        WHEN unit_price < 50 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_band
FROM products
ORDER BY product_id;
