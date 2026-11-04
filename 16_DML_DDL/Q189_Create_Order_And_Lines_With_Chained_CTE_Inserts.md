# Q189 · Create Order And Lines With Chained CTE Inserts

> **Revision Card**
> **Category:** DML (Data-Modifying CTEs) | **Difficulty:** Hard
> **Concepts:** Data-Modifying CTE · INSERT … SELECT · RETURNING · CROSS JOIN · Current Price Lookup
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Sub-statements in one `WITH` cannot see each other's changes in the table — pass data between them through `RETURNING`.

## 1. Problem

The web shop places an order for customer `ALFKI`, handled by employee 1 and shipped via shipper 1, with 10 × Chai (product 1) and 5 × Chang (product 2) at current list prices. The order header and its lines must be created in one statement.

**Objective:** In one statement, insert the order header, insert its two lines using the new `order_id` and current product prices, and return the lines with their totals. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `orders`, `order_details`, `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_id | New order id |
| product_id | Product identifier |
| product_name | Product name |
| quantity | Quantity ordered |
| unit_price | Price copied from `products` |
| line_total | quantity × unit_price |

| order_id | product_id | product_name | quantity | unit_price | line_total |
|----------|------------|--------------|----------|------------|------------|
| 10349 | 1 | Chai | 10 | 18.00 | 180.00 |
| 10349 | 2 | Chang | 5 | 19.00 | 95.00 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `new_order`: `INSERT INTO orders ... RETURNING order_id`.
2. CTE `lines`: `INSERT INTO order_details SELECT new_order.order_id, p.product_id, p.unit_price, v.qty, 0 FROM new_order CROSS JOIN (VALUES ...) v JOIN products p ...  RETURNING *`.
3. Final `SELECT` joins `lines` to `products` for names and orders by `product_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH new_order AS (
    INSERT INTO orders (customer_id, employee_id, order_date, required_date, ship_via, freight)
    VALUES ('ALFKI', 1, DATE '1998-05-06', DATE '1998-06-03', 1, 12.50)
    RETURNING order_id
),
lines AS (
    INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
    SELECT n.order_id, p.product_id, p.unit_price, v.qty, 0
    FROM new_order n
    CROSS JOIN (VALUES (1, 10), (2, 5)) AS v(product_id, qty)
    JOIN products p ON p.product_id = v.product_id
    RETURNING order_id, product_id, unit_price, quantity
)
SELECT
    l.order_id,
    l.product_id,
    p.product_name,
    l.quantity,
    l.unit_price,
    l.quantity * l.unit_price AS line_total
FROM lines l
JOIN products p ON p.product_id = l.product_id
ORDER BY l.product_id;
```

## 6. Why This Works

Data-modifying CTEs run as one statement and one snapshot. The header insert's `RETURNING order_id` is the only way the second CTE can learn the new id, because the new `orders` row is not visible to other parts of the same statement through the table. `CROSS JOIN` of the single new-order row with the `VALUES` list produces one row per line item, and the join to `products` copies the current price. The final query reads the `RETURNING` rows of `lines`.

## 7. Common Pitfalls (generic)

- Trying to `SELECT MAX(order_id) FROM orders` inside the same statement — it does not see the new row.
- Hard-coding the order id and colliding with the sequence.
- Forgetting that the final `SELECT` must read from the CTE, not from `order_details`, to see the inserted lines.

## 8. Interview Follow-ups

**1. Are all CTEs executed even if not referenced?**

Yes — data-modifying CTEs always run exactly once, whether or not the main query reads them.

**2. In what order do the sub-statements run?**

The order is unspecified; dependencies are expressed only through `RETURNING` data flowing from one CTE into another.

**3. How would you also update stock?**

Add a third CTE: `UPDATE products p SET units_in_stock = units_in_stock - l.quantity FROM lines l WHERE l.product_id = p.product_id`.

## 9. Key Takeaway

Chain inserts with CTEs and pass generated keys through `RETURNING` — one atomic statement for header and lines.

---
📄 **SQL File:** [`Q189_Create_Order_And_Lines_With_Chained_CTE_Inserts.sql`](./Q189_Create_Order_And_Lines_With_Chained_CTE_Inserts.sql)
