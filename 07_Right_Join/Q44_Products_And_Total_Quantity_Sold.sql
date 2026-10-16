/* =====================================================================
   Q44 · Products and Total Quantity Sold
   Category : RIGHT JOIN          Difficulty : Medium
   Concepts : RIGHT JOIN · GROUP BY · SUM · NULL Handling (COALESCE)
   ---------------------------------------------------------------------
   PROBLEM : Return all products with total quantity sold, showing 0 for
             products that have never been ordered.
   APPROACH:
     1. Place order_details on the LEFT, products on the RIGHT.
     2. RIGHT JOIN preserves every product regardless of order history.
     3. SUM(quantity) per product; COALESCE converts NULL (empty group) to 0.
     4. GROUP BY product_name, product_id.
   MISTAKES I MADE:
     • none — clean on first attempt
       (note: ROUND on integer quantity is harmless but unnecessary)
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_name,
    COALESCE(
        ROUND(SUM(od.quantity), 2),
        0
    ) AS total_quantity_sold
FROM order_details od
RIGHT JOIN products p
    ON p.product_id = od.product_id
GROUP BY p.product_name, p.product_id;
