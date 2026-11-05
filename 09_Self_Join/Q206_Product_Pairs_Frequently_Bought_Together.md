# Q206 · Product Pairs Frequently Bought Together

> **Revision Card**
> **Category:** SELF JOIN (Market Basket Pairs) | **Difficulty:** Hard
> **Concepts:** Self join · Pair generation with a < b · GROUP BY · HAVING · Market basket analysis
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Join order lines of the same order with b.product_id > a.product_id so each pair appears once.

## 1. Problem

The e-commerce team wants 'frequently bought together' suggestions: pairs of products that appear in the same order at least twice.

**Objective:** List product pairs that appear together in two or more orders, with both names and the number of shared orders, most frequent first.

**Tables:** `order_details`, `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| product_a | Lower product id |
| name_a | Its name |
| product_b | Higher product id |
| name_b | Its name |
| orders_together | Orders containing both |

| product_a | name_a | product_b | name_b | orders_together |
|-----------|--------|-----------|--------|-----------------|
| 25 | NuNuCa Nuß-Nougat-Creme | 32 | Mascarpone Fabioli | 5 |
| 29 | Thüringer Rostbratwurst | 36 | Inlagd Sill | 5 |
| 21 | Sir Rodney's Scones | 28 | Rössle Sauerkraut | 4 |
| 24 | Guaraná Fantástica | 29 | Thüringer Rostbratwurst | 4 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Self-join order_details a and b on the same order_id with b.product_id > a.product_id.
2. Join products twice for the names.
3. Group by the pair and keep pairs with COUNT(*) >= 2.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT a.product_id AS product_a, pa.product_name AS name_a,
       b.product_id AS product_b, pb.product_name AS name_b,
       COUNT(*)     AS orders_together
FROM order_details a
JOIN order_details b ON b.order_id = a.order_id AND b.product_id > a.product_id
JOIN products pa ON pa.product_id = a.product_id
JOIN products pb ON pb.product_id = b.product_id
GROUP BY a.product_id, pa.product_name, b.product_id, pb.product_name
HAVING COUNT(*) >= 2
ORDER BY orders_together DESC, product_a, product_b;
```

## 6. Why This Works

Joining the order lines table to itself on order_id produces every combination of two products in the same order. Requiring b.product_id > a.product_id removes self-pairs and keeps each unordered pair once, so (A, B) and (B, A) aren't counted separately. Counting the joined rows per pair gives the number of orders that contain both, because each product appears at most once per order.

## 7. Common Pitfalls (generic)

- Using <> instead of >, which counts every pair twice.
- Joining on product_id instead of order_id.
- Assuming a product appears once per order; if it could repeat, count DISTINCT order_id.

## 8. Interview Follow-ups

**1. How would you compute lift for each pair?**

Divide the pair's share of orders by the product of each product's share of orders.

**2. How would you find triples?**

Add a third self-join with c.product_id > b.product_id.

**3. How do you keep this fast on big data?**

Limit to frequent products first, or pre-aggregate baskets; the pair join grows with basket size squared.

## 9. Key Takeaway

Self-join on the shared key with a < b to generate each pair once, then count.

---
📄 **SQL File:** [`Q206_Product_Pairs_Frequently_Bought_Together.sql`](./Q206_Product_Pairs_Frequently_Bought_Together.sql)
