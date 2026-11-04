# Q161 · Late Shipments With Days Late

> **Revision Card**
> **Category:** Date & Time (Date Arithmetic) | **Difficulty:** Easy
> **Concepts:** DATE Subtraction · NULL Filtering · Comparison
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** DATE - DATE returns an integer number of days in PostgreSQL; unshipped orders (NULL shipped_date) are neither late nor on time.

## 1. Problem

Customer service wants a list of every order that was shipped after its required date, with how many days late it went out, worst first.

**Objective:** Return all shipped orders where shipped_date > required_date, with the number of days late.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_id | Order identifier |
| customer_id | Customer who placed the order |
| order_date | Date the order was placed |
| required_date | Date the customer needed it |
| shipped_date | Date it actually shipped |
| days_late | shipped_date − required_date, in whole days |

| order_id | customer_id | order_date | required_date | shipped_date | days_late |
|---|---|---|---|---|---|
| 10340 | ANATR | 1998-09-09 | 1998-10-07 | 1998-10-16 | 9 |
| 10285 | ISLAT | 1997-02-10 | 1997-03-10 | 1997-03-18 | 8 |
| 10329 | TRAIH | 1996-10-26 | 1996-11-23 | 1996-11-30 | 7 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Keep only orders with a non-NULL `shipped_date`.
2. Filter `shipped_date > required_date`.
3. Compute `shipped_date - required_date` as `days_late`.
4. Sort by `days_late DESC`, then `order_id`.

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
    o.shipped_date,
    (o.shipped_date - o.required_date) AS days_late
FROM orders o
WHERE o.shipped_date IS NOT NULL
  AND o.shipped_date > o.required_date
ORDER BY days_late DESC, order_id;
```

## 6. Why This Works

Both columns are DATE, and subtracting two DATEs in PostgreSQL yields an integer day count — no `DATEDIFF` needed. Comparisons with NULL return NULL (treated as false), so unshipped orders would drop out anyway, but the explicit `IS NOT NULL` documents intent. `order_id` breaks ties between equally late orders.

## 7. Common Pitfalls (generic)

- Subtracting TIMESTAMPs instead of DATEs returns an INTERVAL, not an integer.
- Using `>=` and counting on-time (same-day) shipments as late.
- Treating NULL shipped dates as on time or as late without a business rule.
- Porting `DATEDIFF` syntax from SQL Server/MySQL — it does not exist in PostgreSQL.

## 8. Interview Follow-ups

**1. How would you also flag unshipped orders that are already past their required date?**

Use the fixed reference date: `WHERE shipped_date IS NULL AND required_date < DATE '1998-12-31'`, computing `DATE '1998-12-31' - required_date` as days overdue. A `UNION ALL` or a `CASE` status column can combine both lists.

**2. How would you compute the on-time delivery rate?**

`AVG(CASE WHEN shipped_date <= required_date THEN 1.0 ELSE 0 END)` over shipped orders only. Multiplying by 100 gives a percentage; the `1.0` avoids integer division.

**3. What if the columns were TIMESTAMP WITH TIME ZONE?**

The subtraction would return an INTERVAL and could be affected by DST boundaries. Cast to DATE in the business timezone first, e.g. `(shipped_at AT TIME ZONE 'UTC')::date`, then subtract.

## 9. Key Takeaway

In PostgreSQL, `date - date` is an integer day count — the simplest way to measure lateness, after filtering out NULL ship dates.

---
📄 **SQL File:** [`Q161_Late_Shipments_With_Days_Late.sql`](./Q161_Late_Shipments_With_Days_Late.sql)
