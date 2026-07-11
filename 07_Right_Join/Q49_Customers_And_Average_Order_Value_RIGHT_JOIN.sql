/*
Question:
Return all customers along with their average order value, including
customers with no orders displayed as 0.00. Use RIGHT JOIN only.

Business Requirement:
The finance team wants a complete customer average order value report —
every customer must appear, and those with no orders should show 0.00.
Average order value = average of per-order totals, NOT average of line items.

---
SUBMITTED ATTEMPT — Issues Identified
---

WITH sum_rev AS (
    SELECT
        c.contact_name,
        COALESCE(ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric, 2), 0) AS total_revenue
    FROM customers c
    RIGHT JOIN orders o ON c.customer_id = o.customer_id
    RIGHT JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, o.order_id
)
SELECT contact_name, AVG(total_revenue) AS average_order_value
FROM sum_rev
GROUP BY contact_name;

Issue 1 (Critical): RIGHT JOIN chain goes customers → orders → order_details,
making order_details the preserved (rightmost) table — not customers.
Customers with no orders are dropped entirely from the CTE.

Issue 2: contact_name is in the CTE SELECT but not in GROUP BY —
PostgreSQL will raise an error (non-aggregated column not in GROUP BY).

Issue 3: Outer GROUP BY on contact_name alone risks silently merging
customers who share the same contact name.

---
CORRECTED SOLUTION
---

Approach:
1. Build CTE (order_totals) summing revenue per order_id —
   this is the correct grain for averaging (per-order total, not per-line-item).
   RIGHT JOIN orders inside CTE to preserve all orders even if some
   have no order_details rows (edge case).
2. Outer query: RIGHT JOIN customers as the final right table —
   preserves every customer regardless of order history.
3. AVG(ot.order_revenue) averages the per-order totals per customer.
4. COALESCE converts NULL (from AVG over empty groups) to 0.00.
5. GROUP BY c.contact_name, c.customer_id — both required.

LEFT JOIN equivalent (Q40 — same result):
   WITH order_totals AS (
       SELECT order_id,
              SUM(unit_price * quantity * (1-discount)) AS order_revenue
       FROM order_details GROUP BY order_id
   )
   SELECT c.contact_name,
       COALESCE(ROUND(AVG(ot.order_revenue)::numeric, 2), 0)
   FROM customers c
   LEFT JOIN orders o ON o.customer_id = c.customer_id
   LEFT JOIN order_totals ot ON ot.order_id = o.order_id
   GROUP BY c.contact_name, c.customer_id;

Expected Output:
| contact_name | average_order_value |
|--------------|---------------------|
| Maria Anders | 1523.45             |
| Ana Trujillo | 0.00                |

Concepts Used:
- CTE
- RIGHT JOIN (chained, two levels)
- GROUP BY (two levels)
- Aggregate Functions (SUM, AVG, COALESCE)
- ROUND / CAST

Complexity:
Hard
*/

-- Corrected solution:
WITH order_totals AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS order_revenue
    FROM order_details od
    RIGHT JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.contact_name,
    COALESCE(
        ROUND(AVG(ot.order_revenue)::numeric, 2),
        0
    ) AS average_order_value
FROM order_totals ot
RIGHT JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.contact_name, c.customer_id;
