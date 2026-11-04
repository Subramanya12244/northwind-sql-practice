/* =====================================================================
   Q136 · Raise Prices For One Supplier
   Category : DML (UPDATE … RETURNING)     Difficulty : Easy
   Concepts : UPDATE · SET Expression · WHERE · RETURNING · ROUND
   ---------------------------------------------------------------------
   PROBLEM : Increase unit_price by 5% (rounded to 2 dp) for products of supplier_id = 1, and return product id, name and new price. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. UPDATE products SET unit_price = ROUND(unit_price * 1.05, 2).
     2. Restrict with WHERE supplier_id = 1.
     3. RETURNING the new price; wrap in a CTE and order by product_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH updated AS (
    UPDATE products
    SET unit_price = ROUND(unit_price * 1.05, 2)
    WHERE supplier_id = 1
    RETURNING product_id, product_name, unit_price AS new_price
)
SELECT product_id, product_name, new_price
FROM updated
ORDER BY product_id;
