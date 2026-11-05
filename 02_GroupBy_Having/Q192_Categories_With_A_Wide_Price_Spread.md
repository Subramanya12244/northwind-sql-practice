# Q192 · Categories With A Wide Price Spread

> **Revision Card**
> **Category:** GROUP BY & HAVING (Multiple Aggregate Conditions) | **Difficulty:** Medium
> **Concepts:** GROUP BY · HAVING · MIN · MAX · AVG · Multiple aggregate conditions
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Aggregate conditions belong in HAVING; WHERE runs before rows are grouped.

## 1. Problem

The pricing team wants to find categories that sell both budget and premium items, because those need two different promotion strategies.

**Objective:** List categories that contain at least one product under 10 and at least one product over 40, with the product count, cheapest and dearest price and the average price (2 dp), widest spread first.

**Tables:** `products`, `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category |
| product_count | Products in the category |
| min_price | Cheapest unit price |
| max_price | Most expensive unit price |
| avg_price | Average unit price, 2 dp |

| category_name | product_count | min_price | max_price | avg_price |
|---------------|---------------|-----------|-----------|-----------|
| Beverages | 12 | 4.50 | 263.50 | 37.98 |
| Meat/Poultry | 6 | 7.45 | 123.79 | 54.01 |
| Confections | 13 | 9.20 | 81.00 | 25.16 |
| Seafood | 12 | 6.00 | 62.50 | 20.68 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join products to categories and group by category.
2. Keep groups where MIN(unit_price) < 10 AND MAX(unit_price) > 40 (HAVING).
3. Order by the spread MAX − MIN, descending, then by name.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT c.category_name,
       COUNT(*)                     AS product_count,
       MIN(p.unit_price)            AS min_price,
       MAX(p.unit_price)            AS max_price,
       ROUND(AVG(p.unit_price), 2)  AS avg_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING MIN(p.unit_price) < 10
   AND MAX(p.unit_price) > 40
ORDER BY MAX(p.unit_price) - MIN(p.unit_price) DESC, c.category_name;
```

## 6. Why This Works

Both conditions are about the whole category, not single rows, so they must be checked after grouping with HAVING. A WHERE clause like `unit_price < 10 AND unit_price > 40` would look for one product that is both cheap and expensive, which never exists. ORDER BY can repeat the aggregate expression, because SELECT aliases can't be combined into expressions there.

## 7. Common Pitfalls (generic)

- Putting the price conditions in WHERE, which filters rows before grouping and returns nothing.
- Writing ORDER BY max_price - min_price: an alias can be used alone in ORDER BY, but not inside an expression.
- Using OR instead of AND, which returns every category with any cheap or any expensive product.

## 8. Interview Follow-ups

**1. How would you show which products are the cheapest and dearest in each category?**

Rank products within each category with ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY unit_price) and keep rank 1 from both directions, or use a LATERAL subquery per category.

**2. How would you make the thresholds relative instead of fixed?**

Compare with the overall price distribution, for example HAVING MIN(unit_price) < (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY unit_price) FROM products).

**3. Why not filter with a subquery per category?**

A correlated subquery per category works, but one GROUP BY pass with HAVING reads the table once and is easier to read.

## 9. Key Takeaway

Conditions on groups go in HAVING, and several aggregate conditions can be combined there with AND.

---
📄 **SQL File:** [`Q192_Categories_With_A_Wide_Price_Spread.sql`](./Q192_Categories_With_A_Wide_Price_Spread.sql)
