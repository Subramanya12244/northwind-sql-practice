# Q51. Customers and Orders (FULL OUTER JOIN)

**Category:** FULL OUTER JOIN
**Difficulty:** Medium

---

## Problem Statement

Generate a report that displays all customers and all orders. The report should include customers who have placed orders, customers who have never placed an order, and orders that do not have a matching customer.

## Objective

Return the customer name and order ID for every customer and every order — no row from either table should be excluded.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Name of the customer contact (NULL if the order has no matching customer) |
| order_id | Unique identifier of the order (NULL if the customer has never placed an order) |

**Sample output:**

| contact_name | order_id |
|--------------|----------|
| Maria Anders | 10248 |
| Ana Trujillo | 10249 |
| FISSA Fabrica Inter. Salchichas S.A. | NULL |
| NULL | 11080 |

*(In standard Northwind, all orders have valid customers and all customers appear in one of the three row types — the NULL rows demonstrate FULL OUTER JOIN behaviour for data quality scenarios.)*

## Concepts Used

- FULL OUTER JOIN
- NULL Handling

## Why This Approach

**Why FULL OUTER JOIN and not LEFT or RIGHT JOIN:**

| Join Type | Preserves | Drops |
|-----------|-----------|-------|
| `LEFT JOIN customers → orders` | All customers | Unmatched orders |
| `RIGHT JOIN customers → orders` | All orders | Unmatched customers |
| `FULL OUTER JOIN` | All customers AND all orders | Nothing |

This report has three distinct row types in the result:
1. **Matched rows** — a customer who has placed at least one order (both sides populated)
2. **Left-only rows** — a customer who has never placed an order (`order_id = NULL`)
3. **Right-only rows** — an order with no matching customer (`contact_name = NULL`)

Only `FULL OUTER JOIN` produces all three simultaneously. `LEFT JOIN` would miss type 3; `RIGHT JOIN` would miss type 2.

**Why the join condition is `ON o.customer_id = c.customer_id`:** this links each order to its customer via the foreign key. Rows where the key matches produce populated values on both sides. Rows with no match on the left (customer with no orders) get `NULL` for all `orders` columns; rows with no match on the right (order with no customer) get `NULL` for all `customers` columns.

**When does `contact_name = NULL` occur in practice?** When an order's `customer_id` references a customer record that has been deleted or never existed. This is an orphaned order — a data integrity anomaly that `FULL OUTER JOIN` surfaces that neither `LEFT JOIN` nor `RIGHT JOIN` alone would catch.

## Common Mistakes

- Using `LEFT JOIN` and missing orphaned orders (right-only rows).
- Using `RIGHT JOIN` and missing customers with no orders (left-only rows).
- Expecting `FULL OUTER JOIN` to deduplicate rows — it does not; a customer with 10 orders produces 10 matched rows, not 1.
- Confusing `FULL OUTER JOIN` with `CROSS JOIN` — `CROSS JOIN` produces every combination of every row (N × M rows); `FULL OUTER JOIN` matches on a key and only produces unmatched rows as NULLs, not all combinations.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. What is the difference between LEFT JOIN, RIGHT JOIN, and FULL OUTER JOIN? When would you use each?**

`LEFT JOIN` preserves all rows from the left table and fills NULL for unmatched right-table columns. `RIGHT JOIN` is the mirror — preserves all rows from the right table. `FULL OUTER JOIN` preserves all rows from both tables simultaneously: matched rows appear normally, unmatched left-only rows get NULLs on the right, and unmatched right-only rows get NULLs on the left. Use `LEFT JOIN` when you want all entities from one side and optionally their related data. Use `FULL OUTER JOIN` when you want a complete reconciliation where neither side should lose rows — such as comparing two data sources, auditing referential integrity, or producing a union-like report across two independent tables.

**2. How would you use this result to find both customers with no orders AND orders with no customer in one query?**

Add a `WHERE` clause filtering for either NULL side:

```sql
SELECT c.contact_name, o.order_id
FROM customers c
FULL OUTER JOIN orders o ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL   -- orphaned orders
   OR o.order_id IS NULL;     -- customers with no orders
```

This is the FULL OUTER JOIN anti-join — returning only the unmatched rows from both sides simultaneously.

**3. How does FULL OUTER JOIN relate to UNION of LEFT JOIN and RIGHT JOIN?**

A `FULL OUTER JOIN` is logically equivalent to a `LEFT JOIN` unioned with a `RIGHT JOIN` (with duplicates removed on matched rows):

```sql
SELECT c.contact_name, o.order_id
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
UNION
SELECT c.contact_name, o.order_id
FROM customers c RIGHT JOIN orders o ON o.customer_id = c.customer_id;
```

This `UNION`-based approach produces the same result as `FULL OUTER JOIN` in databases that don't support `FULL OUTER JOIN` directly (e.g. MySQL before version 8.0). In PostgreSQL, `FULL OUTER JOIN` is native and more efficient.

**4. If a customer has placed 5 orders, how many rows does that customer contribute to the FULL OUTER JOIN result?**

Five rows — one per order. `FULL OUTER JOIN` (like all joins) multiplies rows when there are multiple matches. The "full outer" part only affects *unmatched* rows — those appear once with NULLs on the unmatched side. Matched rows behave exactly like `INNER JOIN` rows, one per matching pair.

**5. How is FULL OUTER JOIN different from CROSS JOIN?**

`CROSS JOIN` produces every possible combination of every row from both tables — N × M rows with no join condition. `FULL OUTER JOIN` matches rows on a specified key condition, producing one row per matching pair (like `INNER JOIN`) plus NULL-padded rows for any unmatched rows on either side. `FULL OUTER JOIN` between a 91-row customers table and an 830-row orders table produces 830 + some NULL rows; `CROSS JOIN` would produce 91 × 830 = 75,530 rows.

## Learning Outcomes

- Understand that `FULL OUTER JOIN` is the only join type that preserves unmatched rows from both tables simultaneously — making it the correct choice for reconciliation, data quality auditing, and any report where neither side should lose rows.
- Know the three row types in a `FULL OUTER JOIN` result: matched, left-only (right side NULL), and right-only (left side NULL).
- Recognise that `FULL OUTER JOIN` = `LEFT JOIN UNION RIGHT JOIN` — a useful mental model and a practical workaround for databases that don't support `FULL OUTER JOIN` natively.

---

📄 **SQL File:** [`Q51_Customers_And_Orders_FULL_OUTER_JOIN.sql`](./Q51_Customers_And_Orders_FULL_OUTER_JOIN.sql)
