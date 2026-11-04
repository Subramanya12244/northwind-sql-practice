# Q114 · Unshipped Orders Older Than 30 Days

> **Revision Card**
> **Category:** Date & Time (Aging with Fixed Reference Date) | **Difficulty:** Medium
> **Concepts:** NULL Filtering · DATE ± Integer · Fixed Reference Date · Boolean Expression
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** use the fixed reference DATE '1998-12-31' as 'today' — never CURRENT_DATE — and test shipped_date with IS NULL, not = NULL.

## 1. Problem

The warehouse wants an aging report of stuck orders. Treat **DATE '1998-12-31' as today**. List every order that has not shipped yet and was placed more than 30 days before that date, showing how long it has been open and whether it is already past its required date.

**Objective:** Return unshipped orders with order_date more than 30 days before 1998-12-31, with days open and an overdue flag.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| customer_id | Customer |
| order_date | Date placed |
| required_date | Date the customer needed it |
| days_open | DATE '1998-12-31' − order_date, in days |
| past_required_date | true if 1998-12-31 is after required_date |

| order_id | customer_id | order_date | required_date | days_open | past_required_date |
|---|---|---|---|---|---|
| 10248 | ALFKI | 1996-01-01 | 1996-01-15 | 1095 | true |
| 10332 | VINET | 1996-01-01 | 1996-01-15 | 1095 | true |
| 10311 | RANCH | 1996-04-08 | 1996-04-22 | 997 | true |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Filter `shipped_date IS NULL`.
2. Keep rows where `order_date < DATE '1998-12-31' - 30`.
3. Compute `days_open` and a boolean `past_required_date`.
4. Sort oldest first (`days_open DESC`), tie-break on `order_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.required_date,
    (DATE '1998-12-31' - o.order_date) AS days_open,
    (DATE '1998-12-31' > o.required_date) AS past_required_date
FROM orders o
WHERE o.shipped_date IS NULL
  AND o.order_date < DATE '1998-12-31' - 30
ORDER BY days_open DESC, order_id;
```

## 6. Why This Works

`DATE - integer` returns a DATE, so `DATE '1998-12-31' - 30` is the cutoff 1998-12-01. A fixed reference date makes the result reproducible — `CURRENT_DATE` would change the answer every day. `IS NULL` is required because `shipped_date = NULL` evaluates to NULL and matches nothing.

## 7. Common Pitfalls (generic)

- `WHERE shipped_date = NULL` returns zero rows.
- Using `CURRENT_DATE` / `NOW()`, which makes results drift over time.
- `DATE - INTERVAL '30 days'` returns a TIMESTAMP, not a DATE — fine for comparison but changes the output type if selected.
- Off-by-one: 'older than 30 days' (`<`) versus 'at least 30 days' (`<=`).

## 8. Interview Follow-ups

**1. How would you bucket these into aging bands (31–90, 91–365, 365+ days)?**

Add a `CASE WHEN days_open <= 90 THEN '31-90' WHEN days_open <= 365 THEN '91-365' ELSE '365+' END` column. Group by it to get counts per band.

**2. Why not just use CURRENT_DATE in production?**

In production you often would, but for reports, tests and graded exercises a parameterised reference date makes results reproducible. Many teams pass the 'as-of' date as a parameter to support backfills.

**3. How would you make this index-friendly on a large table?**

A partial index `CREATE INDEX ON orders (order_date) WHERE shipped_date IS NULL` covers exactly this query. The predicate on `order_date` stays sargable because the column is not wrapped in a function.

## 9. Key Takeaway

Aging reports need a fixed as-of date, `IS NULL` for open items, and `as_of - date` for integer days open.

---
📄 **SQL File:** [`Q114_Unshipped_Orders_Older_Than_30_Days.sql`](./Q114_Unshipped_Orders_Older_Than_30_Days.sql)
