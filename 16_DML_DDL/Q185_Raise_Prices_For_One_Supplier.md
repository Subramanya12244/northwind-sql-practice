# Q185 · Raise Prices For One Supplier

> **Revision Card**
> **Category:** DML (UPDATE … RETURNING) | **Difficulty:** Easy
> **Concepts:** UPDATE · SET Expression · WHERE · RETURNING · ROUND
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** An `UPDATE` without `WHERE` changes every row in the table.

## 1. Problem

Supplier 1 (Exotic Liquids) announced a 5% price increase. Update its products and show the new prices.

**Objective:** Increase `unit_price` by 5% (rounded to 2 dp) for products of `supplier_id = 1`, and return product id, name and new price. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product identifier |
| product_name | Product name |
| new_price | Price after the 5% increase |

| product_id | product_name | new_price |
|------------|--------------|-----------|
| 1 | Chai | 18.90 |
| 30 | Nord-Ost Matjeshering | 27.18 |
| 59 | Raclette Courdavault | 57.75 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `UPDATE products SET unit_price = ROUND(unit_price * 1.05, 2)`.
2. Restrict with `WHERE supplier_id = 1`.
3. `RETURNING` the new price; wrap in a CTE and order by `product_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH updated AS (
    UPDATE products
    SET unit_price = ROUND(unit_price * 1.05, 2)
    WHERE supplier_id = 1
    RETURNING product_id, product_name, unit_price AS new_price
)
SELECT product_id, product_name, new_price
FROM updated
ORDER BY product_id;
```

## 6. Why This Works

`SET col = expression` may reference the column's current value, so `unit_price * 1.05` uses the old price. `RETURNING` shows the row *after* the update. `ROUND(..., 2)` keeps the value inside the `NUMERIC(10,2)` scale explicitly instead of relying on implicit rounding.

## 7. Common Pitfalls (generic)

- Forgetting the `WHERE` clause — every product gets the increase.
- Running the statement twice and compounding the increase (5% then another 5%).
- Expecting `RETURNING` to show the old value — in PostgreSQL 16 it shows the new row only.

## 8. Interview Follow-ups

**1. How can you see the old price too?**

Use a self-join in the UPDATE: `UPDATE products p SET ... FROM products old WHERE old.product_id = p.product_id ... RETURNING old.unit_price, p.unit_price` (PostgreSQL 18 also adds `RETURNING OLD.*`).

**2. How do you test an UPDATE safely?**

Run it inside `BEGIN; ... ROLLBACK;` or first run the equivalent `SELECT` with the same `WHERE`.

**3. How would you cap the price at 100?**

`SET unit_price = LEAST(ROUND(unit_price * 1.05, 2), 100)`.

## 9. Key Takeaway

`UPDATE ... SET col = f(col) WHERE ... RETURNING` — always scope with `WHERE` and verify with `RETURNING`.

---
📄 **SQL File:** [`Q185_Raise_Prices_For_One_Supplier.sql`](./Q185_Raise_Prices_For_One_Supplier.sql)
