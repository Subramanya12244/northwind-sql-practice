# Q183 · Customer Value Segment Summary

> **Revision Card**
> **Category:** CASE Expressions (Segmentation) | **Difficulty:** Hard
> **Concepts:** CASE Segmentation · LEFT JOIN · COALESCE · CTE · CASE in ORDER BY · Window SUM
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Customers with no orders have NULL revenue; COALESCE before bucketing or they fall into the wrong segment.

## 1. Problem

Leadership wants every customer segmented — High value (≥ 5000 revenue), Medium (≥ 1000), Low (> 0), and Inactive (no revenue) — and a summary of how many customers and how much revenue each segment holds.

**Objective:** Segment all customers by total net revenue and return per segment: customer count, total revenue, average revenue per customer and share of total revenue (%), ordered High, Medium, Low, Inactive.

**Tables:** `customers`, `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| segment | High / Medium / Low / Inactive |
| customers | Customers in segment |
| segment_revenue | Total revenue, 2 dp |
| avg_revenue | Average revenue per customer, 2 dp |
| revenue_share_pct | Share of all revenue, % |

| segment | customers | segment_revenue | avg_revenue | revenue_share_pct |
|---------|-----------|-----------------|-------------|-------------------|
| High | 3 | 30579.21 | 10193.07 | 22.1 |
| Medium | 45 | 88214.73 | 1960.33 | 63.8 |
| Low | 41 | 19525.85 | 476.24 | 14.1 |
| Inactive | 2 | 0.00 | 0.00 | 0.0 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `cust_rev`: LEFT JOIN customers to orders/order_details and `COALESCE(SUM(...), 0)` per customer.
2. CTE `seg`: bucket revenue with `CASE` (Inactive when 0).
3. Group by segment; compute share with `SUM(SUM(revenue)) OVER ()`.
4. Order with a `CASE` mapping segments to 1–4.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH cust_rev AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)), 0) AS revenue
    FROM customers c
    LEFT JOIN orders o         ON o.customer_id = c.customer_id
    LEFT JOIN order_details od ON od.order_id   = o.order_id
    GROUP BY c.customer_id
),
seg AS (
    SELECT
        customer_id,
        revenue,
        CASE
            WHEN revenue >= 5000 THEN 'High'
            WHEN revenue >= 1000 THEN 'Medium'
            WHEN revenue >  0    THEN 'Low'
            ELSE 'Inactive'
        END AS segment
    FROM cust_rev
)
SELECT
    segment,
    COUNT(*)                                                         AS customers,
    ROUND(SUM(revenue)::numeric, 2)                                  AS segment_revenue,
    ROUND(AVG(revenue)::numeric, 2)                                  AS avg_revenue,
    ROUND((100 * SUM(revenue) / SUM(SUM(revenue)) OVER ())::numeric, 1) AS revenue_share_pct
FROM seg
GROUP BY segment
ORDER BY CASE segment
             WHEN 'High'     THEN 1
             WHEN 'Medium'   THEN 2
             WHEN 'Low'      THEN 3
             ELSE 4
         END;
```

## 6. Why This Works

The first CTE produces exactly one row per customer — the LEFT JOIN keeps inactive customers and `COALESCE` gives them 0 so they land in the `ELSE` bucket. The second CTE applies the business rule once. The final query aggregates by segment; `SUM(SUM(revenue)) OVER ()` is a window over the grouped rows, giving the grand total for the share. A `CASE` in `ORDER BY` imposes the business order, and each segment appears once, so the order is tie-free.

## 7. Common Pitfalls (generic)

- Bucketing NULL revenue: `NULL >= 5000` is not true, so it would only reach `ELSE` by luck — make it explicit with COALESCE.
- Using an inner JOIN and losing every inactive customer.
- Ordering segments alphabetically (High, Inactive, Low, Medium).
- Computing the share with a scalar subquery that ignores inactive customers — harmless here, but easy to get wrong.

## 8. Interview Follow-ups

**1. Why `SUM(SUM(revenue)) OVER ()`?**

The inner `SUM` is the per-segment aggregate; the outer windowed `SUM` adds those group totals across all groups, after `GROUP BY`.

**2. How would you make thresholds configurable?**

Store them in a table (`segment, min_revenue`) and join with a range condition, or use `WIDTH_BUCKET` for equal-width bands.

**3. How would you list the customers in each segment?**

Add `STRING_AGG(customer_id, ', ' ORDER BY customer_id)` to the final SELECT.

## 9. Key Takeaway

Segment in a CTE (one row per entity, NULLs coalesced), aggregate per segment, and order segments with a `CASE`.

---
📄 **SQL File:** [`Q183_Customer_Value_Segment_Summary.sql`](./Q183_Customer_Value_Segment_Summary.sql)
