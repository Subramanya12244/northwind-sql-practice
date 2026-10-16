/* =====================================================================
   Q56 · Products and Total Revenue (FULL OUTER JOIN)
   Category : FULL OUTER JOIN        Difficulty : Hard
   Concepts : FULL OUTER JOIN · GROUP BY · SUM · COALESCE · ROUND/CAST
              · NULL grouping behaviour
   ---------------------------------------------------------------------
   PROBLEM : Return the product name and total revenue for every product
             and every order line — no product and no order line excluded.
   APPROACH:
     1. FULL OUTER JOIN products to order_details on product_id.
     2. SUM((unit_price * quantity * (1-discount))::numeric) per product.
     3. COALESCE(..., 0) so never-sold products show 0.00, not NULL.
     4. ROUND to 2 dp; GROUP BY p.product_name, p.product_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ---------------------------------------------------------------------
   KEY BEHAVIOUR:
     • SUM() over an all-NULL group returns NULL → COALESCE to 0 required.
     • GROUP BY groups all NULL product_id (orphaned lines) into ONE row.
     • Alternative cast placement: SUM(...)::numeric (1 cast vs N) — same
       result, slightly more efficient.
   The most complete product revenue report — supersedes Q27 (LEFT) and
   Q44 (RIGHT) by capturing all three row types.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select p.product_name,
coalesce(round(sum((od.unit_price * od.quantity * (1-od.discount))::numeric), 2), 0) as total_revenue
from products p
full outer join order_details od on od.product_id = p.product_id
group by p.product_name, p.product_id;
