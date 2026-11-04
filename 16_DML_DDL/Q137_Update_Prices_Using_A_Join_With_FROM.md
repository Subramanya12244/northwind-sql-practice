# Q137 · Update Prices Using A Join With FROM

> **Revision Card**
> **Category:** DML (UPDATE … FROM) | **Difficulty:** Medium
> **Concepts:** UPDATE … FROM · Join Condition in WHERE · RETURNING · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** In `UPDATE ... FROM`, the join condition goes in `WHERE`; missing it updates every product once per category row.

## 1. Problem

Seafood costs went up 10%. Category is stored by name in `categories`, so the update must join to find the products to change.

**Objective:** Increase `unit_price` by 10% (2 dp) for every product in the `Seafood` category, and return the product, category name, and new price. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `products`, `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product identifier |
| product_name | Product name |
| category_name | Category name (from the joined table) |
| new_price | Price after the increase |

| product_id | product_name | category_name | new_price |
|------------|--------------|---------------|-----------|
| 10 | Ikura | Seafood | 34.10 |
| 13 | Konbu | Seafood | 6.60 |
| 18 | Carnarvon Tigers | Seafood | 68.75 |
| 30 | Nord-Ost Matjeshering | Seafood | 28.48 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `UPDATE products p SET ... FROM categories c`.
2. `WHERE c.category_id = p.category_id AND c.category_name = 'Seafood'`.
3. `RETURNING` columns from both tables; wrap in a CTE and order by `product_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH updated AS (
    UPDATE products p
    SET unit_price = ROUND(p.unit_price * 1.10, 2)
    FROM categories c
    WHERE c.category_id   = p.category_id
      AND c.category_name = 'Seafood'
    RETURNING p.product_id, p.product_name, c.category_name, p.unit_price AS new_price
)
SELECT product_id, product_name, category_name, new_price
FROM updated
ORDER BY product_id;
```

## 6. Why This Works

PostgreSQL's `UPDATE ... FROM` joins the target table to other tables; the `WHERE` clause holds both the join condition and the filter. Only target rows with a matching joined row are updated. `RETURNING` can reference columns from the `FROM` tables, so the category name is returned without another join.

## 7. Common Pitfalls (generic)

- Repeating the target table in `FROM` (`FROM products p, categories c`) — that creates a second, unrelated copy and updates every row.
- Omitting the join condition — every product matches the Seafood row.
- If the join matches a target row more than once, only one arbitrary joined row is used for the update.

## 8. Interview Follow-ups

**1. Write it with a subquery instead.**

`UPDATE products SET unit_price = ROUND(unit_price * 1.10, 2) WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'Seafood')`.

**2. What is the SQL Server syntax?**

`UPDATE p SET ... FROM products p JOIN categories c ON ...` — the join is written with `JOIN ... ON`.

**3. How do you delete with a join in PostgreSQL?**

`DELETE FROM target t USING other o WHERE o.id = t.id AND ...`.

## 9. Key Takeaway

`UPDATE target SET ... FROM other WHERE join_condition AND filter` — never list the target in `FROM` again.

---
📄 **SQL File:** [`Q137_Update_Prices_Using_A_Join_With_FROM.sql`](./Q137_Update_Prices_Using_A_Join_With_FROM.sql)
