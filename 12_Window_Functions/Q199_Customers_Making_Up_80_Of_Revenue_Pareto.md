# Q199 · Customers Making Up 80% Of Revenue (Pareto)

> **Revision Card**
> **Category:** Window Functions (Cumulative Share) | **Difficulty:** Hard
> **Concepts:** SUM() OVER (ORDER BY …) · ROWS frame · SUM() OVER () · Pareto analysis · Tie-breaking
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Order the running total by revenue AND customer_id with a ROWS frame, or tied revenues are summed together.

## 1. Problem

Leadership asks the classic 80/20 question: which customers together bring in the first 80% of revenue?

**Objective:** List the smallest set of top customers whose combined revenue reaches 80% of all revenue, with each customer's revenue (2 dp) and the cumulative share in percent (1 dp), largest first.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer |
| revenue | Customer net revenue, 2 dp |
| cumulative_pct | Running share of total revenue including this customer, 1 dp |

| customer_id | revenue | cumulative_pct |
|-------------|---------|----------------|
| FOLKO | 12905.32 | 9.3 |
| GOURL | 9578.85 | 16.3 |
| BOLID | 8095.04 | 22.1 |
| ALFKI | 4703.69 | 25.5 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE: net revenue per customer.
2. Running SUM ordered by revenue DESC, customer_id with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW; total with SUM() OVER ().
3. Keep customers whose running total before them is still under 80% of the total.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH revenue AS (
    SELECT o.customer_id,
           SUM(d.unit_price * d.quantity * (1 - d.discount))::numeric AS rev
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    GROUP BY o.customer_id
),
ranked AS (
    SELECT customer_id, rev,
           SUM(rev) OVER (ORDER BY rev DESC, customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running,
           SUM(rev) OVER () AS total
    FROM revenue
)
SELECT customer_id,
       ROUND(rev, 2)                       AS revenue,
       ROUND(100 * running / total, 1)     AS cumulative_pct
FROM ranked
WHERE running - rev < 0.8 * total
ORDER BY rev DESC, customer_id;
```

## 6. Why This Works

A running total over customers sorted by revenue shows how much the top N customers contribute. The default RANGE frame treats tied revenues as one peer group, so the explicit ROWS frame plus a unique tie-breaker gives a clean per-row total. Keeping rows where the total before this customer (running − rev) is under 80% includes the customer that crosses the line.

## 7. Common Pitfalls (generic)

- Filtering running <= 0.8 * total, which stops one customer short of reaching 80%.
- Relying on the default RANGE frame, which gives tied customers the same running total.
- Computing the share with integer arithmetic or before rounding the revenue.

## 8. Interview Follow-ups

**1. Why can't the filter go in the same SELECT as the window function?**

WHERE runs before window functions are computed, so the windowed value must be filtered in an outer query or CTE.

**2. How would you label every customer A, B or C by cumulative share?**

CASE on cumulative_pct: up to 80 → A, up to 95 → B, else C.

**3. How do ties at the boundary affect the result?**

The tie-breaker decides which tied customer is included; state the rule explicitly in the requirement.

## 9. Key Takeaway

Cumulative shares need a running SUM with an explicit ROWS frame and a unique ORDER BY.

---
📄 **SQL File:** [`Q199_Customers_Making_Up_80_Of_Revenue_Pareto.sql`](./Q199_Customers_Making_Up_80_Of_Revenue_Pareto.sql)
