/* =====================================================================
   Q32 · Customers and Distinct Products Purchased
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN (chained, four levels) · GROUP BY
              · COUNT DISTINCT · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Count of distinct products purchased per customer, with
             no-order customers shown as 0.
   APPROACH:
     1. LEFT JOIN customers -> orders -> order_details -> products.
     2. All joins stay LEFT so no-order customers survive the chain.
     3. COUNT(DISTINCT p.product_id) — DISTINCT avoids counting repeat
        purchases of the same product multiple times.
     4. COUNT returns 0 for empty groups, so no COALESCE needed.
     5. GROUP BY contact_name, customer_id.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name,
count(distinct p.product_id)
from customers c
left join orders o on o.customer_id = c.customer_id
left join order_details od on o.order_id = od.order_id
left join products p on p.product_id = od.product_id
group by c.contact_name, c.customer_id;
