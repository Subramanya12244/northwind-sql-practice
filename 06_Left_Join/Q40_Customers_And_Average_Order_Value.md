# Q40 · Customers and Average Order Value

> **Revision Card**
> **Category:** LEFT JOIN + CTE | **Difficulty:** Hard
> **Concepts:** CTE · LEFT JOIN (chained, two levels) · GROUP BY (two levels) · SUM · AVG · COALESCE · ROUND/CAST
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** `AVG(line_item_revenue)` averages line items, not orders — you must pre-aggregate line items to order totals first, then average those.

## 1. Problem

The finance team wants a report showing every customer and their average order value. Customers who have never placed an order should also appear with an average order value of 0.

**Objective:** Return all customers along with their average order value, ensuring customers with no orders appear with a value of 0.00.

**Tables:** `customers`, `orders`, `order_details`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer contact |
| average_order_value | Average revenue per order for this customer (0.00 if no orders placed) |

| contact_name | average_order_value |
|--------------|---------------------|
| Maria Anders | 1523.45 |
| Thomas Hardy | 1873.20 |
| Ana Trujillo | 0.00 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

"Average order value" requires **two levels of aggregation**, which only became clear after two failed attempts:

1. First, compute the **total revenue per order** (summing all line items within each order) in a CTE grouped by `order_id`.
2. Then, in the outer query, LEFT JOIN `customers → orders → CTE` (all LEFT to preserve no-order customers) and compute the **average of those per-order totals** per customer with `AVG()`.
3. Wrap in `COALESCE(..., 0)` so no-order customers (where `AVG()` returns NULL) show 0.00.
4. GROUP BY customer.

## 3. My Solution (as submitted)

My first submission averaged the line items directly, which is the wrong grain:

```sql
SELECT c.contact_name,
    COALESCE(ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0)
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.contact_name, c.customer_id;
```

## 4. Mistakes I Made

- ⚠️ **First attempt — averaged line items, not orders.** `AVG(od.unit_price * od.quantity * (1 - od.discount))` operates on *individual order line items* (one row per product per order), not on total order values. An order with 5 line items of £200 each gets an "average" of £200, but its true order value is £1000 — the metric computed is "average line item value", a completely different thing. **Fix:** sum line items to order-level totals *first* (in a CTE grouped by `order_id`), then average those per-order totals per customer.
- ⚠️ **Second attempt — broken CTE join.** I tried a CTE that computed a single global `SUM()` with no `GROUP BY`, so it had no `order_id` to join back on, and the join `LEFT JOIN sum_value ON o` was not even a valid join condition. **Fix:** the CTE must `GROUP BY order_id` so it produces one total per order and exposes `order_id` as the key to join back to `orders`.

## 5. Correct / Optimal Solution

```sql
WITH sum_value AS (
    SELECT
        order_id,
        COALESCE(
            ROUND(
                SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric
            , 2), 0) AS total_revenue
    FROM order_details od
    GROUP BY order_id
)
SELECT c.contact_name,
    COALESCE(
        ROUND(
            AVG(s.total_revenue)::numeric
        , 2), 0) AS average_order_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN sum_value s ON s.order_id = o.order_id
GROUP BY c.contact_name, c.customer_id;
```

## 6. Why This Works

**Why the CTE (`sum_value`) groups by `order_id`:** each order can have multiple line items in `order_details`. The CTE collapses all line items for a given order into a single total revenue figure — one row per `order_id`. This is the correct grain for computing "order value" before averaging across orders per customer.

**Why `AVG(s.total_revenue)` in the outer query:** after joining the per-order CTE back to customers (via `orders`), each customer now has one row per order (not one row per line item). `AVG()` over those per-order totals correctly computes the average order value per customer.

**Why two `LEFT JOIN`s in the outer query:** `customers → orders` must be `LEFT JOIN` to preserve customers with no orders. `orders → sum_value` must also be `LEFT JOIN` so those same NULL-padded customer rows are not eliminated at the CTE join step.

**Why `COALESCE(..., 0)` is still needed:** for customers with no orders, `AVG()` receives no non-NULL values to average and returns `NULL`. `COALESCE` converts that to the required `0.00`.

## 7. Common Pitfalls (generic)

- Using `AVG(od.unit_price * od.quantity * (1 - od.discount))` directly — this averages line items, not orders; the most common mistake on this question.
- Not pre-aggregating to order level in a CTE first — without materialising per-order totals, there is no correct way to average them per customer in a single pass.
- Breaking the CTE join by not including `order_id` as a key column in the CTE — the CTE must `GROUP BY order_id` so it can be joined back to `orders` on that key.
- Making the `orders → sum_value` join `INNER JOIN`, which drops the NULL-padded no-order customer rows produced by the first `LEFT JOIN`.

## 8. Interview Follow-ups

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

## 9. Key Takeaway

"Average order value" is a two-level aggregation: sum line items to order totals first, then average those per customer — always ask "what is the correct grain?" before writing any `AVG()`.

---
📄 **SQL File:** [`Q40_Customers_And_Average_Order_Value.sql`](./Q40_Customers_And_Average_Order_Value.sql)
