/* =====================================================================
   Q58 · Customer Revenue Comparison (Advanced)
   Category : FULL OUTER JOIN / CTE / Tie-Safe Top-N    Difficulty : Hard
   Concepts : FULL OUTER JOIN (chained) · CTE · COALESCE · ::numeric cast
              · Tie-safe MAX comparison (not LIMIT 1) · GROUP BY
   ---------------------------------------------------------------------
   PROBLEM : Return the customer(s) with the single highest total revenue,
             using a full reconciliation of all customers, unmatched
             customers, and unassigned orders as the comparison basis.
   APPROACH:
     1. CTE `rev`: reconcile customers/orders/order_details with FULL OUTER
        JOIN at every step so no row is dropped on either side.
     2. SUM((unit_price*quantity*(1-discount))::numeric), ROUND 2 dp.
     3. COALESCE(..., 0) so no-order customers are comparable (not NULL).
     4. Outer query: WHERE total_revenue >= (SELECT MAX(total_revenue)
        FROM rev) — tie-safe top-N (returns all ties, unlike LIMIT 1).
   MISTAKES I MADE:
     • none — clean on first attempt (reconciliation join, CTE reuse,
       COALESCE, ::numeric cast, tie-safe MAX all correctly applied)
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
with rev as (
    select
        c.contact_name,
        coalesce(
            round(
                sum((od.unit_price * od.quantity * (1 - od.discount))::numeric),
                2
            ),
            0
        ) as total_revenue
    from customers c
    full outer join orders o
        on o.customer_id = c.customer_id
    full outer join order_details od
        on od.order_id = o.order_id
    group by c.contact_name, c.customer_id
)
select
    contact_name,
    total_revenue
from rev
where total_revenue >= (select max(total_revenue) from rev);

/*
Note — tie-safe pattern generalization:
For "top N with ties" (e.g. top 3), replace the MAX(...) filter with
DENSE_RANK() OVER (ORDER BY total_revenue DESC) inside the CTE and filter
rank <= N. DENSE_RANK() avoids rank gaps / arbitrary tie-breaking.

Note — why COALESCE is non-negotiable here:
NULL >= anything evaluates to UNKNOWN, so any customer left with NULL
total_revenue would be silently excluded from the tie-safe comparison —
even if they were the true maximum.
*/
