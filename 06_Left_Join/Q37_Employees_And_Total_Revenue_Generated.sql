/* =====================================================================
   Q37 · Employees and Total Revenue Generated
   Category : LEFT JOIN          Difficulty : Medium
   Concepts : LEFT JOIN (chained, two levels) · GROUP BY · SUM
              · COALESCE · ROUND/CAST · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Total discounted revenue per employee, with employees who
             handled no orders shown as 0.00.
   APPROACH:
     1. LEFT JOIN employees -> orders on employee_id.
     2. LEFT JOIN -> order_details on order_id (must stay LEFT).
     3. SUM(unit_price*quantity*(1-discount)) at employee level.
     4. COALESCE(..., 0) — SUM returns NULL for empty groups.
     5. Cast to numeric, ROUND to 2 dp.
     6. CONCAT(first_name,' ',last_name) — safer than || for NULL parts.
     7. GROUP BY employee_id only (names are inside CONCAT).
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
select concat(e.first_name,' ',e.last_name) as employee_name,
coalesce(round(sum(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) as total_revenue
from employees e
left join orders o on o.employee_id = e.employee_id
left join order_details od on od.order_id = o.order_id
group by e.employee_id;
