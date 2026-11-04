# Q118 · Customers Inactive In Last Six Months

> **Revision Card**
> **Category:** Date & Time (Recency / Churn) | **Difficulty:** Hard
> **Concepts:** LEFT JOIN · MAX · INTERVAL · NULLS FIRST · Fixed Reference Date · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** customers with no orders at all must be included — use LEFT JOIN and keep last_order_date IS NULL explicitly.

## 1. Problem

The retention team wants a churn list. Treat **DATE '1998-12-31' as today**. Find every customer who has not placed an order in the last 6 months (no order on or after 1998-06-30), including customers who never ordered at all.

**Objective:** Return customers whose most recent order is before 1998-06-30, or who have no orders, with last order date and days since then.

**Tables:** `customers`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Company name |
| country | Customer country |
| last_order_date | Most recent order_date (NULL if never ordered) |
| lifetime_orders | Total orders ever placed |
| days_since_last_order | 1998-12-31 − last_order_date (NULL if never ordered) |

| customer_id | company_name | country | last_order_date | lifetime_orders | days_since_last_order |
|---|---|---|---|---|---|
| FISSA | FISSA Fabrica Inter. Salchichas | Spain | NULL | 0 | NULL |
| PARIS | Paris spécialités | France | NULL | 0 | NULL |
| VINET | Vins et alcools Chevalier | France | 1996-01-01 | 1 | 1095 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. CTE: LEFT JOIN customers to orders; take `MAX(order_date)` and `COUNT(o.order_id)` per customer.
2. Cutoff = `(DATE '1998-12-31' - INTERVAL '6 months')::date` = 1998-06-30.
3. Keep rows where last order is NULL or before the cutoff.
4. Order by `last_order_date NULLS FIRST`, tie-break on `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH last_orders AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.country,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.order_id) AS lifetime_orders
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.company_name, c.country
)
SELECT
    customer_id,
    company_name,
    country,
    last_order_date,
    lifetime_orders,
    (DATE '1998-12-31' - last_order_date) AS days_since_last_order
FROM last_orders
WHERE last_order_date IS NULL
   OR last_order_date < (DATE '1998-12-31' - INTERVAL '6 months')::date
ORDER BY last_order_date NULLS FIRST, customer_id;
```

## 6. Why This Works

The question is about the *latest* order, so aggregate to `MAX(order_date)` per customer first, then filter — filtering individual orders would wrongly keep customers who had old orders but also recent ones. The LEFT JOIN keeps never-ordered customers with a NULL max. `COUNT(o.order_id)` counts 0 for them, whereas `COUNT(*)` would count 1.

## 7. Common Pitfalls (generic)

- Inner join drops customers who never ordered — often the most important churn segment.
- `WHERE order_date < cutoff` before grouping, which finds customers with *any* old order rather than *no recent* order.
- Writing `last_order_date < cutoff` alone; NULL comparisons are not true, so never-ordered customers vanish.
- Using `CURRENT_DATE`, which makes the 6-month window move.

## 8. Interview Follow-ups

**1. How would you write this with NOT EXISTS?**

`SELECT ... FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.order_date >= DATE '1998-06-30')`. It is often the clearest and most efficient anti-join, and naturally includes never-ordered customers.

**2. Why cast DATE - INTERVAL back to date?**

`DATE - INTERVAL` yields a TIMESTAMP. The comparison still works, but the cast keeps types consistent and makes the cutoff obvious as 1998-06-30.

**3. How would you build an RFM (recency, frequency, monetary) segment from this?**

Compute recency (days since last order), frequency (order count) and monetary (total revenue) per customer, then score each with `NTILE(5) OVER (ORDER BY ...)`. Combining the three scores gives segments such as 'champions' or 'at risk'.

## 9. Key Takeaway

Churn = aggregate to each customer's latest order via LEFT JOIN, then filter on that max — and keep the NULL never-ordered rows explicitly.

---
📄 **SQL File:** [`Q118_Customers_Inactive_In_Last_Six_Months.sql`](./Q118_Customers_Inactive_In_Last_Six_Months.sql)
