# Q08 · Customers Above Average Order Count

> **Revision Card**
> **Category:** GROUP BY & HAVING | **Difficulty:** Medium
> **Concepts:** INNER JOIN · GROUP BY · CTE · COUNT/AVG · Scalar Subquery
> **Outcome:** ✅ correct first attempt
> **Watch out for:** 'average order count' means average *per customer*, not across orders (which would trivially be 1).

## 1. Problem

Operations wants to identify customers who order more frequently than the typical customer, to understand engagement patterns separate from revenue value.

**Objective:** Return all customers whose order count exceeds the average order count computed across all customers.

**Tables:** `customers`, `orders`

**Expected output:**

| Column | Description |
|---|---|
| customer_id | Unique identifier of the customer |
| company_name | Name of the customer's company |
| order_count | Total number of orders placed by the customer |

| customer_id | company_name | order_count |
|---|---|---|
| SAVEA | Save-a-lot Markets | 31 |
| ERNSH | Ernst Handel | 30 |
| QUICK | QUICK-Stop | 28 |
| HUNGO | Hungry Owl All-Night Grocers | 19 |

*(Sample values are illustrative, based on the standard Northwind dataset — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Build a CTE (`customer_orders`) that counts orders per customer.
2. Select from that CTE.
3. Filter using a scalar subquery computing `AVG(order_count)` over the whole CTE.
4. Sort by order count descending.

## 3. My Solution (as submitted)

```sql
WITH customer_orders AS (
    SELECT
        cu.customer_id,
        cu.company_name,
        COUNT(o.order_id) AS order_count
    FROM customers cu
    JOIN orders o ON o.customer_id = cu.customer_id
    GROUP BY cu.customer_id, cu.company_name
)
SELECT *
FROM customer_orders
WHERE order_count > (SELECT AVG(order_count) FROM customer_orders)
ORDER BY order_count DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why this mirrors Q6/Q7 but with `COUNT` instead of `SUM`:** the same 'aggregate per entity, then compare to a separately computed average' pattern applies regardless of which aggregate function defines the metric.

## 7. Common Pitfalls (generic)

- Using average order count across *orders* (i.e. just `1`, trivially) instead of average order count *per customer* — a subtle misreading of the requirement.
- Forgetting that customers with zero orders are excluded entirely by the `INNER JOIN`, which slightly skews the average upward (every customer in the CTE has at least 1 order).

## 8. Interview Follow-ups

1. Would the computed average change if customers with zero orders were included via a LEFT JOIN? Why?
2. How does this differ conceptually from Q5 (Top 5 Customers by Order Count)?
3. How would you find customers whose order count is *below* average instead?

## 9. Key Takeaway

The above-average comparison pattern applies to any aggregate — swap `SUM` for `COUNT` and it still holds. Watch how `INNER JOIN` vs `LEFT JOIN` subtly shifts the computed average.

---
📄 **SQL File:** [`Q08_Customers_Above_Average_Order_Count.sql`](./Q08_Customers_Above_Average_Order_Count.sql)
