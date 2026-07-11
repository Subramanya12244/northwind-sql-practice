# Q41. Customers and Orders

**Category:** RIGHT JOIN
**Difficulty:** Easy

---

## Problem Statement

The sales team wants a report showing every order along with the customer who placed it. If an order somehow has no matching customer record, it should still appear in the report.

## Objective

Return all orders and their corresponding customer names, preserving every order even if it has no matching customer.

## Tables Used

- `customers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| order_id | Unique identifier of the order |
| contact_name | Name of the customer contact (NULL if no matching customer exists) |

**Sample output:**

| order_id | contact_name |
|----------|--------------|
| 10248 | Maria Anders |
| 10249 | Ana Trujillo |
| 10250 | NULL |

*(Sample values are illustrative. In the standard Northwind dataset, all orders have a valid customer — the NULL row demonstrates the RIGHT JOIN behaviour for data quality scenarios.)*

## Concepts Used

- RIGHT JOIN
- NULL Handling

## Why This Approach

**What RIGHT JOIN does:** `RIGHT JOIN` preserves every row from the **right-hand table** (`orders`) regardless of whether a match exists in the left-hand table (`customers`). For any order whose `customer_id` does not match any row in `customers`, the columns from `customers` (including `contact_name`) are filled with `NULL` — the order still appears in the result.

**Why `customers` is on the LEFT and `orders` is on the RIGHT:** the table you want to preserve completely is `orders` — that is the "right" table in this `RIGHT JOIN`. `customers` is the lookup table whose columns may be `NULL` when no match is found. The join condition `ON o.customer_id = c.customer_id` then links the two tables on the shared key.

**RIGHT JOIN vs LEFT JOIN — two ways to write the same logic:** this query is functionally equivalent to swapping the table order and using `LEFT JOIN`:

```sql
-- Equivalent LEFT JOIN version:
SELECT o.order_id, c.contact_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

Both produce identical results. The choice between them is purely about which table you place first in `FROM`. Most SQL developers prefer `LEFT JOIN` for readability (the "primary" table on the left is a more natural reading order), but `RIGHT JOIN` is equally valid and worth knowing for completeness.

**When would a NULL `contact_name` actually occur?** In a well-maintained relational database with foreign key constraints enforced, it shouldn't — `orders.customer_id` would be constrained to reference a valid `customers.customer_id`. In practice, NULL rows in this result indicate a data quality problem: orphaned orders whose customer record was deleted, or orders imported without a matching customer. This query is useful precisely for surfacing such anomalies.

## Common Mistakes

- Confusing which table is "right" — the right table is the one whose rows are **all preserved**; the left table is the one that may contribute NULLs.
- Swapping the table positions without changing `LEFT` to `RIGHT` (or vice versa), producing an `INNER JOIN` or the wrong outer join behaviour.
- Assuming `RIGHT JOIN` is inherently different in power from `LEFT JOIN` — every `RIGHT JOIN` can be rewritten as a `LEFT JOIN` by reversing the table order.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. What is the difference between LEFT JOIN and RIGHT JOIN, and when would you choose one over the other?**

Functionally, they are mirror images. `LEFT JOIN` preserves all rows from the left table; `RIGHT JOIN` preserves all rows from the right table. Any `RIGHT JOIN` can be rewritten as a `LEFT JOIN` by swapping the table order, and vice versa. Most developers default to `LEFT JOIN` because it reads more naturally — the "primary" or "driving" table is listed first in `FROM`, and the lookup table follows in `JOIN`. `RIGHT JOIN` is useful when you're working with an existing query and want to add a new table that must be the preserved one, without restructuring the entire `FROM` clause.

**2. Rewrite this query using LEFT JOIN. What changes?**

Swap the table order in `FROM` and `JOIN`, and change `RIGHT JOIN` to `LEFT JOIN`:

```sql
SELECT o.order_id, c.contact_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

The result is identical. `orders` is now the left table (preserved completely) and `customers` is the right table (contributes NULL when no match exists).

**3. In the standard Northwind dataset, will any rows actually show NULL for `contact_name`? Why or why not?**

No — in standard Northwind, every order has a valid `customer_id` that references an existing customer record, so all orders find a match and no NULLs appear. The NULL scenario is demonstrated as a concept, not a real data state in this dataset. In production databases where foreign key constraints are not enforced (common in data warehouses or ETL pipelines), orphaned orders with no matching customer are a real possibility this query would correctly surface.

**4. How would you use this query to find orders with no matching customer — i.e. the data quality check?**

Add a `WHERE` filter on the customer column being NULL:

```sql
SELECT o.order_id, c.contact_name
FROM customers c
RIGHT JOIN orders o ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

This is the RIGHT JOIN equivalent of the anti-join pattern — returning only the unmatched rows from the right table, which represent orphaned orders.

**5. How does RIGHT JOIN relate to FULL OUTER JOIN?**

`FULL OUTER JOIN` is a superset of both `LEFT JOIN` and `RIGHT JOIN` — it preserves unmatched rows from *both* tables simultaneously. A `RIGHT JOIN` only preserves unmatched rows from the right table; unmatched rows from the left table are dropped. `FULL OUTER JOIN` is used when you want to see every row from both sides regardless of whether a match exists.

## Learning Outcomes

- Understand that `RIGHT JOIN` and `LEFT JOIN` are mirror images — any query written with one can be rewritten with the other by swapping table order.
- Recognise that `RIGHT JOIN` preserves the right table completely, filling NULLs for unmatched left-table columns.
- Know that `RIGHT JOIN` is practically useful for surfacing orphaned records and data quality issues in systems without enforced foreign key constraints.
- Build the habit of defaulting to `LEFT JOIN` for readability while being comfortable reading and writing `RIGHT JOIN` when encountered.

---

📄 **SQL File:** [`Q41_Customers_And_Orders.sql`](./Q41_Customers_And_Orders.sql)
