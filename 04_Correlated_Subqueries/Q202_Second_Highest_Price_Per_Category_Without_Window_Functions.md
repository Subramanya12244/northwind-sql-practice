# Q202 · Second Highest Price Per Category Without Window Functions

> **Revision Card**
> **Category:** Correlated Subqueries (Nth Value by Counting) | **Difficulty:** Hard
> **Concepts:** Correlated subquery · COUNT(DISTINCT) · Nth highest value · Ties
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** 'Exactly one distinct price above it' means second highest; COUNT(DISTINCT) handles ties.

## 1. Problem

An interviewer asks for the second most expensive product in each category, but without window functions.

**Objective:** For each category, list the product(s) priced at the second-highest distinct price, with the price, by category and product name.

**Tables:** `products`, `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category |
| product_name | Product at the second-highest price |
| unit_price | That price |

| category_name | product_name | unit_price |
|---------------|--------------|------------|
| Beverages | Ipoh Coffee | 46.00 |
| Condiments | Northwoods Cranberry Sauce | 40.00 |
| Confections | Tarte au sucre | 49.30 |
| Dairy Products | Queso Manchego La Pastora | 38.00 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. For each product, count the distinct prices in its category that are higher than its own.
2. Keep products where that count is exactly 1.
3. Join categories for the name and order by category, product.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT c.category_name, p.product_name, p.unit_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE 1 = (
    SELECT COUNT(DISTINCT p2.unit_price)
    FROM products p2
    WHERE p2.category_id = p.category_id
      AND p2.unit_price > p.unit_price
)
ORDER BY c.category_name, p.product_name;
```

## 6. Why This Works

A product has the Nth highest price when exactly N − 1 distinct prices in its category are higher. The correlated subquery computes that count for each product. COUNT(DISTINCT) makes ties at the top count once, so two products sharing the highest price don't push the real second price to third.

## 7. Common Pitfalls (generic)

- COUNT(*) instead of COUNT(DISTINCT), which mishandles ties at the top price.
- Using >= in the subquery, which counts the product itself.
- Using LIMIT 1 OFFSET 1 overall, which finds the second price in the whole table, not per category.

## 8. Interview Follow-ups

**1. How would you write it with a window function?**

DENSE_RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) = 2.

**2. What if a category has only one price?**

No product has exactly one higher price, so the category doesn't appear; LEFT JOIN from categories to show it with NULL.

**3. How does this scale?**

The subquery runs per product; an index on (category_id, unit_price) helps, but window functions read the table once.

## 9. Key Takeaway

Nth highest without windows: count the distinct higher values with a correlated subquery.

---
📄 **SQL File:** [`Q202_Second_Highest_Price_Per_Category_Without_Window_Functions.sql`](./Q202_Second_Highest_Price_Per_Category_Without_Window_Functions.sql)
