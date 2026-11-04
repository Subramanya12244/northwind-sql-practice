# Q106 · Customer Revenue Quartiles

> **Revision Card**
> **Category:** Window Functions (Distribution) | **Difficulty:** Medium
> **Concepts:** NTILE · Bucketing · GROUP BY · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** NTILE splits by row count, not by value; tied revenues can land in different quartiles.

## 1. Problem

Marketing wants to segment customers into four equally sized tiers by lifetime revenue — quartile 1 being the top spenders — to target campaigns.

**Objective:** Assign every customer to a revenue quartile (1 = highest revenue) using `NTILE(4)`.

**Tables:** `orders`, `order_details`, `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Customer company name |
| customer_revenue | Net revenue, 2 dp |
| revenue_quartile | 1–4, where 1 is the top 25% of customers by revenue |

| customer_id | company_name | customer_revenue | revenue_quartile |
|-------------|--------------|------------------|------------------|
| FOLKO | Folk och fä HB | 12905.32 | 1 |
| GOURL | Gourmet Lanchonetes | 9578.85 | 1 |
| BOLID | Bólido Comidas preparadas | 8095.04 | 1 |
| ALFKI | Alfreds Futterkiste | 4703.69 | 1 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `customer_revenue`: net revenue per customer.
2. `NTILE(4) OVER (ORDER BY revenue DESC, customer_id)` to bucket customers.
3. Join `customers`; order by quartile, revenue descending, `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.customer_id
)
SELECT
    cr.customer_id,
    c.company_name,
    ROUND(cr.revenue::numeric, 2) AS customer_revenue,
    NTILE(4) OVER (ORDER BY cr.revenue DESC, cr.customer_id) AS revenue_quartile
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
ORDER BY revenue_quartile, customer_revenue DESC, customer_id;
```

## 6. Why This Works

`NTILE(n)` splits the ordered rows into n buckets of as equal size as possible. When the row count is not divisible by n, the first buckets get one extra row each. Ordering by revenue descending puts top spenders in bucket 1.

Adding `customer_id` to the window's `ORDER BY` makes bucket boundaries deterministic. Without it, customers tied on revenue could swap buckets between runs.

## 7. Common Pitfalls (generic)

- Expecting `NTILE` to split by revenue ranges — it splits by row count.
- Ordering ascending, so quartile 1 becomes the lowest spenders.
- No tie-breaker, so boundary customers move between runs.
- Expecting equal-sized buckets when the count does not divide evenly.

## 8. Interview Follow-ups

**1. How would you bucket by value ranges instead of equal counts?**

Use `WIDTH_BUCKET(revenue, min, max, 4)` or compute thresholds with `PERCENTILE_CONT(ARRAY[0.25,0.5,0.75]) WITHIN GROUP (ORDER BY revenue)` and compare. Buckets then have different sizes but consistent ranges.

**2. How do you summarise each quartile?**

Wrap the query and `GROUP BY revenue_quartile` with `COUNT(*)`, `SUM(customer_revenue)`, `MIN` and `MAX`. That shows the revenue band and contribution of each tier.

**3. How would you include customers with no orders in quartile 4?**

Start from `customers` and `LEFT JOIN` the revenue CTE with `COALESCE(revenue, 0)`. They sort last and fill the bottom bucket.

## 9. Key Takeaway

`NTILE(n)` makes n equal-count buckets over an ordered set — always add a tie-breaker.

---
📄 **SQL File:** [`Q106_Customer_Revenue_Quartiles.sql`](./Q106_Customer_Revenue_Quartiles.sql)
