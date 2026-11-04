/* =====================================================================
   Q138 · Delete Small Order Lines With Returning
   Category : DML (DELETE … RETURNING)     Difficulty : Medium
   Concepts : DELETE · RETURNING · CTE · Aggregating Deleted Rows
   ---------------------------------------------------------------------
   PROBLEM : Delete order_details rows with quantity <= 2 and return each deleted line with its net value. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. DELETE FROM order_details WHERE quantity <= 2 RETURNING * inside a CTE.
     2. Compute the line value in the outer SELECT.
     3. Order by the primary key (order_id, product_id).
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH deleted AS (
    DELETE FROM order_details
    WHERE quantity <= 2
    RETURNING order_id, product_id, unit_price, quantity, discount
)
SELECT
    order_id,
    product_id,
    quantity,
    ROUND((unit_price * quantity * (1 - discount))::numeric, 2) AS line_value
FROM deleted
ORDER BY order_id, product_id;
