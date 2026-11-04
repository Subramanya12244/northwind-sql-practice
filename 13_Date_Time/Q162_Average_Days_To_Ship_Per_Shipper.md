# Q162 · Average Days To Ship Per Shipper

> **Revision Card**
> **Category:** Date & Time (Lead-Time Analysis) | **Difficulty:** Medium
> **Concepts:** DATE Subtraction · AVG · MAX · JOIN · NULL Exclusion · ROUND
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** exclude unshipped orders explicitly; and AVG of integers must be cast to numeric before ROUND(..., 2).

## 1. Problem

Logistics is reviewing carrier performance. For each shipper, measure how quickly orders are handed over: the number of shipped orders, the average days from order to shipment, and the slowest shipment. Orders not yet shipped must be ignored.

**Objective:** Per shipper, return shipped order count, average and maximum days between order_date and shipped_date.

**Tables:** `shippers`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| shipper_id | Shipper identifier |
| company_name | Shipper name |
| shipped_orders | Number of shipped orders carried |
| avg_days_to_ship | Average shipped_date − order_date, rounded to 2 decimals |
| max_days_to_ship | Longest order-to-ship gap in days |

| shipper_id | company_name | shipped_orders | avg_days_to_ship | max_days_to_ship |
|---|---|---|---|---|
| 2 | United Package | 28 | 4.93 | 36 |
| 1 | Speedy Express | 29 | 5.83 | 35 |
| 3 | Federal Shipping | 28 | 6.18 | 37 |

*(Sample rows are illustrative — taken from the practice dataset to show shape/format; your instance may differ.)*

## 2. My Approach

1. Join `shippers` to `orders` on `ship_via = shipper_id`.
2. Filter `shipped_date IS NOT NULL`.
3. Aggregate `COUNT`, `AVG` and `MAX` of `shipped_date - order_date`.
4. Round the average and sort fastest first, tie-break on `shipper_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    s.shipper_id,
    s.company_name,
    COUNT(o.order_id)                                         AS shipped_orders,
    ROUND(AVG(o.shipped_date - o.order_date)::numeric, 2)     AS avg_days_to_ship,
    MAX(o.shipped_date - o.order_date)                        AS max_days_to_ship
FROM shippers s
JOIN orders o ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.shipper_id, s.company_name
ORDER BY avg_days_to_ship, shipper_id;
```

## 6. Why This Works

`shipped_date - order_date` gives integer days per order. `AVG` already ignores NULLs, but `COUNT(o.order_id)` would still count unshipped orders, so filtering in `WHERE` keeps all three metrics on the same population. The average of integers is numeric in PostgreSQL, and the explicit cast keeps `ROUND(..., 2)` portable.

## 7. Common Pitfalls (generic)

- Relying on AVG's NULL-skipping while COUNT includes unshipped orders — inconsistent denominators.
- Joining on `orders.shipper_id` — the column is `ship_via`.
- Integer division when computing averages manually as `SUM(days) / COUNT(*)`.
- Mixing calendar days with business days without saying which is reported.

## 8. Interview Follow-ups

**1. How would you compute the median days to ship?**

Use `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY shipped_date - order_date)` per shipper. The median is more robust to the occasional 35+ day outlier than the mean.

**2. How would you count business days only?**

Generate the days between the two dates with `generate_series` and count those where `EXTRACT(ISODOW FROM d) < 6`. A holiday calendar table would be joined in to exclude public holidays as well.

**3. How would you include shippers with no shipped orders?**

Change to `LEFT JOIN` and move the `shipped_date IS NOT NULL` condition into the ON clause. Otherwise the WHERE filter discards the NULL-extended rows and turns it back into an inner join.

## 9. Key Takeaway

Lead-time metrics = `date - date` aggregated per group, with the NULL population excluded once in WHERE so every metric shares the same base.

---
📄 **SQL File:** [`Q162_Average_Days_To_Ship_Per_Shipper.sql`](./Q162_Average_Days_To_Ship_Per_Shipper.sql)
