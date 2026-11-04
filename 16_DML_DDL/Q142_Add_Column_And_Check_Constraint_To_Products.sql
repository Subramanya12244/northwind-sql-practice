/* =====================================================================
   Q142 · Add Column And Check Constraint To Products
   Category : DDL (ALTER TABLE / Constraints)     Difficulty : Hard
   Concepts : ALTER TABLE ADD COLUMN · CHECK Constraint · UPDATE with CASE · NOT NULL · pg_constraint
   ---------------------------------------------------------------------
   PROBLEM : Add a price_band column, backfill it with CASE, make it NOT NULL with a CHECK on the allowed values, add a CHECK (unit_price >= 0) constraint, and return the product count per band. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. ALTER TABLE products ADD COLUMN price_band VARCHAR(10).
     2. UPDATE products SET price_band = CASE ... END to backfill.
     3. ALTER COLUMN price_band SET NOT NULL and add CHECK (price_band IN (...)) and CHECK (unit_price >= 0).
     4. SELECT count and min price per band ordered by min_price.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
ALTER TABLE products ADD COLUMN price_band VARCHAR(10);

UPDATE products
SET price_band = CASE
                     WHEN unit_price < 20 THEN 'Budget'
                     WHEN unit_price < 50 THEN 'Mid-range'
                     ELSE 'Premium'
                 END;

ALTER TABLE products
    ALTER COLUMN price_band SET NOT NULL,
    ADD CONSTRAINT chk_products_price_band CHECK (price_band IN ('Budget', 'Mid-range', 'Premium')),
    ADD CONSTRAINT chk_products_unit_price_nonneg CHECK (unit_price >= 0);

SELECT
    price_band,
    COUNT(*)        AS product_count,
    MIN(unit_price) AS min_price
FROM products
GROUP BY price_band
ORDER BY min_price;
