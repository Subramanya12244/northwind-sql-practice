# Q55. Customers and Total Orders (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Hard

---

## Problem Statement

Generate a report showing all customers and the total number of orders they have placed. The report should include customers who have placed orders, customers who have never placed an order, and orders that do not have a matching customer.

## Objective

Return the customer name and total number of orders — covering all three row types that a FULL OUTER JOIN produces, including a row for orphaned orders where `contact_name = NULL`.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer (NULL for orphaned orders with no matching customer) |
| total_orders | Total number of orders placed (0 for customers with no orders, >0 for orphaned-order group) |

**Sample output:**

| contact_name | total_orders |
|--------------|--------------|
| Maria Anders | 12 |
| Ana Trujillo | 8 |
| FISSA Fabrica Inter. Salchichas S.A. | 0 |
| NULL | 1 |

The `NULL | 1` row means: there is 1 order in the system whose `customer_id` does not match any customer record.

## Concepts Used

- FULL OUTER JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling
- NULL grouping behaviour

## Why This Approach

**Why FULL OUTER JOIN:** three row types are required:
1. Customers with orders — both sides populated, `COUNT > 0`
2. Customers with no orders — right side NULL, `COUNT = 0`
3. Orphaned orders (no matching customer) — left side NULL, `COUNT > 0`

Only `FULL OUTER JOIN` produces all three. `LEFT JOIN` misses type 3; `RIGHT JOIN` misses type 2.

**Why `COUNT(o.order_id)` and not `COUNT(*)`:** for customers with no orders (type 2), the `FULL OUTER JOIN` produces one NULL-padded row with `o.order_id = NULL`. `COUNT(o.order_id)` counts only non-NULL values, correctly returning 0. `COUNT(*)` would count the NULL-padded row as 1, incorrectly implying one order exists.

**How NULL groups behave with GROUP BY:** when `GROUP BY c.customer_id, c.contact_name` is applied, all rows where `c.customer_id IS NULL` (i.e. orphaned orders — type 3 rows) collapse into a **single NULL group**. This means if there are 5 orphaned orders belonging to 5 different unknown customers, they all appear as one row: `NULL | 5`. This is correct and expected — PostgreSQL treats NULL as equal to NULL for grouping purposes (`NULL = NULL` is true in `GROUP BY`, even though it's NULL/unknown in `WHERE`). The expected output's `NULL | 1` row represents all orphaned orders combined.

**This is the key difference from the LEFT JOIN version (Q25):** Q25 only showed customers and their order counts — no NULL customer row could appear because `customers` was fully preserved on the left and there was no mechanism to surface orders without customers. `FULL OUTER JOIN` adds the third row type, surfacing data quality anomalies that `LEFT JOIN` silently hides.

## Common Mistakes

- Using `COUNT(*)` instead of `COUNT(o.order_id)` — returns 1 instead of 0 for customers with no orders (the NULL-padded left-join row is counted as a real row by `COUNT(*)`).
- Expecting one NULL row per orphaned order — `GROUP BY` collapses all NULL-customer-id rows into a single NULL group, so there is always exactly one NULL row regardless of how many orphaned orders exist.
- Using `LEFT JOIN` and missing the orphaned orders entirely — the whole point of this question versus Q25 is capturing that third row type.
- Grouping by `c.contact_name` alone — risks merging customers with identical names, and also affects how the NULL group is keyed.

## Difficulty

**Hard**

## Interview Follow-up Questions

**1. Why does `COUNT(o.order_id)` return 0 for customers with no orders, but `COUNT(*)` would return 1?**

For a customer with no orders, the `FULL OUTER JOIN` produces exactly one output row with all `orders` columns set to NULL — including `o.order_id`. `COUNT(o.order_id)` counts only non-NULL values of that column, so for a row where `o.order_id IS NULL`, it contributes 0 to the count for that group. `COUNT(*)` counts every row regardless of NULLs — it sees that one NULL-padded row and counts it as 1, incorrectly suggesting one order exists. This is the same `COUNT(*) vs COUNT(column)` distinction as Q25/Q35, but it matters even more with `FULL OUTER JOIN` because there are now two types of NULL rows (customer-side NULLs and order-side NULLs) that behave differently.

**2. What does the `NULL | total_orders` row in the result actually mean, and how many NULL rows can appear?**

The `NULL | total_orders` row represents all orders in the `orders` table whose `customer_id` does not match any row in the `customers` table — orphaned orders. There is always exactly **one** such NULL row in the output, regardless of how many orphaned orders exist, because `GROUP BY c.customer_id` groups all NULL `customer_id` values together. PostgreSQL treats NULL as equal to NULL for `GROUP BY` purposes — so all orphaned orders collapse into one group. The `COUNT(o.order_id)` for that group gives the total number of orphaned orders.

**3. How does `GROUP BY` treat NULL values, and why is this different from how `WHERE` treats NULL?**

In `GROUP BY`, NULL is treated as a single grouping key — all rows with `NULL` in the grouped column are placed in the same group together. This is a deliberate SQL design choice for grouping semantics. In `WHERE` (and `JOIN ON`) conditions, `NULL = NULL` evaluates to `NULL` (unknown), not `TRUE` — so `WHERE customer_id = NULL` would never match any row; you need `WHERE customer_id IS NULL`. The distinction is: `GROUP BY` intentionally groups NULLs together; `WHERE`/`JOIN ON` do not equate NULLs. Understanding this asymmetry is important for correctly interpreting `FULL OUTER JOIN` + `GROUP BY` results.

**4. How would you separate the NULL customer row from regular rows — showing it with a label like "Orphaned Orders" rather than NULL?**

Use `COALESCE` to replace the NULL `contact_name` with a descriptive label:

```sql
SELECT
    COALESCE(c.contact_name, 'Orphaned Orders') AS contact_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
FULL OUTER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.contact_name
ORDER BY total_orders DESC;
```

`COALESCE(c.contact_name, 'Orphaned Orders')` substitutes the NULL display value with a meaningful label, making the report more readable for non-technical stakeholders.

**5. How does this query differ from Q25 (LEFT JOIN version — Customers and Order Count)?**

Q25 used `LEFT JOIN customers → orders`, preserving all customers but making it impossible for orders with no matching customer to appear. Only types 1 and 2 rows existed. This query uses `FULL OUTER JOIN`, adding type 3 rows — orphaned orders — as a NULL-named group. The practical difference: Q25 answers "how many orders has each customer placed?" whereas this query answers "how many orders has each customer placed, AND are there any orders with no customer at all?" The FULL OUTER JOIN version is the data-quality-aware version of the same report.

## Learning Outcomes

- Understand how `GROUP BY` handles NULL values — grouping all NULLs together into a single group, producing exactly one NULL row regardless of how many orphaned records exist.
- Know why `COUNT(column)` is always correct over `COUNT(*)` in `FULL OUTER JOIN` aggregation — the presence of two types of NULL rows (both sides) makes the distinction even more critical than in simple LEFT/RIGHT JOIN queries.
- Recognise the three-row-type structure of `FULL OUTER JOIN + GROUP BY` results and be able to explain what each type means in business terms.
- Understand the asymmetry between `GROUP BY` (treats `NULL = NULL` as same group) and `WHERE`/`JOIN ON` (treats `NULL = NULL` as unknown/false) — a fundamental SQL semantics point.

---

📄 **SQL File:** [`Q55_Customers_And_Total_Orders_FULL_OUTER_JOIN.sql`](./Q55_Customers_And_Total_Orders_FULL_OUTER_JOIN.sql)
