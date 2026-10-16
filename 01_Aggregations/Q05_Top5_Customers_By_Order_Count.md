# Q05 · Top 5 Customers by Number of Orders

> **Revision Card**
> **Category:** Aggregations & Revenue Analysis | **Difficulty:** Easy
> **Concepts:** INNER JOIN · GROUP BY · COUNT · ORDER BY · LIMIT
> **Outcome:** ✅ correct first attempt
> **Watch out for:** frequency (order count) ≠ value (revenue, Q03) — different business question, different list.

## 1. Problem

Operations wants to know which customers order most *frequently* — a different signal than total revenue, useful for spotting high-frequency, potentially lower-basket accounts versus high-value/low-frequency ones.

**Objective:** Identify the 5 customers who placed the highest number of distinct orders.

**Tables:** `customers`, `orders`

**Expected output:**

| Column | Description |
|---|---|
| customer_id | Unique identifier of the customer |
| company_name | Customer's company name |
| order_count | Number of distinct orders placed |

| customer_id | company_name | order_count |
|---|---|---|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |

*(Sample values illustrative of the standard Northwind dataset.)*

## 2. My Approach

1. Join `customers` to `orders` on `customer_id`.
2. `COUNT(DISTINCT order_id)` per customer.
3. Group by customer.
4. Sort by order count descending.
5. `LIMIT 5`.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY order_count DESC
LIMIT 5;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why `COUNT(DISTINCT o.order_id)` rather than `COUNT(o.order_id)`:** with only `customers` joined to `orders` (no `order_details`), each order appears once per customer, so the two are equivalent here. `DISTINCT` is a defensive habit — it prevents inflated counts if the query is later extended to join `order_details`, which duplicates rows per line item.

## 7. Common Pitfalls (generic)

- Joining `order_details` unnecessarily then using plain `COUNT(order_id)` → counts each order once per line item, wildly overstating counts.
- Confusing 'most orders' (frequency) with 'most revenue' (value, Q03) — different questions.

## 8. Interview Follow-ups

1. Why is `COUNT(DISTINCT order_id)` a safer default than plain `COUNT(order_id)`?
2. What's the business difference between a customer here vs the Q03 top-revenue list?
3. How would you extend this to average order count per segment/region?
4. If you joined `order_details`, what would break and how would you fix it?

## 9. Key Takeaway

Separate frequency metrics from value metrics, and use `COUNT(DISTINCT ...)` defensively in joins that may later fan out to a finer grain.

---
📄 **SQL File:** [`Q05_Top5_Customers_By_Order_Count.sql`](./Q05_Top5_Customers_By_Order_Count.sql)
