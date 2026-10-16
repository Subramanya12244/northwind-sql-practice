/* =====================================================================
   Q30 · Products Never Ordered
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · NULL Handling · WHERE · NOT EXISTS (alternative)
   ---------------------------------------------------------------------
   PROBLEM : List all products that do not appear in any order.
   APPROACH:
     1. LEFT JOIN products -> order_details on product_id (keep every product).
     2. Keep rows where od.product_id IS NULL — the join key itself, which
        mirrors the ON condition. Any right-side column works equally well;
        a left-side column (p.product_id) would never be NULL for a real row.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select p.product_id, p.product_name
from products p
left join order_details od on p.product_id = od.product_id
where od.product_id is NULL;
