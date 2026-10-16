/* =====================================================================
   Q31 · Customers and Total Revenue
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN (chained, two levels) · GROUP BY · SUM
              · COALESCE · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Total discounted revenue per customer, with no-order
             customers shown as 0.00 (not excluded, not NULL).
   APPROACH:
     1. LEFT JOIN customers -> orders on customer_id.
     2. LEFT JOIN -> order_details on order_id (must stay LEFT so NULL
        rows from step 1 survive).
     3. SUM(unit_price*quantity*(1-discount)) at customer level.
     4. COALESCE(..., 0) — SUM returns NULL for empty groups.
     5. Cast to numeric, ROUND to 2 dp.
     6. GROUP BY contact_name, customer_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name,
coalesce (round(sum(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) as revenue
from customers as c
left join orders as o on
c.customer_id=o.customer_id
left join order_details od on
o.order_id=od.order_id
group by c.contact_name,c.customer_id;
