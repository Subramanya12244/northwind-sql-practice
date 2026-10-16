/* =====================================================================
   Q48 · Suppliers and Total Revenue
   Category : RIGHT JOIN          Difficulty : Medium
   Concepts : RIGHT JOIN (chained, two levels) · GROUP BY · SUM
              · NULL Handling (COALESCE) · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Return all suppliers with total revenue from their products,
             showing 0.00 for suppliers with no sales.
   APPROACH:
     1. Chain order_details -> products -> suppliers (suppliers = rightmost).
     2. First RIGHT JOIN preserves all products (incl. never-ordered);
        second RIGHT JOIN preserves all suppliers.
     3. SUM(quantity*unit_price*(1-discount)); COALESCE NULL -> 0.
     4. Cast to numeric, ROUND to 2 dp; GROUP BY company_name, supplier_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
SELECT
    s.company_name,
    COALESCE(
        ROUND(
            SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric,
            2
        ),
        0
    ) AS total_revenue
FROM order_details od
RIGHT JOIN products p
    ON p.product_id = od.product_id
RIGHT JOIN suppliers s
    ON s.supplier_id = p.supplier_id
GROUP BY
    s.company_name,
    s.supplier_id;
