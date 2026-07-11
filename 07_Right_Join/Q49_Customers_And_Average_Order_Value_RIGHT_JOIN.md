# Q49. Customers and Average Order Value (RIGHT JOIN)

**Category:** RIGHT JOIN + CTE
**Difficulty:** Hard

---

## Problem Statement

The finance team wants a report showing every customer and their average order value. Customers who have never placed an order should also appear with an average order value of 0.

## Objective

Return all customers along with their average order value, ensuring customers with no orders appear with 0.00. Use RIGHT JOIN only.

## Tables Used

- `customers`
- `orders`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer contact |
| average_order_value | Average revenue per order for this customer (0.00 if no orders placed) |

**Sample output:**

| contact_name | average_order_value |
|--------------|---------------------|
| Maria Anders | 1523.45 |
| Thomas Hardy | 1873.20 |
| Ana Trujillo | 0.00 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- CTE (Common Table Expression)
- RIGHT JOIN (chained, two levels)
- GROUP BY (two levels — order-level, then customer-level)
- Aggregate Functions (SUM, AVG, COALESCE)
- NULL Handling
- ROUND / CAST

## Understanding the Problem — Two Levels of Aggregation Required

This is the RIGHT JOIN version of Q40. The same two-level aggregation requirement applies:

1. **First**: sum all line items within each order → per-order total revenue
2. **Then**: average those per-order totals per customer → average order value

A single `AVG()` pass cannot do both — averaging `order_details` rows directly gives average *line item* value, not average *order* value.

---

## Attempt Analysis

### ❌ Submitted Attempt — Issues Identified

```sql
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
```

**Issue 1 — Wrong RIGHT JOIN direction (critical):**
The chain `customers RIGHT JOIN orders RIGHT JOIN order_details` has `order_details` as the rightmost (preserved) table. This preserves every order line item — not every customer. Customers with no orders will be dropped because `customers` is on the left, and unmatched customer rows have nothing to be preserved by. The requirement to show no-order customers with `0.00` is violated.

**Issue 2 — CTE selects `contact_name` but groups by `customer_id`:**
`contact_name` is in the `SELECT` list but `customer_id` is the only non-aggregated column in `GROUP BY`. PostgreSQL will raise an error: `column "c.contact_name" must appear in the GROUP BY clause`. Both must be included.

**Issue 3 — Outer GROUP BY on `contact_name` only:**
The outer query groups on `contact_name` alone, risking silent merges for customers who share the same contact name. `customer_id` should be carried through and used in the outer GROUP BY.

**Issue 4 — No-order customers produce no CTE rows:**
Because `order_details` is preserved (not `customers`), customers with no orders produce no rows in the CTE at all. The outer `AVG()` has nothing to average for them, and they simply disappear from the output — no `0.00` is shown.

---

### ✅ Corrected Solution

The fix mirrors Q40's LEFT JOIN solution, but reverses table order for RIGHT JOIN: the chain must go `order_details → orders → customers`, with `customers` as the final right table.

```sql
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
    COALESCE(ROUND(AVG(ot.order_revenue)::numeric, 2), 0) AS average_order_value
FROM order_totals ot
RIGHT JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.contact_name, c.customer_id;
```

**Why this is correct:**
- CTE computes per-order revenue (correct grain for averaging)
- CTE uses `RIGHT JOIN orders` to preserve all orders even if some have no `order_details` rows
- Outer query uses `RIGHT JOIN customers` to preserve all customers even if they have no orders
- `customers` is the final right table — the entity we want to preserve
- `COALESCE` converts NULL (from `AVG()` over no-order customers) to `0.00`

## Why This Approach

**Why a CTE is still required with RIGHT JOIN:** the two-level aggregation problem is the same regardless of join direction. You cannot `AVG()` over `order_details` rows directly and get average *order* value — the per-order totals must be materialised first. The CTE's job is the same as in Q40: collapse line items to one total per order before averaging those totals per customer.

**Why the CTE uses `RIGHT JOIN orders`:** some orders could theoretically have no `order_details` rows (edge case). RIGHT JOIN here preserves all orders so none are silently dropped before the averaging step.

**Why the outer query uses `RIGHT JOIN customers`:** this is what preserves all customers, including those with no orders, giving them `NULL` (converted to `0.00` by COALESCE) in the average.

