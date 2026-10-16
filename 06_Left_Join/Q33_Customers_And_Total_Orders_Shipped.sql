/* =====================================================================
   Q33 · Customers and Total Orders Shipped
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN (chained, two levels) · GROUP BY · COUNT · COALESCE
   ---------------------------------------------------------------------
   PROBLEM : Number of orders per customer, with no-order customers
             shown as 0.
   APPROACH:
     1. LEFT JOIN customers -> orders on customer_id (keep every customer).
     2. LEFT JOIN orders -> shippers on ship_via = shipper_id (context).
     3. COUNT(o.order_id) — returns 0 for no-order customers (not COUNT(*)).
     4. COALESCE(..., 0) as a defensive/explicit default.
     5. GROUP BY contact_name, customer_id.
   NOTE: the shippers join attaches shipper info but does NOT filter for
         dispatched orders. To count only dispatched orders, filter on
         o.shipped_date IS NOT NULL inside the ON clause.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select c.contact_name,
coalesce(count(o.order_id),0)
from customers c left join
orders o on o.customer_id = c.customer_id
left join shippers sh on shipper_id = ship_via
group by c.contact_name,c.customer_id;
