/* =====================================================================
   Q38 · Shippers and Total Orders Handled
   Category : LEFT JOIN          Difficulty : Easy
   Concepts : LEFT JOIN · GROUP BY · COUNT · NULL Handling
   ---------------------------------------------------------------------
   PROBLEM : Number of orders handled per shipper, with shippers who
             handled none shown as 0.
   APPROACH:
     1. LEFT JOIN shippers -> orders on ship_via = shipper_id.
        (ship_via references shipper_id — different names, map explicitly.
         Qualifying as o.ship_via = s.shipper_id is the safer habit.)
     2. COUNT(o.order_id) — not COUNT(*) — so no-order shippers return 0.
     3. COUNT returns 0 for empty groups, so no COALESCE needed.
     4. GROUP BY company_name, shipper_id.
   MISTAKES I MADE:
     • none — clean on first attempt
       (join columns written unqualified; works here, but aliasing them
        is the safer habit — see the .md §7)
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select s.company_name,
count(o.order_id) as total_orders
from shippers s
left join orders o on ship_via = shipper_id
group by s.company_name, s.shipper_id;
