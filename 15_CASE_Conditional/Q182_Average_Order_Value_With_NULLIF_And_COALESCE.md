# Q182 · Average Order Value With NULLIF And COALESCE

> **Revision Card**
> **Category:** NULL Handling (COALESCE / NULLIF) | **Difficulty:** Medium
> **Concepts:** COALESCE · NULLIF · LEFT JOIN · Safe Division · COUNT DISTINCT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Dividing by a zero order count raises an error; `NULLIF(count, 0)` turns it into NULL instead.

## 1. Problem

Account managers for Germany want every German customer listed — even those who never ordered — with their revenue (0 when none) and average order value (blank when there are no orders).

**Objective:** For all customers in Germany, return order count, total net revenue (0 if none) and average order value (NULL if no orders), plus a status label.

**Tables:** `customers`, `orders`, `order_details`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Company name |
| order_count | Distinct orders |
| total_revenue | Net revenue, 0 when none |
| avg_order_value | Revenue / orders, NULL when no orders |
| status | `no orders` or `active` |

| customer_id | company_name | order_count | total_revenue | avg_order_value | status |
|-------------|--------------|-------------|---------------|-----------------|--------|
| ALFKI | Alfreds Futterkiste | 2 | 4703.69 | 2351.84 | active |
| BLAUS | Blauer See Delikatessen | 2 | 2041.22 | 1020.61 | active |
| DRACD | Drachenblut Delikatessen | 1 | 95.62 | 95.62 | active |
| FRANK | Frankenversand | 1 | 1003.20 | 1003.20 | active |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `LEFT JOIN` customers to orders and order_details so customers without orders stay.
2. `COUNT(DISTINCT o.order_id)` and `SUM` net revenue.
3. `COALESCE(SUM(...), 0)` for revenue; `SUM(...) / NULLIF(COUNT(DISTINCT ...), 0)` for the average.
4. Label with `CASE` and order by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    c.customer_id,
    c.company_name,
    COUNT(DISTINCT o.order_id)                                               AS order_count,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)), 0)::numeric, 2) AS total_revenue,
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount))
           / NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric, 2)             AS avg_order_value,
    CASE WHEN COUNT(o.order_id) = 0 THEN 'no orders' ELSE 'active' END       AS status
FROM customers c
LEFT JOIN orders o         ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id   = o.order_id
WHERE c.country = 'Germany'
GROUP BY c.customer_id, c.company_name
ORDER BY c.customer_id;
```

## 6. Why This Works

`NULLIF(a, b)` returns NULL when `a = b`, otherwise `a`. Dividing by `NULLIF(count, 0)` therefore yields NULL instead of a division-by-zero error. `COALESCE(x, 0)` returns its first non-NULL argument, turning the NULL `SUM` of a customer without orders into 0. The two functions are mirror images: NULLIF creates a NULL, COALESCE removes one.

## 7. Common Pitfalls (generic)

- `COUNT(*)` over a LEFT JOIN counts the unmatched row as 1 — count a column from the right side.
- Applying `COALESCE` to the average as 0, which falsely suggests a zero-value order.
- Integer division when both operands are integers; here `SUM` of numeric/real keeps decimals.

## 8. Interview Follow-ups

**1. What does `COALESCE(a, b, c)` do?**

Returns the first non-NULL argument from left to right, or NULL if all are NULL.

**2. Is `NULLIF(x, 0)` the same as `CASE WHEN x = 0 THEN NULL ELSE x END`?**

Yes — NULLIF is shorthand for exactly that CASE.

**3. Why can `x / NULLIF(y,0)` still be NULL when y is not 0?**

Because `x` itself may be NULL — any arithmetic with NULL returns NULL.

## 9. Key Takeaway

`NULLIF(divisor, 0)` makes division safe; `COALESCE(agg, 0)` turns missing aggregates into zero — use each where its meaning fits.

---
📄 **SQL File:** [`Q182_Average_Order_Value_With_NULLIF_And_COALESCE.sql`](./Q182_Average_Order_Value_With_NULLIF_And_COALESCE.sql)
