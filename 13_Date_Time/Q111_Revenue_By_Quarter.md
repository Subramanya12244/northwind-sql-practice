# Q111 · Revenue By Quarter

> **Revision Card**
> **Category:** Date & Time (Quarterly Aggregation) | **Difficulty:** Easy
> **Concepts:** EXTRACT(QUARTER) · JOIN · SUM · COUNT DISTINCT · ROUND
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** after joining to order_details, count orders with COUNT(DISTINCT order_id), not COUNT(*), or you count line items.

## 1. Problem

Finance prepares quarterly reports. For every year and quarter in the data, they want the number of orders and the net revenue earned, where revenue for a line is `unit_price * quantity * (1 - discount)`.

**Objective:** Return order count and net revenue (rounded to 2 decimals) per year and quarter.

**Tables:** `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| order_year | Calendar year (integer) |
| order_quarter | Quarter 1–4 (integer) |
| order_count | Distinct orders in that quarter |
| revenue | Net revenue, rounded to 2 decimals |

| order_year | order_quarter | order_count | revenue |
|---|---|---|---|
| 1996 | 1 | 9 | 5217.41 |
| 1996 | 2 | 9 | 18574.06 |
| 1996 | 3 | 8 | 19336.35 |
| 1996 | 4 | 8 | 9197.44 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Join `orders` to `order_details` on `order_id`.
2. Extract year and quarter from `order_date`.
3. `SUM` the net line revenue and `COUNT(DISTINCT order_id)`.
4. Round revenue with `ROUND(...::numeric, 2)` and order by year, quarter.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    EXTRACT(YEAR FROM o.order_date)::int    AS order_year,
    EXTRACT(QUARTER FROM o.order_date)::int AS order_quarter,
    COUNT(DISTINCT o.order_id)              AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(QUARTER FROM o.order_date)
ORDER BY order_year, order_quarter;
```

## 6. Why This Works

`EXTRACT(QUARTER FROM date)` maps months 1–3 to 1, 4–6 to 2 and so on, giving a calendar-quarter key. Revenue lives at the line level, so the join is required; it multiplies rows per order, which is why the order count must be `DISTINCT`. `discount` is REAL, so the sum is cast to numeric before `ROUND(..., 2)`.

## 7. Common Pitfalls (generic)

- `COUNT(*)` after the join counts order lines, not orders.
- Calling `ROUND(double precision, 2)` — PostgreSQL has no such overload; cast to `numeric` first.
- Assuming fiscal quarters equal calendar quarters; a fiscal year starting in, say, April needs a date shift first.
- Forgetting the `(1 - discount)` factor and reporting gross instead of net revenue.

## 8. Interview Follow-ups

**1. How would you report fiscal quarters for a fiscal year starting 1 April?**

Shift the date before extracting: `EXTRACT(QUARTER FROM order_date - INTERVAL '3 months')`. The fiscal year label is likewise `EXTRACT(YEAR FROM order_date - INTERVAL '3 months')`, adjusted to whatever naming convention finance uses.

**2. How would you show each quarter's share of its year's revenue?**

Wrap the query and add `revenue * 100.0 / SUM(revenue) OVER (PARTITION BY order_year)`. The window sums across quarters of the same year without collapsing rows.

**3. Could DATE_TRUNC('quarter', ...) replace the two EXTRACTs?**

Yes — `DATE_TRUNC('quarter', order_date)::date` yields the first day of the quarter as one key, e.g. 1996-04-01. It is easier to join and sort, but the expected output here asks for integer year and quarter columns.

## 9. Key Takeaway

Quarterly revenue = join to line items, group by year + `EXTRACT(QUARTER)`, `COUNT(DISTINCT order_id)`, and cast to numeric before rounding.

---
📄 **SQL File:** [`Q111_Revenue_By_Quarter.sql`](./Q111_Revenue_By_Quarter.sql)
