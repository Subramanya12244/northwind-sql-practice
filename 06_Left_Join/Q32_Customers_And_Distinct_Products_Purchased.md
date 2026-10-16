# Q32 · Customers and Distinct Products Purchased

> **Revision Card**
> **Category:** LEFT JOIN | **Difficulty:** Medium
> **Concepts:** LEFT JOIN (chained, four levels) · GROUP BY · COUNT DISTINCT · NULL Handling
> **Outcome:** ✅ correct first attempt
> **Watch out for:** without `DISTINCT`, repeat purchases of the same product inflate the count — `COUNT(DISTINCT p.product_id)` is essential.

## 1. Problem

The product analytics team wants a report showing every customer and the total number of distinct products they have purchased. Customers who have never placed an order should also appear in the report with a product count of 0.

**Objective:** Return all customers along with the count of distinct products they have purchased, ensuring customers with no orders still appear with a count of 0.

**Tables:** `customers`, `orders`, `order_details`, `products`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer contact |
| distinct_products | Number of distinct products purchased by this customer (0 if no orders placed) |

| contact_name | distinct_products |
|--------------|-------------------|
| Maria Anders | 24 |
| Thomas Hardy | 31 |
| Ana Trujillo | 0 |
| Christina Berglund | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Start from `customers` and LEFT JOIN to `orders` on `customer_id`.
2. LEFT JOIN to `order_details` on `order_id` to reach line-item level.
3. LEFT JOIN to `products` on `product_id` to bring in product context.
4. All joins must remain LEFT JOIN — converting any to INNER JOIN would drop no-order customers from the result at that step.
5. Use `COUNT(DISTINCT p.product_id)` to count unique products per customer. DISTINCT is essential — without it, repeat purchases of the same product across multiple orders inflate the count incorrectly.
6. COUNT returns 0 (not NULL) for empty groups, so COALESCE is not required — unlike `SUM()`.
7. GROUP BY both `contact_name` and `customer_id`.

## 3. My Solution (as submitted)

```sql
select c.contact_name,
count(distinct p.product_id)
from customers c
left join orders o on o.customer_id = c.customer_id
left join order_details od on o.order_id = od.order_id
left join products p on p.product_id = od.product_id
group by c.contact_name, c.customer_id;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why four tables are joined:** the chain `customers → orders → order_details → products` is the only path from customer identity to individual product purchases. There is no shortcut — each table provides a necessary link:
- `orders` connects `customers` to their transactions via `customer_id`
- `order_details` connects each order to its line items via `order_id`
- `products` is joined to bring in `product_id` as the entity being counted — although `order_details` already contains `product_id`, joining `products` makes the intent explicit and allows `product_name` to be added to the output easily if needed.

**Why all joins are `LEFT JOIN`:** the chain must remain `LEFT JOIN` throughout. Converting any intermediate join to `INNER JOIN` would silently drop the NULL-padded rows produced by the earlier `LEFT JOIN` — pulling customers with no orders out of the result at that step, even though the first join correctly preserved them.

**Why `COUNT(DISTINCT p.product_id)`:** a customer can order the same product multiple times across different orders. Without `DISTINCT`, each repeat purchase of the same product would be counted again, inflating the total beyond the number of unique products the customer has ever bought. `DISTINCT` ensures each product is counted only once per customer regardless of how many times it was ordered.

**Why `COUNT` does not need `COALESCE` here:** `COUNT(DISTINCT p.product_id)` counts non-NULL values of `p.product_id`. For a customer with no orders, the entire chain produces `NULL` for `p.product_id`, and `COUNT` returns `0` — not `NULL`. Unlike `SUM()`, `COUNT()` never returns `NULL` for an empty group; it always returns `0`. `COALESCE` would be redundant here, though harmless if added for consistency.

**Why `GROUP BY c.contact_name, c.customer_id`:** `customer_id` is the unique key that guarantees one row per customer; `contact_name` must also appear because it is a non-aggregated selected column. Grouping by `contact_name` alone risks merging two customers with identical names.

## 7. Common Pitfalls (generic)

- Converting any intermediate join to `INNER JOIN`, which silently drops no-order customers from the result.
- Using `COUNT(p.product_id)` without `DISTINCT`, which counts repeat purchases of the same product as separate items — inflating the "distinct products" figure.
- Assuming `products` is unnecessary because `order_details` already has `product_id` — technically true for just counting, but joining `products` is a good habit that makes the query more readable and extensible.
- Grouping by `contact_name` alone, which risks silently merging customers who share the same contact name.

## 8. Interview Follow-ups

**1. Why must `DISTINCT` be used inside `COUNT()` here?**

A customer can order the same product in multiple separate orders. Without `DISTINCT`, each of those order line items contributes +1 to the count, even if it's the same product. For example, if a customer ordered "Chai" in 5 different orders, `COUNT(p.product_id)` would return 5 while `COUNT(DISTINCT p.product_id)` correctly returns 1. The question asks for distinct products ever purchased, not total line items.

**2. Does `COUNT(DISTINCT ...)` need `COALESCE` to handle customers with no orders?**

No — unlike `SUM()`, `COUNT()` never returns `NULL` for an empty group. `COUNT(DISTINCT p.product_id)` returns `0` when every value in the group is `NULL` (as is the case for no-order customers after the `LEFT JOIN`). `COALESCE` is only required for `SUM()`, `AVG()`, `MIN()`, and `MAX()`, which return `NULL` for empty groups. Knowing which aggregate functions return `NULL` versus `0` for empty groups is a valuable interview signal.

**3. Is the join to `products` strictly necessary if `order_details` already contains `product_id`?**

Not for this specific query — `COUNT(DISTINCT od.product_id)` would produce the same result without joining `products` at all, since the `product_id` being counted already exists in `order_details`. The `products` join is included for extensibility (easily add `product_name` to the output) and readability. In a performance-sensitive context on large tables, removing the unnecessary join to `products` would reduce I/O and join overhead with no change to the result.

**4. What would happen if any intermediate join were changed to `INNER JOIN`?**

The NULL-padded rows produced for no-order customers by the first `LEFT JOIN` would be eliminated at the `INNER JOIN` step — because those rows have `NULL` in the join key column, and `INNER JOIN` requires a match on both sides. The result would look correct for customers who have orders, but every customer with zero purchases would silently disappear from the output, violating the business requirement.

**5. How would you modify this to also show the most recently purchased product per customer?**

Add a subquery or CTE to find the last `order_date` per customer-product pair, then join back. Alternatively, add `MAX(o.order_date) AS last_order_date` to this query as a quick proxy for recency at the customer level:

```sql
SELECT
    c.contact_name,
    COUNT(DISTINCT p.product_id) AS distinct_products,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN products p ON p.product_id = od.product_id
GROUP BY c.contact_name, c.customer_id
ORDER BY distinct_products DESC;
```

## 9. Key Takeaway

Every link in a multi-table chain must stay `LEFT JOIN` to preserve no-match rows end to end, and `COUNT(column)` vs `COUNT(DISTINCT column)` is the difference between counting occurrences and counting unique values.

---
📄 **SQL File:** [`Q32_Customers_And_Distinct_Products_Purchased.sql`](./Q32_Customers_And_Distinct_Products_Purchased.sql)
