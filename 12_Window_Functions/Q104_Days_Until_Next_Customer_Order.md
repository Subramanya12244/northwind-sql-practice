# Q104 · Days Until Next Customer Order

> **Revision Card**
> **Category:** Window Functions (Offset) | **Difficulty:** Medium
> **Concepts:** LEAD · PARTITION BY · Date Arithmetic · Named WINDOW
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Partition by customer, or LEAD will read another customer's order.

## 1. Problem

The retention team wants to know how quickly customers come back. For every order, show that customer's next order and how many days passed until it was placed.

**Objective:** For each order, return the same customer's next order ID, its date, and the number of days between the two (NULL if there is no next order).

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| order_id | Order identifier |
| order_date | Order date |
| next_order_id | The customer's next order (NULL if none) |
| next_order_date | Date of the next order |
| days_until_next_order | Days from this order to the next |

| customer_id | order_id | order_date | next_order_id | next_order_date | days_until_next_order |
|-------------|----------|------------|---------------|-----------------|-----------------------|
| ALFKI | 10248 | 1996-01-01 | 10339 | 1997-08-08 | 585 |
| ALFKI | 10339 | 1997-08-08 | NULL | NULL | NULL |
| ANATR | 10249 | 1997-02-02 | 10340 | 1998-09-09 | 584 |
| ANATR | 10340 | 1998-09-09 | NULL | NULL | NULL |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Define `WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)`.
2. Use `LEAD(order_id)` and `LEAD(order_date)` over `w`.
3. Subtract `order_date` from the lead date to get days (date − date = integer).
4. Order by customer, date, order_id.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_id)   OVER w AS next_order_id,
    LEAD(order_date) OVER w AS next_order_date,
    LEAD(order_date) OVER w - order_date AS days_until_next_order
FROM orders
WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)
ORDER BY customer_id, order_date, order_id;
```

## 6. Why This Works

`LEAD(x)` reads the next row's value in the window. `PARTITION BY customer_id` keeps each customer's timeline separate, so the last order of one customer never sees the first order of the next. `order_id` in the window's `ORDER BY` breaks ties on the same date.

In PostgreSQL, subtracting two `date` values gives an integer number of days. The last order per customer has no next row, so all three `LEAD` columns are NULL.

## 7. Common Pitfalls (generic)

- Forgetting `PARTITION BY customer_id`, mixing customers.
- Ordering the window by `order_id` only, which may not match date order.
- Subtracting timestamps, which gives an interval instead of an integer day count.
- Filtering rows in `WHERE` before the window, which changes which order is 'next'.

## 8. Interview Follow-ups

**1. How would you get each customer's average days between orders?**

Wrap this query in a CTE and `AVG(days_until_next_order)` grouped by customer. `AVG` ignores the NULL on the last order automatically.

**2. What's the difference between LEAD and LAG here?**

`LEAD` looks forward (days until next), `LAG` looks backward (days since previous). The gaps are the same; they just sit on different rows.

**3. How would you flag customers who took more than 365 days to return?**

Add `CASE WHEN days_until_next_order > 365 THEN 1 ELSE 0 END` and aggregate per customer. Or filter the wrapped query with `WHERE days_until_next_order > 365`.

## 9. Key Takeaway

`LEAD()` with `PARTITION BY entity ORDER BY time` gives 'next event' metrics per entity in one pass.

---
📄 **SQL File:** [`Q104_Days_Until_Next_Customer_Order.sql`](./Q104_Days_Until_Next_Customer_Order.sql)
