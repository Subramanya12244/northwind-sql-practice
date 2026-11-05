# Q204 · Products Shipped To Germany And The USA But Not France

> **Revision Card**
> **Category:** Set Operators (INTERSECT and EXCEPT Together) | **Difficulty:** Hard
> **Concepts:** INTERSECT · EXCEPT · Operator precedence · IN subquery
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** INTERSECT binds tighter than EXCEPT, so A INTERSECT B EXCEPT C is (A ∩ B) − C.

## 1. Problem

A distributor considers a French launch for products that already sell in both Germany and the USA but have never shipped to France.

**Objective:** List products that appear on orders shipped to Germany and on orders shipped to the USA, but never on orders shipped to France, by product id.

**Tables:** `products`, `order_details`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_id | Product |
| product_name | Name |

| product_id | product_name |
|------------|--------------|
| 7 | Uncle Bob's Organic Dried Pears |
| 8 | Northwoods Cranberry Sauce |
| 43 | Ipoh Coffee |
| 46 | Spegesild |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Three SELECTs of product_id from order lines filtered by ship_country.
2. Combine: Germany INTERSECT USA EXCEPT France.
3. Use the combined set in WHERE product_id IN (...).

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT p.product_id, p.product_name
FROM products p
WHERE p.product_id IN (
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'Germany'
    INTERSECT
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'USA'
    EXCEPT
    SELECT d.product_id FROM order_details d JOIN orders o ON o.order_id = d.order_id WHERE o.ship_country = 'France'
)
ORDER BY p.product_id;
```

## 6. Why This Works

Set operators express 'in both' (INTERSECT) and 'but not' (EXCEPT) directly and remove duplicates. In PostgreSQL INTERSECT is evaluated before EXCEPT, so the query means products in Germany and the USA, minus France, without parentheses. Wrapping the result in IN lets the outer query add product names.

## 7. Common Pitfalls (generic)

- Assuming left-to-right evaluation: A EXCEPT B INTERSECT C means A − (B ∩ C).
- Using UNION ALL-style thinking: INTERSECT and EXCEPT remove duplicates unless ALL is added.
- Selecting product_name inside the branches, which compares names instead of ids.

## 8. Interview Follow-ups

**1. How would you write it with EXISTS?**

WHERE EXISTS (Germany order line) AND EXISTS (USA order line) AND NOT EXISTS (France order line).

**2. What does INTERSECT ALL do?**

It keeps duplicates as many times as they appear in both inputs.

**3. How would you parameterise the countries?**

Put the countries in a VALUES list or table and use GROUP BY product with COUNT FILTER per country.

## 9. Key Takeaway

INTERSECT and EXCEPT say 'both' and 'but not'; INTERSECT runs first unless you add parentheses.

---
📄 **SQL File:** [`Q204_Products_Shipped_To_Germany_And_The_USA_But_Not_France.sql`](./Q204_Products_Shipped_To_Germany_And_The_USA_But_Not_France.sql)
