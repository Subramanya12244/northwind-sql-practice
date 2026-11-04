# Q142 · Add Column And Check Constraint To Products

> **Revision Card**
> **Category:** DDL (ALTER TABLE / Constraints) | **Difficulty:** Hard
> **Concepts:** ALTER TABLE ADD COLUMN · CHECK Constraint · UPDATE with CASE · NOT NULL · pg_constraint
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Adding a `NOT NULL` constraint fails if existing rows are NULL — backfill first, then set the constraint.

## 1. Problem

The catalogue team wants a stored `price_band` column on `products`, always filled with one of three allowed values, and a guarantee that prices are never negative.

**Objective:** Add a `price_band` column, backfill it with `CASE`, make it `NOT NULL` with a `CHECK` on the allowed values, add a `CHECK (unit_price >= 0)` constraint, and return the product count per band. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| price_band | Budget / Mid-range / Premium |
| product_count | Products in the band |
| min_price | Lowest price in the band |

| price_band | product_count | min_price |
|------------|---------------|-----------|
| Budget | 39 | 2.50 |
| Mid-range | 31 | 20.00 |
| Premium | 7 | 53.00 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `ALTER TABLE products ADD COLUMN price_band VARCHAR(10)`.
2. `UPDATE products SET price_band = CASE ... END` to backfill.
3. `ALTER COLUMN price_band SET NOT NULL` and add `CHECK (price_band IN (...))` and `CHECK (unit_price >= 0)`.
4. `SELECT` count and min price per band ordered by `min_price`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
ALTER TABLE products ADD COLUMN price_band VARCHAR(10);

UPDATE products
SET price_band = CASE
                     WHEN unit_price < 20 THEN 'Budget'
                     WHEN unit_price < 50 THEN 'Mid-range'
                     ELSE 'Premium'
                 END;

ALTER TABLE products
    ALTER COLUMN price_band SET NOT NULL,
    ADD CONSTRAINT chk_products_price_band CHECK (price_band IN ('Budget', 'Mid-range', 'Premium')),
    ADD CONSTRAINT chk_products_unit_price_nonneg CHECK (unit_price >= 0);

SELECT
    price_band,
    COUNT(*)        AS product_count,
    MIN(unit_price) AS min_price
FROM products
GROUP BY price_band
ORDER BY min_price;
```

## 6. Why This Works

A new column starts as NULL for every row, so it must be backfilled before `NOT NULL` can be enforced. One `ALTER TABLE` can carry several actions, which PostgreSQL validates together against existing data — if any row violates a `CHECK`, the whole statement fails. The final `SELECT` proves every row received a valid band.

## 7. Common Pitfalls (generic)

- Adding `NOT NULL` before the backfill — error: column "price_band" of relation "products" contains null values.
- A `CHECK` that existing data violates fails immediately; use `NOT VALID` then `VALIDATE CONSTRAINT` to add it without a long lock.
- A stored derived column can drift when `unit_price` changes later — consider a generated column instead.

## 8. Interview Follow-ups

**1. How would you keep `price_band` always in sync?**

Use a generated column: `ADD COLUMN price_band text GENERATED ALWAYS AS (CASE ... END) STORED`.

**2. How do you list a table's constraints?**

`SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'products'::regclass`.

**3. What happens with a CHECK and a NULL value?**

A CHECK passes when its expression is NULL, so `CHECK (unit_price >= 0)` does not reject NULL prices — add `NOT NULL` for that.

## 9. Key Takeaway

Add column → backfill → enforce (`NOT NULL`, `CHECK`) — constraints are validated against existing rows when added.

---
📄 **SQL File:** [`Q142_Add_Column_And_Check_Constraint_To_Products.sql`](./Q142_Add_Column_And_Check_Constraint_To_Products.sql)
