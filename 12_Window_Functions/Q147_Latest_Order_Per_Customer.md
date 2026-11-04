# Q147 · Latest Order Per Customer

> **Revision Card**
> **Category:** Window Functions (Ranking) | **Difficulty:** Easy
> **Concepts:** ROW_NUMBER · PARTITION BY · ORDER BY DESC · Top-1 per Group · CTE
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** ROW_NUMBER needs a deterministic tie-breaker (order_id) or the 'latest' row can change between runs.

## 1. Problem

The account-management team wants a one-row-per-customer snapshot showing each customer's most recent order — which order it was, when it was placed, and which employee handled it — so they can spot dormant accounts.

**Objective:** For every customer who has ordered, return exactly one row describing their latest order (latest `order_date`; if two orders share a date, the higher `order_id` wins).

**Tables:** `orders`, `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Customer company name |
| latest_order_id | ID of the customer's most recent order |
| latest_order_date | Date of that order |
| employee_id | Employee who handled that order |

| customer_id | company_name | latest_order_id | latest_order_date | employee_id |
|-------------|--------------|-----------------|-------------------|-------------|
| ALFKI | Alfreds Futterkiste | 10339 | 1997-08-08 | 2 |
| ANATR | Ana Trujillo Emparedados | 10340 | 1998-09-09 | 3 |
| ANTON | Antonio Moreno Taquería | 10250 | 1998-03-03 | 3 |
| AROUT | Around the Horn | 10342 | 1997-11-11 | 6 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Number each customer's orders with `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC)`.
2. Keep only `rn = 1` in the outer query (window results cannot be filtered in the same `WHERE`).
3. Join `customers` for the company name and sort by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH ranked_orders AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        o.employee_id,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id
                           ORDER BY o.order_date DESC, o.order_id DESC) AS rn
    FROM orders o
)
SELECT
    r.customer_id,
    c.company_name,
    r.order_id   AS latest_order_id,
    r.order_date AS latest_order_date,
    r.employee_id
FROM ranked_orders r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY customer_id;
```

## 6. Why This Works

`ROW_NUMBER()` assigns 1, 2, 3 ... inside each `PARTITION BY customer_id` group, following the window's `ORDER BY`. Sorting by `order_date DESC` puts the newest order at position 1. Adding `order_id DESC` breaks same-day ties, so exactly one row per customer survives and the result is deterministic.

The window is computed after `WHERE`, so the filter `rn = 1` has to live in an outer query (a CTE here). This pattern beats a correlated `MAX(order_date)` subquery because it returns the whole row in one pass and never yields duplicates on tied dates.

## 7. Common Pitfalls (generic)

- Filtering `WHERE ROW_NUMBER() OVER (...) = 1` directly — window functions are not allowed in `WHERE`.
- Omitting a tie-breaker, so two same-day orders make the 'latest' row non-deterministic.
- Using `RANK()` when exactly one row is required — ties would return two rows.
- Forgetting `PARTITION BY`, which returns only the single latest order overall.

## 8. Interview Follow-ups

**1. How would you return the latest two orders per customer?**

Change the filter to `rn <= 2`. The partition and ordering stay the same. Each customer then contributes up to two rows, fewer if they have only one order.

**2. Can you solve this without window functions?**

Yes: join to a subquery of `MAX(order_date)` per customer, or use a correlated subquery. Both need extra logic to break same-date ties. PostgreSQL also offers `DISTINCT ON (customer_id) ... ORDER BY customer_id, order_date DESC, order_id DESC`, which is concise but non-standard.

**3. When would you use RANK() instead of ROW_NUMBER() here?**

When the business wants every order on the latest date, not just one. `RANK()` gives all same-date orders rank 1, so all of them survive the filter. Pick based on whether ties should be kept or broken.

## 9. Key Takeaway

Top-1-per-group = `ROW_NUMBER() OVER (PARTITION BY group ORDER BY metric DESC, unique_id)` in a CTE, then filter `rn = 1` outside.

---
📄 **SQL File:** [`Q147_Latest_Order_Per_Customer.sql`](./Q147_Latest_Order_Per_Customer.sql)
