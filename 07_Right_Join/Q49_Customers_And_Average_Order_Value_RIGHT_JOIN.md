# Q49 · Customers and Average Order Value (RIGHT JOIN)

> **Revision Card**
> **Category:** RIGHT JOIN + CTE | **Difficulty:** Hard
> **Concepts:** CTE · RIGHT JOIN (chained, two levels) · GROUP BY (two levels) · SUM · AVG · COALESCE · ROUND/CAST
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** my chain `customers RIGHT JOIN orders RIGHT JOIN order_details` preserved *order_details*, not customers — so no-order customers were silently dropped. The preserved entity must be the rightmost table.

## 1. Problem

The finance team wants a report showing every customer and their average order value. Customers who have never placed an order should also appear with an average order value of 0.

**Objective:** Return all customers along with their average order value, ensuring customers with no orders appear with 0.00. Use RIGHT JOIN only.

**Tables:** `customers`, `orders`, `order_details`

**Expected output:**

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

**Two levels of aggregation are required** (this is the RIGHT JOIN version of Q40):
1. **First**: sum all line items within each order → per-order total revenue.
2. **Then**: average those per-order totals per customer → average order value.

A single `AVG()` pass cannot do both — averaging `order_details` rows directly gives average *line item* value, not average *order* value.

## 2. My Approach

1. Build a CTE (`order_totals`) summing revenue per `order_id` — the correct grain for averaging (per-order total, not per-line-item). Use `RIGHT JOIN orders` inside the CTE to preserve all orders even if some have no `order_details` rows (edge case).
2. Outer query: `RIGHT JOIN customers` as the final right table — preserves every customer regardless of order history.
3. `AVG(ot.order_revenue)` averages the per-order totals per customer.
4. `COALESCE` converts NULL (from `AVG` over empty groups) to 0.00.
5. `GROUP BY c.contact_name, c.customer_id` — both required.

## 3. My Solution (as submitted)

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

## 4. Mistakes I Made

- ⚠️ **Wrong RIGHT JOIN direction (critical).** The chain `customers RIGHT JOIN orders RIGHT JOIN order_details` makes `order_details` the rightmost (preserved) table — it preserves every line item, not every customer. → Customers with no orders are dropped because `customers` is on the left with nothing to preserve them. → **Fix:** reverse the chain to `order_details → orders → customers`, putting `customers` as the final right table.
- ⚠️ **CTE selects `contact_name` but groups by `customer_id` / `order_id`.** `contact_name` is in `SELECT` but not in `GROUP BY`. → PostgreSQL errors: `column "c.contact_name" must appear in the GROUP BY clause`. → **Fix:** carry `customer_id` through and group correctly (per-order in the CTE, per-customer in the outer query).
- ⚠️ **Outer `GROUP BY contact_name` only.** → Risks silently merging customers who share the same contact name. → **Fix:** group the outer query on `c.contact_name, c.customer_id`.
- ⚠️ **No-order customers produce no CTE rows.** Because `order_details` is preserved (not `customers`), no-order customers contribute zero rows, so the outer `AVG()` has nothing to average and they disappear — no `0.00` shown. → **Fix:** the reversed chain preserves customers, giving them a NULL-padded row that `AVG` → NULL → `COALESCE` turns into 0.00.

## 5. Correct / Optimal Solution

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
    COALESCE(
        ROUND(AVG(ot.order_revenue)::numeric, 2),
        0
    ) AS average_order_value
FROM order_totals ot
RIGHT JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.contact_name, c.customer_id;
```

**Why this is correct:**
- CTE computes per-order revenue (correct grain for averaging).
- CTE uses `RIGHT JOIN orders` to preserve all orders even if some have no `order_details` rows.
- Outer query uses `RIGHT JOIN customers` to preserve all customers even if they have no orders.
- `customers` is the final right table — the entity we want to preserve.
- `COALESCE` converts NULL (from `AVG()` over no-order customers) to `0.00`.

## 6. Why This Works

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

## 7. Common Pitfalls (generic)

- Reversing the RIGHT JOIN chain so `order_details` is the rightmost table — this preserves line items, not customers.
- Forgetting that `contact_name` must appear in the CTE's `GROUP BY` if it is in the CTE's `SELECT` list.
- Grouping the outer query on `contact_name` alone, risking silent customer merges.
- Averaging `order_details` rows directly instead of pre-aggregating to order level in a CTE — the same mistake as in Q40's first attempt.

## 8. Interview Follow-ups

**1. What is wrong with the submitted attempt, and how does reversing the JOIN chain fix it?**

The submitted attempt has `customers` on the left and `order_details` on the right — so `order_details` is the preserved table, not `customers`. Customers with no orders produce no rows in the CTE and disappear from the output entirely. Reversing the chain (`order_details → orders → customers`) puts `customers` on the right of the final `RIGHT JOIN`, preserving every customer. The join semantics flip completely: now it's customers that drive the result set, and unmatched customers get NULL-padded rows from the left side.

**2. Why does the two-level aggregation requirement exist regardless of LEFT vs RIGHT JOIN direction?**

The aggregation grain problem is independent of join direction. "Average order value" always requires: (a) sum line items to get a total per order, (b) average those per-order totals per customer. Whether you use LEFT or RIGHT JOIN changes which table is preserved, not how many aggregation passes are needed. The CTE handles the first aggregation pass; the outer query handles the second. This two-step structure is mandatory regardless of join direction.

**3. Walk through what happens to a no-order customer at each step of the corrected solution.**

The CTE produces per-order totals — a customer with no orders contributes zero rows to the CTE (since the CTE is built from `order_details` and `orders`, not `customers`). In the outer query, `RIGHT JOIN customers` preserves every customer row. For a no-order customer, no CTE row matches their `customer_id`, so `ot.order_revenue` is NULL for their row. `AVG(NULL)` returns NULL. `COALESCE(NULL, 0)` returns 0.00. The customer correctly appears with 0.00.

**4. Is it possible to solve this correctly without a CTE — in a single query?**

Not cleanly. Without a CTE, you would need a correlated subquery or a window function to compute per-order totals before averaging them per customer. A derived-table approach:

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

## 9. Key Takeaway

Reversing table order in a RIGHT JOIN chain changes *which* entity is preserved — it must be the rightmost table in the final join. The two-level aggregation (sum per order, then average per customer) is mandatory regardless of join direction, so debug a query by checking: preserved table, GROUP BY completeness, and output grain.

---
📄 **SQL File:** [`Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.sql`](./Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.sql)
