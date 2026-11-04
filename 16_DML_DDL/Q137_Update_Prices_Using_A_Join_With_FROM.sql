/* =====================================================================
   Q137 · Update Prices Using A Join With FROM
   Category : DML (UPDATE … FROM)     Difficulty : Medium
   Concepts : UPDATE … FROM · Join Condition in WHERE · RETURNING · CTE
   ---------------------------------------------------------------------
   PROBLEM : Increase unit_price by 10% (2 dp) for every product in the Seafood category, and return the product, category name, and new price. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. UPDATE products p SET ... FROM categories c.
     2. WHERE c.category_id = p.category_id AND c.category_name = 'Seafood'.
     3. RETURNING columns from both tables; wrap in a CTE and order by product_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH updated AS (
    UPDATE products p
    SET unit_price = ROUND(p.unit_price * 1.10, 2)
    FROM categories c
    WHERE c.category_id   = p.category_id
      AND c.category_name = 'Seafood'
    RETURNING p.product_id, p.product_name, c.category_name, p.unit_price AS new_price
)
SELECT product_id, product_name, category_name, new_price
FROM updated
ORDER BY product_id;
