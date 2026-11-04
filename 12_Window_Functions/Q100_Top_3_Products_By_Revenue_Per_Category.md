# Q100 · Top 3 Products By Revenue Per Category

> **Revision Card**
> **Category:** Window Functions (Ranking + Filter) | **Difficulty:** Medium
> **Concepts:** DENSE_RANK · PARTITION BY · GROUP BY · SUM · CTE · Top-N per Group
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Aggregate revenue first, then rank; you cannot filter on the rank in the same SELECT that computes it.

## 1. Problem

Category managers want to know their three best-selling products by net revenue, so they can prioritise stock and promotions. Products tied on revenue should share a position.

**Objective:** For each category, return the top 3 revenue positions (using `DENSE_RANK`), where revenue = `unit_price * quantity * (1 - discount)` from `order_details`.

**Tables:** `order_details`, `products`, `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category name |
| revenue_rank | Dense rank of the product's revenue within its category |
| product_id | Product identifier |
| product_name | Product name |
| revenue | Total net revenue, rounded to 2 dp |

| category_name | revenue_rank | product_id | product_name | revenue |
|---------------|--------------|------------|--------------|---------|
| Beverages | 1 | 38 | Côte de Blaye | 17509.57 |
| Beverages | 2 | 43 | Ipoh Coffee | 2371.30 |
| Beverages | 3 | 76 | Lakkalikööri | 1914.30 |
| Condiments | 1 | 8 | Northwoods Cranberry Sauce | 3148.00 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `product_revenue`: sum net revenue per product (with its `category_id`).
2. CTE `ranked`: `DENSE_RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC)`.
3. Filter `revenue_rank <= 3`, join `categories` for the name, and round.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH product_revenue AS (
    SELECT
        p.category_id,
        p.product_id,
        p.product_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM order_details od
    JOIN products p ON p.product_id = od.product_id
    GROUP BY p.category_id, p.product_id, p.product_name
),
ranked AS (
    SELECT
        pr.*,
        DENSE_RANK() OVER (PARTITION BY pr.category_id ORDER BY pr.revenue DESC) AS revenue_rank
    FROM product_revenue pr
)
SELECT
    c.category_name,
    r.revenue_rank,
    r.product_id,
    r.product_name,
    ROUND(r.revenue::numeric, 2) AS revenue
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.revenue_rank <= 3
ORDER BY category_name, revenue_rank, product_id;
```

## 6. Why This Works

This is the top-N-per-group pattern. Aggregation must come first, because the ranking is over product totals, not individual order lines. The window function then runs over the grouped rows, restarting for each category because of `PARTITION BY`.

Window functions are evaluated after `WHERE` and `HAVING`, so the rank can only be filtered one level up. `DENSE_RANK` keeps tied products at the same position and still gives three distinct revenue levels. Rounding happens only in the final projection, so ranking uses full precision.

## 7. Common Pitfalls (generic)

- Ranking raw `order_details` rows instead of per-product totals.
- Filtering on the rank in the same `SELECT`, which is a syntax error.
- Rounding before ranking, which can create artificial ties.
- Using `ROW_NUMBER()` and silently dropping a product tied at position 3.

## 8. Interview Follow-ups

**1. How would the result change with ROW_NUMBER() or RANK()?**

`ROW_NUMBER()` always returns at most 3 rows per category and breaks ties arbitrarily. `RANK()` can return more than 3 rows when there is a tie at rank 3, but fewer distinct levels after a tie higher up. `DENSE_RANK()` returns the top three revenue levels, which can be more than three products.

**2. How would you also show each product's share of its category revenue?**

Add `revenue / SUM(revenue) OVER (PARTITION BY category_id)` in the `ranked` CTE. The partitioned sum is computed before the top-3 filter, so the share is out of the whole category, not just the top 3.

**3. Why not use a correlated subquery counting higher-revenue products?**

It works (`WHERE (SELECT COUNT(DISTINCT ...) ...) < 3`), but it re-scans the data for every product and is harder to read. The window approach sorts each partition once.

## 9. Key Takeaway

Top-N per group: aggregate, rank with `PARTITION BY`, then filter the rank in an outer query.

---
📄 **SQL File:** [`Q100_Top_3_Products_By_Revenue_Per_Category.sql`](./Q100_Top_3_Products_By_Revenue_Per_Category.sql)
