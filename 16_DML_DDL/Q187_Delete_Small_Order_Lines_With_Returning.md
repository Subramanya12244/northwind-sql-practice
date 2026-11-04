# Q187 · Delete Small Order Lines With Returning

> **Revision Card**
> **Category:** DML (DELETE … RETURNING) | **Difficulty:** Medium
> **Concepts:** DELETE · RETURNING · CTE · Aggregating Deleted Rows
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `RETURNING` output is unordered and only lists rows; aggregate it in an outer query to summarise the deletion.

## 1. Problem

A clean-up job removes order lines with quantity of 2 or less (sample shipments). Audit wants the deleted lines plus their value.

**Objective:** Delete `order_details` rows with `quantity <= 2` and return each deleted line with its net value. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| product_id | Product identifier |
| quantity | Deleted quantity |
| line_value | Net value of the deleted line, 2 dp |

| order_id | product_id | quantity | line_value |
|----------|------------|----------|------------|
| 10278 | 52 | 1 | 7.00 |
| 10279 | 46 | 1 | 12.00 |
| 10279 | 53 | 2 | 65.60 |
| 10280 | 40 | 1 | 18.40 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `DELETE FROM order_details WHERE quantity <= 2 RETURNING *` inside a CTE.
2. Compute the line value in the outer `SELECT`.
3. Order by the primary key `(order_id, product_id)`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH deleted AS (
    DELETE FROM order_details
    WHERE quantity <= 2
    RETURNING order_id, product_id, unit_price, quantity, discount
)
SELECT
    order_id,
    product_id,
    quantity,
    ROUND((unit_price * quantity * (1 - discount))::numeric, 2) AS line_value
FROM deleted
ORDER BY order_id, product_id;
```

## 6. Why This Works

`DELETE ... RETURNING` hands back the removed rows, giving an audit trail in the same statement. As a data-modifying CTE, those rows can be transformed, joined or aggregated by the outer query. Ordering by the composite primary key makes the output deterministic.

## 7. Common Pitfalls (generic)

- Deleting parent rows (`orders`) that are still referenced by `order_details` — the foreign key raises an error.
- Testing the `WHERE` clause only after deleting; run the `SELECT` version first.
- Expecting the outer query to see the table *after* the delete — all parts of a statement see the same snapshot; only the CTE's `RETURNING` reflects the change.

## 8. Interview Follow-ups

**1. `DELETE` vs `TRUNCATE`?**

`TRUNCATE` removes all rows quickly, cannot have `WHERE` or `RETURNING`, and does not fire row-level triggers.

**2. How do you archive and delete in one statement?**

`WITH d AS (DELETE ... RETURNING *) INSERT INTO archive SELECT * FROM d`.

**3. How do you delete orders together with their lines?**

Delete the lines first (or use `ON DELETE CASCADE` on the foreign key).

## 9. Key Takeaway

`WITH d AS (DELETE ... RETURNING ...) SELECT ... FROM d` lets you audit, summarise or archive exactly what was removed.

---
📄 **SQL File:** [`Q187_Delete_Small_Order_Lines_With_Returning.sql`](./Q187_Delete_Small_Order_Lines_With_Returning.sql)
