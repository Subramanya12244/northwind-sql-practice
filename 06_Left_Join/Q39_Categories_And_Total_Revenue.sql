/* =====================================================================
   Q39 · Categories and Total Revenue
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN (chained, two levels) · GROUP BY · SUM
              · COALESCE · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Total discounted revenue per category, with categories that
             have no sales shown as 0.00.
   APPROACH:
     1. LEFT JOIN categories -> products on category_id (bridge table).
     2. LEFT JOIN -> order_details on product_id (must stay LEFT).
     3. SUM(unit_price*quantity*(1-discount)) at category level.
     4. COALESCE(..., 0) — SUM returns NULL for empty groups.
     5. Cast to numeric, ROUND to 2 dp.
     6. GROUP BY category_name, category_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.category_name,
coalesce(round(sum(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) as total_revenue
from categories c
left join products p on p.category_id = c.category_id
left join order_details od on od.product_id = p.product_id
group by c.category_name, c.category_id;
