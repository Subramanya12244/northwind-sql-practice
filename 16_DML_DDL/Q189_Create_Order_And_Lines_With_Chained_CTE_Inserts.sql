/* =====================================================================
   Q189 · Create Order And Lines With Chained CTE Inserts
   Category : DML (Data-Modifying CTEs)     Difficulty : Hard
   Concepts : Data-Modifying CTE · INSERT … SELECT · RETURNING · CROSS JOIN · Current Price Lookup
   ---------------------------------------------------------------------
   PROBLEM : In one statement, insert the order header, insert its two lines using the new order_id and current product prices, and return the lines with their totals. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. CTE new_order: INSERT INTO orders ... RETURNING order_id.
     2. CTE lines: INSERT INTO order_details SELECT new_order.order_id, p.product_id, p.unit_price, v.qty, 0 FROM new_order CROSS JOIN (VALUES ...) v JOIN products p ...  RETURNING *.
     3. Final SELECT joins lines to products for names and orders by product_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH new_order AS (
    INSERT INTO orders (customer_id, employee_id, order_date, required_date, ship_via, freight)
    VALUES ('ALFKI', 1, DATE '1998-05-06', DATE '1998-06-03', 1, 12.50)
    RETURNING order_id
),
lines AS (
    INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
    SELECT n.order_id, p.product_id, p.unit_price, v.qty, 0
    FROM new_order n
    CROSS JOIN (VALUES (1, 10), (2, 5)) AS v(product_id, qty)
    JOIN products p ON p.product_id = v.product_id
    RETURNING order_id, product_id, unit_price, quantity
)
SELECT
    l.order_id,
    l.product_id,
    p.product_name,
    l.quantity,
    l.unit_price,
    l.quantity * l.unit_price AS line_total
FROM lines l
JOIN products p ON p.product_id = l.product_id
ORDER BY l.product_id;
