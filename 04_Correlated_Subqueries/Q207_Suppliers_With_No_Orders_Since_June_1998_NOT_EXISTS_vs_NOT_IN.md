# Q207 · Suppliers With No Orders Since June 1998 (NOT EXISTS vs NOT IN)

> **Revision Card**
> **Category:** Correlated Subqueries (Anti-Join, NULL-Safe) | **Difficulty:** Hard
> **Concepts:** NOT EXISTS · Anti-join · NOT IN NULL trap · Multi-table correlated subquery · Sargable date filter
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** NOT IN returns no rows if the subquery yields a NULL; NOT EXISTS has no such trap and plans as an anti-join.

## 1. Problem

Procurement wants to review suppliers whose products haven't been ordered since 1 June 1998.

**Objective:** List suppliers none of whose products appear on an order dated on or after 1998-06-01, by supplier id.

**Tables:** `suppliers`, `products`, `order_details`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| supplier_id | Supplier |
| company_name | Supplier name |

| supplier_id | company_name |
|-------------|--------------|
| 1 | Exotic Liquids |
| 5 | Cooperativa de Quesos |
| 7 | Pavlova, Ltd. |
| 12 | Plutzer Lebensmittel |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. For each supplier, look for any order line of their products with order_date >= '1998-06-01'.
2. Keep suppliers where that search finds nothing (NOT EXISTS).
3. Order by supplier_id.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT s.supplier_id, s.company_name
FROM suppliers s
WHERE NOT EXISTS (
    SELECT 1
    FROM products p
    JOIN order_details d ON d.product_id = p.product_id
    JOIN orders o ON o.order_id = d.order_id
    WHERE p.supplier_id = s.supplier_id
      AND o.order_date >= DATE '1998-06-01'
)
ORDER BY s.supplier_id;
```

## 6. Why This Works

An anti-join keeps rows with no match. NOT EXISTS expresses it directly and PostgreSQL plans it as a hash or merge anti-join. The equivalent NOT IN (SELECT supplier_id …) silently returns nothing if any value in the subquery is NULL, because x NOT IN (…, NULL) is never true. The date is compared as a plain range on the column, so an index on order_date can be used.

## 7. Common Pitfalls (generic)

- NOT IN with a nullable subquery column, which can return zero rows.
- Filtering with EXTRACT(YEAR FROM order_date) = 1998 AND EXTRACT(MONTH …) >= 6, which can't use an index on order_date.
- LEFT JOIN … WHERE x IS NULL with the date condition in WHERE instead of ON, which turns it back into an inner join.

## 8. Interview Follow-ups

**1. Rewrite it as LEFT JOIN anti-join.**

LEFT JOIN the recent order lines (date condition in ON) and keep rows where the joined id IS NULL.

**2. How would you check the plan?**

Run EXPLAIN and look for Hash Anti Join or Nested Loop Anti Join.

**3. When is NOT IN safe?**

When the subquery column is NOT NULL (or you add WHERE col IS NOT NULL).

## 9. Key Takeaway

Prefer NOT EXISTS for 'has no matching row': NULL-safe and planned as an anti-join.

---
📄 **SQL File:** [`Q207_Suppliers_With_No_Orders_Since_June_1998_NOT_EXISTS_vs_NOT_IN.sql`](./Q207_Suppliers_With_No_Orders_Since_June_1998_NOT_EXISTS_vs_NOT_IN.sql)
