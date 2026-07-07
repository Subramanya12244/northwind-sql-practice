/*
Question:
Return all customers along with their average order value, including
customers with no orders displayed as 0.00.

Business Requirement:
The finance team wants a complete customer average order value report —
every customer must appear, and those with no orders should show 0.00
rather than being excluded or showing NULL.

---
IMPORTANT: Why naive approaches fail
---

WRONG - First Attempt (averages line items, not orders):
    SELECT c.contact_name,
        AVG(od.unit_price * od.quantity * (1 - od.discount))
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_details od ON od.order_id = o.order_id
    GROUP BY c.contact_name, c.customer_id;

    Problem: AVG() here operates on individual line items (one per product
    per order), not on total order values. An order with 5 line items of
    100 each averages as 100, not as a single order worth 500.

WRONG - Second Attempt (broken CTE with no join key):
    WITH sum_value AS (
        SELECT COALESCE(ROUND(SUM(...)::numeric, 2), 0) AS total_revenue
        FROM order_details od
    )
    -- CTE has no order_id, cannot be joined back to orders

    Problem: The CTE produces a single global total with no GROUP BY,
    so there is no order_id to join back on. The join is syntactically
    broken and semantically meaningless even if fixed.

---
Correct Approach: Two-Level Aggregation via CTE
---

"Average order value" requires two passes:
    1. SUM line items to order-level totals (one total per order_id)
    2. AVG those per-order totals per customer

These two aggregations cannot be combined in a single GROUP BY pass —
the per-order totals must be materialised in a CTE first.

Approach:
1. Build CTE (sum_value) grouping order_details by order_id, producing
   one total revenue row per order.
2. In the outer query, LEFT JOIN customers to orders (preserving no-order
   customers), then LEFT JOIN to the CTE on order_id (preserving those
   same customers through the second join too).
3. AVG(s.total_revenue) now averages per-order totals per customer —
   the correct grain.
4. COALESCE converts NULL (from AVG over no-order customers) to 0.00.
5. GROUP BY c.customer_id to guarantee one row per customer.

Expected Output:
| contact_name | average_order_value |
|--------------|---------------------|
| Maria Anders | 1523.45             |
| Thomas Hardy | 1873.20             |
| Ana Trujillo | 0.00                |

Concepts Used:
- CTE (Common Table Expression)
- LEFT JOIN (chained, two levels)
- GROUP BY (two levels)
- Aggregate Functions (SUM, AVG)
- NULL Handling (COALESCE)
- ROUND / CAST

Complexity:
Hard
*/

with sum_value as
(
    select
        order_id,
        coalesce(
            round(
                sum(od.unit_price * od.quantity * (1 - od.discount))::numeric
            , 2), 0) as total_revenue
    from order_details od
    group by order_id
)
select c.contact_name,
coalesce(
    round(
        avg(s.total_revenue)::numeric
    , 2), 0) as average_order_value
from customers c
left join orders o on o.customer_id = c.customer_id
left join sum_value s on s.order_id = o.order_id
group by c.contact_name, c.customer_id;
