# Q40. Customers and Average Order Value

**Category:** LEFT JOIN + CTE
**Difficulty:** Hard

---

## Problem Statement

The finance team wants a report showing every customer and their average order value. Customers who have never placed an order should also appear with an average order value of 0.

## Objective

Return all customers along with their average order value, ensuring customers with no orders appear with a value of 0.00.

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

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- CTE (Common Table Expression)
- LEFT JOIN (chained, two levels)
- GROUP BY (two levels)
- Aggregate Functions (SUM, AVG)
- NULL Handling (COALESCE)
- ROUND / CAST

## The Problem With Naive Approaches

This question has an intentional trap. "Average order value per customer" is not as straightforward as it looks, and there are two common wrong approaches before arriving at the correct solution.

### ❌ First Attempt — Wrong: Averaging Line Items, Not Orders

```sql
SELECT c.contact_name,
    COALESCE(ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0)
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.contact_name, c.customer_id;
```

**Why this is wrong:** `AVG()` here averages *individual order line items* (one row per product per order), not the total value of each order. A customer with one order containing 5 line items of £200 each gets an "average" of £200 — but their average *order* value is £1000. This computes "average line item value", which is a completely different metric from "average order value".

### ❌ Second Attempt — Wrong: Broken CTE Join

```sql
WITH sum_value AS (
    SELECT COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS total_revenue
    FROM order_details od
)
SELECT c.contact_name,
    COALESCE(ROUND(AVG(sum_value)::numeric, 2), 0) AS average_order_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
LEFT JOIN sum_value ON o    -- broken: no valid join condition
GROUP BY c.contact_name, c.customer_id, sum_value.total_revenue;
```

**Why this is wrong:** the CTE computes a single global revenue total with no `GROUP BY`, so there is no `order_id` to join back on. The `LEFT JOIN sum_value ON o` is syntactically broken — `ON o` is not a valid join condition. Even if fixed, a single-row CTE cross-joined to the main query would produce meaningless results.

### ✅ Correct Approach — Two-Level Aggregation via CTE

The key insight is that "average order value" requires **two levels of aggregation**:
1. First, compute the **total revenue per order** (summing all line items within each order)
2. Then, compute the **average of those per-order totals** per customer

A single `AVG()` pass cannot do both simultaneously — the per-order totals must be materialised first before they can be averaged.

## Why This Approach (Final Solution)

**Why the CTE (`sum_value`) groups by `order_id`:** each order can have multiple line items in `order_details`. The CTE collapses all line items for a given order into a single total revenue figure — one row per `order_id`. This is the correct grain for computing "order value" before averaging across orders per customer.

**Why `AVG(s.total_revenue)` in the outer query:** after joining the per-order CTE back to customers (via `orders`), each customer now has one row per order (not one row per line item). `AVG()` over those per-order totals correctly computes the average order value per customer.

**Why two `LEFT JOIN`s in the outer query:** `customers → orders` must be `LEFT JOIN` to preserve customers with no orders. `orders → sum_value` must also be `LEFT JOIN` so those same NULL-padded customer rows are not eliminated at the CTE join step.

**Why `COALESCE(..., 0)` is still needed:** for customers with no orders, `AVG()` receives no non-NULL values to average and returns `NULL`. `COALESCE` converts that to the required `0.00`.

## Common Mistakes

- Using `AVG(od.unit_price * od.quantity * (1 - od.discount))` directly — this averages line items, not orders; the most common mistake on this question.
- Not pre-aggregating to order level in a CTE first — without materialising per-order totals, there is no correct way to average them per customer in a single pass.
- Breaking the CTE join by not including `order_id` as a key column in the CTE — the CTE must `GROUP BY order_id` so it can be joined back to `orders` on that key.
- Making the `orders → sum_value` join `INNER JOIN`, which drops the NULL-padded no-order customer rows produced by the first `LEFT JOIN`.

## Difficulty

**Hard**

## Interview Follow-up Questions

**1. Why does `AVG(od.unit_price * od.quantity * (1 - od.discount))` give the wrong answer?**

That expression averages individual *line items*, not *orders*. An order with 3 line items of £100, £200, and £300 would contribute three separate values to the `AVG()` — giving a per-line-item average of £200. But the order's total value is £600, and it should count as one order worth £600 when computing a customer's average order value. The fix is to always aggregate line items to order-level totals first, then average those totals per customer.

**2. Why must the CTE include `GROUP BY order_id`?**

Two reasons. First, it collapses the multiple line-item rows for each order into a single total revenue figure — the correct grain for "order value". Second, `order_id` becomes the join key that connects the CTE back to `orders` in the outer query. Without `GROUP BY order_id`, the CTE would produce either a single global total (no grouping at all) or an error, with no way to associate each total with its specific order.

**3. Walk through what happens to a customer with no orders at each step of this query.**

The outer `LEFT JOIN customers → orders` produces one row for the customer with `o.order_id = NULL`. The subsequent `LEFT JOIN orders → sum_value` tries to match `s.order_id = o.order_id`, but since `o.order_id` is `NULL`, no match is found — producing another NULL-padded row, now with `s.total_revenue = NULL`. `AVG(NULL)` returns `NULL`. `COALESCE(NULL, 0)` returns `0.00`. The customer correctly appears with a zero average.

**4. How does this two-level aggregation pattern differ from what was used in Q13 (Products Sold Above Category Average)?**

Q13 also used two levels of aggregation — first summing quantity per product, then averaging those per-product totals within each category. The structural pattern is identical: aggregate to an intermediate grain (order, or product), materialise that in a CTE, then aggregate again to the final grain (customer average, or category average). "Two-level aggregation via CTE" is a broadly applicable pattern in analytical SQL, not specific to this problem.

**5. How would you modify this to show customers whose average order value is above the company-wide average?**

Add a third CTE computing the company-wide average order value, then filter:

```sql
WITH order_totals AS (
    SELECT order_id,
           SUM(unit_price * quantity * (1 - discount)) AS order_revenue
    FROM order_details
    GROUP BY order_id
),
customer_avg AS (
    SELECT
        c.contact_name,
        c.customer_id,
        COALESCE(ROUND(AVG(ot.order_revenue)::numeric, 2), 0) AS average_order_value
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_totals ot ON ot.order_id = o.order_id
    GROUP BY c.contact_name, c.customer_id
),
overall_avg AS (
    SELECT AVG(average_order_value) AS avg_val FROM customer_avg
    WHERE average_order_value > 0  -- exclude no-order customers from the benchmark
)
SELECT ca.contact_name, ca.average_order_value
FROM customer_avg ca, overall_avg oa
WHERE ca.average_order_value > oa.avg_val
ORDER BY ca.average_order_value DESC;
```

## Learning Outcomes

- Understand that "average order value" is a two-level aggregation problem — line items must be summed to order level before order values can be averaged per customer.
- Practise the discipline of asking "what is the correct grain for my aggregation?" before writing any `AVG()`, `SUM()`, or `COUNT()` — a fundamental analytical SQL skill.
- Recognise the general two-level aggregation via CTE pattern and understand when it applies (anytime you need to aggregate an already-aggregated intermediate result).
- Learn from the documented wrong approaches — seeing *why* naive solutions fail is often more instructive than just seeing the correct one.

---

📄 **SQL File:** [`Q40_Customers_And_Average_Order_Value.sql`](./Q40_Customers_And_Average_Order_Value.sql)
