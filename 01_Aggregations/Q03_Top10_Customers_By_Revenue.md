# Q03 · Top 10 Customers by Revenue

> **Revision Card**
> **Category:** Aggregations & Revenue Analysis | **Difficulty:** Easy
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY · LIMIT
> **Outcome:** ✅ correct first attempt
> **Watch out for:** `ORDER BY ... DESC` must come *before* `LIMIT`, or you get an arbitrary 10, not the top 10.

## 1. Problem

The account management team wants the company's most valuable customers by revenue, to prioritize relationship management and retention on the accounts that matter most.

**Objective:** Identify the 10 customers with the highest total discounted revenue across all orders.

**Tables:** `customers`, `orders`, `order_details`

**Expected output:**

| Column | Description |
|---|---|
| customer_id | Unique identifier of the customer |
| company_name | Customer's company name |
| total_revenue | Sum of discounted revenue across all orders |

| customer_id | company_name | total_revenue |
|---|---|---|
| QUICK | QUICK-Stop | 117483.39 |
| ERNSH | Ernst Handel | 104874.98 |
| SAVEA | Save-a-lot Markets | 104361.95 |

*(Sample values illustrative of the standard Northwind dataset.)*

## 2. My Approach

1. Join `customers → orders → order_details` to connect identity to transactions.
2. Compute revenue `unit_price * quantity * (1 - discount)`.
3. `SUM()` grouped by customer.
4. Sort by revenue descending.
5. Return top 10 with `LIMIT`.

## 3. My Solution (as submitted)

```sql
SELECT
    cu.customer_id,
    cu.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY cu.customer_id, cu.company_name
ORDER BY total_revenue DESC
LIMIT 10;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why join through `orders`:** `customers` has no direct link to `order_details`; `orders` is the bridge connecting `customer_id` to individual line items.

**Why `LIMIT 10` after `ORDER BY ... DESC`:** sorting first, then limiting, guarantees the *highest* 10. Limiting before sorting returns an arbitrary 10 depending on storage order.

## 7. Common Pitfalls (generic)

- `LIMIT` before fully aggregating / without `ORDER BY` → arbitrary top-10.
- Ties at 10th place silently cut off by `LIMIT`; use `RANK() <= 10` if ties must be kept.
- Confusing 'top by revenue' with 'top by number of orders' (Q05) — different lists.

## 8. Interview Follow-ups

1. What's the risk of `LIMIT` without a preceding `ORDER BY`?
2. If two customers tie for 10th, would this show both, one, or neither? How to fix?
3. How would you show top 10 customers per country instead of overall?
4. What indexes would help this query on a large orders table?

## 9. Key Takeaway

For deterministic top-N reporting, always `ORDER BY` before `LIMIT`, and reach for window ranking when ties must be preserved.

---
📄 **SQL File:** [`Q03_Top10_Customers_By_Revenue.sql`](./Q03_Top10_Customers_By_Revenue.sql)
