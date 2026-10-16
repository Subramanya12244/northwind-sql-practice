/* =====================================================================
   Q27 · Products and Total Quantity Sold
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN · GROUP BY · SUM · NULL Handling · COALESCE
   ---------------------------------------------------------------------
   PROBLEM : Total quantity sold per product, with never-ordered
             products shown explicitly as 0.
   APPROACH:
     1. LEFT JOIN products -> order_details on product_id.
     2. SUM(od.quantity) wrapped in COALESCE(..., 0) — SUM returns NULL
        for products with no sales, so COALESCE converts it to 0.
     3. GROUP BY product; ORDER BY total_quantity_sold DESC.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;
