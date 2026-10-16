# Q11 · Revenue by Shipper

> **Revision Card**
> **Category:** Category & Product Analytics | **Difficulty:** Easy
> **Concepts:** INNER JOIN (multi-table) · GROUP BY · SUM · ORDER BY
> **Outcome:** ✅ correct first attempt
> **Watch out for:** sum `order_details` revenue, not `orders.freight` — freight is the shipping cost, not the revenue handled.

## 1. Problem

Logistics and procurement want to understand how much order revenue flows through each shipping partner, to support shipper contract negotiations and performance comparisons.

**Objective:** Calculate the total discounted revenue of orders handled by each shipping company.

**Tables:** `shippers`, `orders`, `order_details`

**Expected output:**

| Column Name | Description |
|-------------|-------------|
| shipper_id | Unique identifier of the shipping company |
| company_name | Name of the shipping company |
| total_revenue | Sum of discounted revenue from all orders shipped via this company |

**Sample output:**

| shipper_id | company_name | total_revenue |
|------------|--------------|---------------|
| 3 | Federal Shipping | 402817.59 |
| 1 | Speedy Express | 385482.42 |
| 2 | United Package | 374733.39 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## 2. My Approach

1. Join `shippers` to `orders` on `ship_via = shipper_id`.
2. Join `orders` to `order_details` to access transaction-level revenue.
3. Calculate discounted revenue per line item.
4. Aggregate revenue by shipper.
5. Sort by total revenue descending.

## 3. My Solution (as submitted)

```sql
SELECT
    s.shipper_id,
    s.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM shippers s
JOIN orders o ON o.ship_via = s.shipper_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY s.shipper_id, s.company_name
ORDER BY total_revenue DESC;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Why join on `o.ship_via = s.shipper_id`:** `orders.ship_via` stores the foreign key pointing to the shipper used for that order — it's the only link between an order and the company that shipped it.

**Why this is revenue 'handled' rather than 'shipping cost':** the question asks for order revenue attributed to each shipper, not the `freight` cost charged for shipping — a distinction worth clarifying with stakeholders, since Northwind's `orders.freight` column could easily be confused for this.

## 7. Common Pitfalls (generic)

- Summing `orders.freight` (the shipping cost) instead of `order_details` revenue, which answers a completely different question.
- Forgetting that `ship_via` can technically be unpopulated for some orders, which would silently exclude those orders from any shipper's total under an `INNER JOIN`.

## 8. Interview Follow-ups

**1. What's the difference between 'revenue handled by a shipper' and 'shipping cost (freight) paid to a shipper'? Which does this query compute?**

Revenue handled is the total order value flowing through that shipper — the sum of line-item revenue `unit_price * quantity * (1 - discount)` from `order_details`. Freight (`orders.freight`) is the shipping charge for carrying the order, a cost rather than merchandise value. This query computes revenue handled, because it sums `order_details` revenue. Summing `orders.freight` would instead answer "how much freight was billed on orders this shipper carried" — a completely different number.

**2. How would you find the average order value per shipper instead of total revenue?**

Order value lives at the line-item grain, so first aggregate revenue to one total per order, then average those totals per shipper. Use a CTE/subquery: `SELECT o.ship_via, o.order_id, SUM(od.unit_price*od.quantity*(1-od.discount)) AS order_value FROM orders o JOIN order_details od ... GROUP BY o.ship_via, o.order_id`, then `SELECT ship_via, AVG(order_value) ... GROUP BY ship_via`. Averaging the raw line items directly would give average line value, not average order value.

**3. If some orders have a `NULL` `ship_via`, how would that affect this query's totals, and how would you account for those orders?**

An `INNER JOIN` on `o.ship_via = s.shipper_id` silently drops every order whose `ship_via` is NULL, since NULL matches no shipper_id. Those orders' revenue simply never appears under any shipper, so the grand total is understated. To account for them, `LEFT JOIN` from `orders` to `shippers` and use `COALESCE(s.company_name, 'Unknown/Unshipped')` so NULL-shipper revenue is grouped into its own bucket rather than vanishing.

## 9. Key Takeaway

Joining through a foreign key named differently from its parent key (`ship_via` vs `shipper_id`) is routine — and always confirm whether 'revenue' means order value or shipping cost (`freight`), two metrics easy to conflate.

---
📄 **SQL File:** [`Q11_Revenue_By_Shipper.sql`](./Q11_Revenue_By_Shipper.sql)
