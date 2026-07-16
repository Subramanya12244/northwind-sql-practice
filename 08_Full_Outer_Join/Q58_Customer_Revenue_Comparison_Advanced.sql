/*
Question:
Return the customer(s) with the single highest total revenue, using a full
reconciliation of all customers, unmatched customers, and unassigned orders
as the basis for the comparison.

Business Requirement:
The finance team wants a reconciliation report showing all customers and their
revenue, including customers who generated revenue, customers with no orders,
and orders that exist without a valid customer, and then wants to know which
customer(s) generated the single highest revenue amount. If multiple customers
tie for the highest revenue, all tied customers must be returned.

Approach:
1. Build a CTE (`rev`) that reconciles customers, orders, and order_details
   using FULL OUTER JOIN at every step, so no customer or order is silently
   dropped on either side.
2. Aggregate revenue per customer with SUM(unit_price * quantity * (1 - discount)),
   cast to ::numeric before ROUND() (PostgreSQL requirement for the 2-arg form).
3. Wrap the SUM in COALESCE(..., 0) so customers with no orders show 0 revenue
   instead of NULL -- this is required for the final tie-safe comparison to work,
   since NULL fails every standard comparison operator.
4. In the outer query, select from `rev` and filter with
   `total_revenue >= (SELECT MAX(total_revenue) FROM rev)`.
   This is the tie-safe top-N pattern: it returns every row matching the true
   maximum, rather than an arbitrary single row the way `ORDER BY ... LIMIT 1`
   would if there's a tie.

This is structurally an extension of Q57 (same FULL OUTER JOIN reconciliation
logic, customers/orders/order_details instead of employees/orders/order_details),
combined with the tie-safe "top N" pattern used across earlier aggregation
questions. No bugs found in the submitted query -- reconciliation join, CTE
reuse, COALESCE placement, ::numeric cast, and the tie-safe MAX comparison are
all correctly applied.

Expected Output:
| contact_name   | total_revenue |
|-----------------|---------------|
| Ernst Handel    | 128945.75     |
| NULL            | 500.00        |
(Illustrative only -- actual returned rows are whichever contact_name(s) truly
hold the maximum total_revenue in the dataset. A genuine tie returns multiple
rows; a single winner returns one row.)

Concepts Used:
- FULL OUTER JOIN (chained, for reconciliation)
- CTE (Common Table Expression)
- COALESCE for zero-revenue defaulting
- ::numeric cast before ROUND()
- Tie-safe maximum comparison (subquery >=, not LIMIT 1)
- GROUP BY with FULL OUTER JOIN

Complexity:
Hard
*/

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
Note -- tie-safe pattern generalization:
To extend this to "top N with ties" (e.g. top 3 customers by revenue), replace
the MAX(...) filter with DENSE_RANK() OVER (ORDER BY total_revenue DESC) inside
the CTE and filter the outer query on rank <= N. DENSE_RANK() is required over
RANK() or ROW_NUMBER() to avoid rank gaps after ties or arbitrary tie-breaking.

Note -- why COALESCE is non-negotiable here specifically:
Unlike previous questions where COALESCE was mostly a display/formatting
concern, here it is a correctness requirement: NULL >= anything evaluates to
UNKNOWN in SQL, so any customer left with a NULL total_revenue would be
silently excluded from the tie-safe comparison, even if they were the true
maximum.
*/
