/* =====================================================================
   Q178 · Product Count And Average Price Per Band
   Category : CASE Expressions (Grouping)     Difficulty : Easy
   Concepts : CASE in GROUP BY · COUNT · AVG · MIN · MAX
   ---------------------------------------------------------------------
   PROBLEM : For each price band (Budget < 20, Mid-range < 50, Premium), return the product count, min, max and average price.
   APPROACH:
     1. Compute the band with CASE.
     2. GROUP BY the band alias.
     3. Aggregate COUNT, MIN, MAX, AVG.
     4. Order by min_price so bands appear cheapest first.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    CASE
        WHEN unit_price < 20 THEN 'Budget'
        WHEN unit_price < 50 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_band,
    COUNT(*)                  AS product_count,
    MIN(unit_price)           AS min_price,
    MAX(unit_price)           AS max_price,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY price_band
ORDER BY min_price;
