# Q154 · Customer Share Of Total Revenue

> **Revision Card**
> **Category:** Window Functions (Aggregate Windows) | **Difficulty:** Medium
> **Concepts:** SUM() OVER () · Percent of Total · GROUP BY · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** An empty OVER () spans the whole result set, so the grand total is available on every row without a subquery.

## 1. Problem

Sales leadership wants to know how concentrated revenue is: what percentage of total company revenue each customer accounts for.

**Objective:** For each customer, return their net revenue, the company-wide total, and their share as a percentage (2 dp), largest first.

**Tables:** `orders`, `order_details`, `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Customer company name |
| customer_revenue | Customer's net revenue, 2 dp |
| total_revenue | Net revenue across all customers, 2 dp |
| revenue_share_pct | customer_revenue / total_revenue × 100, 2 dp |

| customer_id | company_name | customer_revenue | total_revenue | revenue_share_pct |
|-------------|--------------|------------------|---------------|-------------------|
| FOLKO | Folk och fä HB | 12905.32 | 138319.80 | 9.33 |
| GOURL | Gourmet Lanchonetes | 9578.85 | 138319.80 | 6.93 |
| BOLID | Bólido Comidas preparadas | 8095.04 | 138319.80 | 5.85 |
| ALFKI | Alfreds Futterkiste | 4703.69 | 138319.80 | 3.40 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE `customer_revenue`: net revenue per customer.
2. Outer query: `SUM(revenue) OVER ()` gives the grand total on every row.
3. Share = `100.0 * revenue / SUM(revenue) OVER ()`; round and order by share descending, then `customer_id`.

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
    ROUND((SUM(cr.revenue) OVER ())::numeric, 2) AS total_revenue,
    ROUND((100.0 * cr.revenue / SUM(cr.revenue) OVER ())::numeric, 2) AS revenue_share_pct
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
ORDER BY revenue_share_pct DESC, customer_id;
```

## 6. Why This Works

A window aggregate with an empty `OVER ()` treats the whole result set as one partition. Every row gets the same grand total, and the row is not collapsed as it would be with plain `GROUP BY`. That lets each customer's revenue be divided by the total in the same `SELECT`.

The window runs over the already grouped CTE rows, so it sums customer totals, not order lines. Unrounded values are used for the share so rounding does not skew the percentage.

## 7. Common Pitfalls (generic)

- Mixing a plain `SUM()` with non-grouped columns, which needs a `GROUP BY` and collapses rows.
- Using integer division, which makes most shares 0.
- Dividing by a rounded total, adding small errors.
- Applying `WHERE` filters that change the denominator unintentionally (the window only sees rows that survive `WHERE`).

## 8. Interview Follow-ups

**1. How would you add a cumulative share (Pareto curve)?**

Add `SUM(revenue) OVER (ORDER BY revenue DESC, customer_id ROWS UNBOUNDED PRECEDING) / SUM(revenue) OVER ()`. This shows how many top customers make up, say, 80% of revenue.

**2. How would you compute share within each country instead?**

Use `SUM(revenue) OVER (PARTITION BY c.country)` as the denominator. Each customer's share is then relative to their own country's total.

**3. Is SUM() OVER () computed once or per row?**

Logically it is defined per row, but PostgreSQL computes the aggregate once for the partition and reuses it. It is typically cheaper than a scalar subquery repeated in the select list.

## 9. Key Takeaway

`SUM(x) OVER ()` puts the grand total on every row, making percent-of-total a one-step calculation.

---
📄 **SQL File:** [`Q154_Customer_Share_Of_Total_Revenue.sql`](./Q154_Customer_Share_Of_Total_Revenue.sql)
