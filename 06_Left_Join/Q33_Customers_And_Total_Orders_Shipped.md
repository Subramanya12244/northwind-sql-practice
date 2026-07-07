# Q33. Customers and Total Orders Shipped

**Category:** LEFT JOIN
**Difficulty:** Medium

---

## Problem Statement

The logistics team wants a report showing every customer and the total number of orders that have been shipped to them. Customers who have never placed an order should also appear with a shipped order count of 0.

## Objective

Return all customers along with the number of shipped orders, ensuring customers with no orders appear with a count of 0 rather than being excluded.

## Tables Used

- `customers`
- `orders`
- `shippers`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer contact |
| shipped_orders | Total number of orders shipped to this customer (0 if no orders placed) |

**Sample output:**

| contact_name | shipped_orders |
|--------------|----------------|
| Maria Anders | 12 |
| Ana Trujillo | 0 |
| Thomas Hardy | 9 |
| Christina Berglund | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN (chained, two levels)
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling (COALESCE)

## Why This Approach

**Why `LEFT JOIN customers → orders`:** preserves every customer row regardless of whether they have matching orders. An `INNER JOIN` would silently drop customers with no order history — directly violating the requirement to show them with a count of 0.

**Why `LEFT JOIN orders → shippers`:** the `shippers` table is joined to associate each order with a shipping company. Since `orders.ship_via` references `shippers.shipper_id`, this join brings in shipper context alongside each order row.

**Why `COALESCE(COUNT(o.order_id), 0)`:** for a customer with no orders, the `LEFT JOIN` produces a NULL-padded row — `o.order_id` will be `NULL`. `COUNT(o.order_id)` counts only non-NULL values, so it correctly returns `0` for those customers without needing `COALESCE`. However, wrapping in `COALESCE` is a safe and explicit defensive habit — it guarantees a `0` even if the planner or data ever produces a NULL count in an edge case, and makes the intent immediately clear to any reader.

**Why `GROUP BY c.contact_name, c.customer_id`:** both columns are included because `customer_id` is the true unique key ensuring one row per customer, while `contact_name` must also appear in `GROUP BY` since it is a non-aggregated column in the `SELECT` list. Grouping on `contact_name` alone risks silently merging two customers who share the same name.

**A note on the `shippers` join:** in this query, no column from `shippers` is referenced in the `SELECT` or filtered in a `WHERE` clause — the join to `shippers` is technically redundant for counting orders. If the intent is specifically to count only orders that were **actually dispatched** (i.e. have a confirmed ship date), a more precise approach would be to filter on `o.shipped_date IS NOT NULL` rather than relying on the presence of a shipper. In the standard Northwind dataset, `ship_via` is populated on virtually every order, so both approaches yield similar results — but the distinction matters in a production system where orders may be created before being assigned to a shipper.

## Common Mistakes

- Using `INNER JOIN` for either join, which drops no-order customers from the result.
- Using `COUNT(*)` instead of `COUNT(o.order_id)` — for a customer with no orders, the `LEFT JOIN` still produces one NULL-padded row, and `COUNT(*)` would count that row as `1` instead of `0`, incorrectly suggesting one order exists.
- Grouping by `contact_name` alone, which risks silently merging customers with identical contact names.
- Assuming the join to `shippers` filters to "shipped orders only" — it does not. A join to `shippers` simply attaches shipper information to each order; it does not filter for orders that have been dispatched. To filter for dispatched orders, `WHERE o.shipped_date IS NOT NULL` is the correct condition.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why is `COUNT(o.order_id)` used instead of `COUNT(*)`?**

`COUNT(column)` counts only non-NULL values of that column, while `COUNT(*)` counts every row regardless of NULLs. For a customer with no orders, the `LEFT JOIN` produces exactly one output row with `o.order_id = NULL`. `COUNT(o.order_id)` sees that NULL and returns `0` — correct. `COUNT(*)` counts that NULL-padded row as a real row and returns `1` — incorrect. This is one of the most important distinctions to understand when using `LEFT JOIN` with aggregation.

**2. Does `COALESCE` actually change the result here, given that `COUNT(o.order_id)` already returns 0?**

Strictly speaking, no — `COUNT(o.order_id)` already returns `0` for unmatched customers, not `NULL`, so `COALESCE` is redundant here. `COALESCE` is genuinely needed for `SUM()` (as in Q31), which *does* return `NULL` for empty groups. For `COUNT`, `COALESCE` is a defensive habit rather than a correctness fix — it adds clarity of intent, and it's harmless, but understanding the difference between when it's required versus optional is a sign of deeper SQL fluency.

**3. What's the difference between "orders with a shipper assigned" and "orders that have been shipped"?**

Joining to `shippers` (or filtering `ship_via IS NOT NULL`) tells you an order *has a shipper assigned* — which happens when the order is created or processed. It does not confirm the goods have physically left the warehouse. `shipped_date IS NOT NULL` is the reliable indicator that an order has been dispatched in Northwind. In a production system, the difference matters: an order might have a shipper assigned but still be sitting in the warehouse awaiting pickup.

**4. How would you modify this query to count only orders that have actually been dispatched?**

Replace the `shippers` join with a `WHERE` filter on `shipped_date`:

```sql
SELECT
    c.contact_name,
    COUNT(o.order_id) AS shipped_orders
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
    AND o.shipped_date IS NOT NULL
GROUP BY c.contact_name, c.customer_id;
```

Note: the `AND o.shipped_date IS NOT NULL` condition is placed inside the `ON` clause (not in `WHERE`) so that customers with no dispatched orders still appear in the result with a count of `0` — placing it in `WHERE` would turn the `LEFT JOIN` into an effective `INNER JOIN` for this filter, dropping those customers entirely.

**5. How would you extend this to also show the most recent ship date per customer?**

Add `MAX(o.shipped_date) AS latest_ship_date` to the `SELECT` list. `MAX()` naturally returns `NULL` for customers with no shipped orders, which is the correct display value in that case — no extra `COALESCE` needed unless you want to substitute a placeholder string or date:

```sql
SELECT
    c.contact_name,
    COUNT(o.order_id) AS shipped_orders,
    MAX(o.shipped_date) AS latest_ship_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.contact_name, c.customer_id
ORDER BY latest_ship_date DESC NULLS LAST;
```

## Learning Outcomes

- Understand the critical difference between `COUNT(column)` and `COUNT(*)` in the context of `LEFT JOIN` — the single most tested aggregation nuance in SQL interviews involving outer joins.
- Recognise that joining to a lookup table (like `shippers`) does not implicitly filter rows — joins attach data, filters restrict rows.
- Know the difference between "has a shipper assigned" (`ship_via IS NOT NULL`) and "has been dispatched" (`shipped_date IS NOT NULL`), which are logically distinct in order management systems.
- Practice placing filter conditions inside `ON` rather than `WHERE` when the intent is to filter join matches while still preserving outer (non-matching) rows.

---

📄 **SQL File:** [`Q33_Customers_And_Total_Orders_Shipped.sql`](./Q33_Customers_And_Total_Orders_Shipped.sql)