**LEFT JOIN equivalent from Q40:**
```sql
WITH order_totals AS (
    SELECT order_id,
           SUM(unit_price * quantity * (1 - discount)) AS order_revenue
    FROM order_details
    GROUP BY order_id
)
SELECT c.contact_name,
    COALESCE(ROUND(AVG(ot.order_revenue)::numeric, 2), 0) AS average_order_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot ON ot.order_id = o.order_id
GROUP BY c.contact_name, c.customer_id;
```

## Common Mistakes

- Reversing the RIGHT JOIN chain so `order_details` is the rightmost table — this preserves line items, not customers.
- Forgetting that `contact_name` must appear in the CTE's `GROUP BY` if it is in the CTE's `SELECT` list.
- Grouping the outer query on `contact_name` alone, risking silent customer merges.
- Averaging `order_details` rows directly instead of pre-aggregating to order level in a CTE — the same mistake as in Q40's first attempt.

## Difficulty

**Hard**

## Interview Follow-up Questions

**1. What is wrong with the submitted attempt, and how does reversing the JOIN chain fix it?**

The submitted attempt has `customers` on the left and `order_details` on the right — so `order_details` is the preserved table, not `customers`. Customers with no orders produce no rows in the CTE and disappear from the output entirely. Reversing the chain (`order_details → orders → customers`) puts `customers` on the right of the final `RIGHT JOIN`, preserving every customer. The join semantics flip completely: now it's customers that drive the result set, and unmatched customers get NULL-padded rows from the left side.

**2. Why does the two-level aggregation requirement exist regardless of LEFT vs RIGHT JOIN direction?**

The aggregation grain problem is independent of join direction. "Average order value" always requires: (a) sum line items to get a total per order, (b) average those per-order totals per customer. Whether you use LEFT or RIGHT JOIN changes which table is preserved, not how many aggregation passes are needed. The CTE handles the first aggregation pass; the outer query handles the second. This two-step structure is mandatory regardless of join direction.

**3. Walk through what happens to a no-order customer at each step of the corrected solution.**

The CTE produces per-order totals — a customer with no orders contributes zero rows to the CTE (since the CTE is built from `order_details` and `orders`, not `customers`). In the outer query, `RIGHT JOIN customers` preserves every customer row. For a no-order customer, no CTE row matches their `customer_id`, so `ot.order_revenue` is NULL for their row. `AVG(NULL)` returns NULL. `COALESCE(NULL, 0)` returns 0.00. The customer correctly appears with 0.00.

**4. Is it possible to solve this correctly without a CTE — in a single query?**

Not cleanly. Without a CTE, you would need a correlated subquery or a window function to compute per-order totals before averaging them per customer. A correlated subquery approach:

```sql
SELECT
    c.contact_name,
    COALESCE(ROUND(AVG(order_rev.order_revenue)::numeric, 2), 0) AS average_order_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_revenue
    FROM order_details
    GROUP BY order_id
) order_rev ON order_rev.order_id = o.order_id
GROUP BY c.contact_name, c.customer_id;
```

The CTE version and this derived-table version are logically equivalent — a CTE is just a named, reusable derived table with cleaner syntax.

**5. What makes this question "Hard" compared to Q45 (Customers and Total Revenue)?**

Q45 computes total revenue per customer — a single SUM over all line items grouped by customer. That requires only one level of aggregation. Q49 computes average order value — which requires summing line items per order first, then averaging those per-order sums per customer. That is two levels of aggregation, which is why a CTE (or subquery) is mandatory. The additional cognitive step of "I need to aggregate twice, not once" is what elevates this to Hard difficulty.

## Learning Outcomes

- Understand that reversing the table order in a RIGHT JOIN chain changes *which* entity is preserved — the rightmost table is always the one fully preserved.
- Recognise that the two-level aggregation requirement for "average order value" applies equally to LEFT JOIN and RIGHT JOIN solutions — join direction is independent of aggregation grain.
- Practice debugging a submitted SQL attempt systematically: identify the preserved table, check GROUP BY completeness, verify the output grain matches the business requirement.
- Appreciate that a CTE is a named derived table — either form works, but CTEs are cleaner and more readable for multi-step aggregation logic.

---

📄 **SQL File:** [`Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.sql`](./Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.sql)
