# Q42. Products and Suppliers

**Category:** RIGHT JOIN
**Difficulty:** Easy

---

## Problem Statement

The inventory team wants a report showing every product along with the supplier who provides it. If a product has no matching supplier record, it should still appear in the report.

## Objective

Return all products and their corresponding supplier names, preserving every product even if it has no matching supplier.

## Tables Used

- `suppliers`
- `products`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| product_name | Name of the product |
| supplier_name | Name of the supplying company (NULL if no matching supplier exists) |

**Sample output:**

| product_name | supplier_name |
|--------------|---------------|
| Chai | Exotic Liquids |
| Chang | Exotic Liquids |
| Product X | NULL |

*(Sample values are illustrative. In standard Northwind, all products have a valid supplier — the NULL row demonstrates the RIGHT JOIN behaviour for orphaned product records.)*

## Concepts Used

- RIGHT JOIN
- NULL Handling

## Why This Approach

**Why `suppliers` is on the LEFT and `products` is on the RIGHT:** the table to preserve completely is `products` — every product must appear in the output regardless of whether a matching supplier exists. Placing `products` as the right table in a `RIGHT JOIN` achieves exactly this. `suppliers` is the lookup table whose columns may come back NULL when a product has no matching supplier.

**Why this is structurally identical to Q41:** both questions follow the same pattern — "preserve all rows from table X, look up display name from table Y, show NULL if no match." Only the tables and join key change. Q41 preserves `orders` and looks up from `customers`; this question preserves `products` and looks up from `suppliers`.

**LEFT JOIN equivalent for clarity:**
```sql
-- Same result, more commonly written as:
SELECT p.product_name, s.company_name AS supplier_name
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id;
```

**When would `supplier_name` be NULL in practice?** If a supplier record is deleted from `suppliers` without first reassigning or deleting their products, those products become orphaned — still in the catalog with a `supplier_id` that references nothing. This query surfaces that data quality problem. In a properly constrained database, this shouldn't occur, but it's common in data warehouse environments where referential integrity isn't enforced at the database level.

## Common Mistakes

- Placing `products` on the left and `suppliers` on the right with `RIGHT JOIN` — this would preserve all suppliers (including those with no products), which is the opposite of the requirement.
- Confusing "preserve the right table" with "the more important table goes on the right" — the placement is a mechanical JOIN direction choice, not a value judgment.
- Using `INNER JOIN`, which would drop any product with no matching supplier entirely from the result.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. How would you rewrite this using LEFT JOIN instead of RIGHT JOIN?**

Swap the table order so `products` becomes the left (driving) table:

```sql
SELECT p.product_name, s.company_name AS supplier_name
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id;
```

The result is identical. Most SQL developers prefer this form — `products` as the left table is a more natural reading order when the intent is "all products with their supplier info."

**2. In your ER diagram, `products.supplier_id` is a foreign key to `suppliers.supplier_id`. Does that guarantee no NULLs in this result?**

Only if the foreign key constraint is actively enforced at the database level. If FK constraints are enforced, the database will reject any attempt to insert a product with a `supplier_id` that doesn't reference an existing supplier, making NULL results impossible. But in many real-world systems — particularly data warehouses, staging databases, or systems that migrated data from other sources — FK constraints are not enforced, and orphaned records are possible. The `RIGHT JOIN` pattern is a practical way to audit for such orphans.

**3. How would you find products with no matching supplier (the orphan detection query)?**

Add a `WHERE` clause filtering for NULL on the supplier side:

```sql
SELECT p.product_name, s.company_name AS supplier_name
FROM suppliers s
RIGHT JOIN products p ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;
```

This is the RIGHT JOIN anti-join pattern — the mirror of Q29's `LEFT JOIN ... WHERE ... IS NULL` approach.

**4. How would you extend this to also show each product's unit price and whether it is discontinued?**

Simply add those columns from `products` to the `SELECT` list — they come from the preserved (right) table and are always available:

```sql
SELECT
    p.product_name,
    s.company_name AS supplier_name,
    p.unit_price,
    p.discontinued
FROM suppliers s
RIGHT JOIN products p ON p.supplier_id = s.supplier_id
ORDER BY p.product_name;
```

## Learning Outcomes

- Reinforce that `RIGHT JOIN` always preserves the right-hand table, and that choosing which table goes on which side is the key decision when writing outer joins.
- Understand the practical use case for `RIGHT JOIN` — surfacing orphaned records where a foreign key reference has no corresponding parent row.
- Recognise that every `RIGHT JOIN` is mechanically interchangeable with a `LEFT JOIN` by reversing table order — the logic is identical, only the syntax differs.

---

📄 **SQL File:** [`Q42_Products_And_Suppliers.sql`](./Q42_Products_And_Suppliers.sql)
