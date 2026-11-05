# Q200 · Customer Buying Episodes (Sessionization)

> **Revision Card**
> **Category:** Window Functions (Sessionization) | **Difficulty:** Hard
> **Concepts:** LAG · PARTITION BY · Running SUM of flags · COUNT DISTINCT · Date arithmetic
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** A new episode starts on a customer's first order or after a gap of more than 60 days.

## 1. Problem

Marketing measures loyalty by buying episodes: a burst of orders from a customer, separated from the next burst by more than 60 days without an order.

**Objective:** For each customer with at least two orders, count their buying episodes, their orders, and the days between their first and last order; most episodes first.

**Tables:** `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer |
| buying_episodes | Episodes separated by more than 60 days |
| orders | Total orders |
| span_days | Days from first to last order |

| customer_id | buying_episodes | orders | span_days |
|-------------|-----------------|--------|-----------|
| BONAP | 2 | 3 | 876 |
| ALFKI | 2 | 2 | 585 |
| ANATR | 2 | 2 | 584 |
| ANTON | 2 | 2 | 509 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. LAG(order_date) per customer gives the gap to their previous order.
2. Flag 1 when the gap is NULL (first order) or over 60 days; a running SUM per customer numbers the episodes.
3. Group by customer: COUNT(DISTINCT episode), COUNT(*), MAX − MIN date.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH gaps AS (
    SELECT customer_id, order_id, order_date,
           order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS gap
    FROM orders
    WHERE customer_id IS NOT NULL
),
flagged AS (
    SELECT *, SUM(CASE WHEN gap IS NULL OR gap > 60 THEN 1 ELSE 0 END)
                OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS episode
    FROM gaps
)
SELECT customer_id,
       COUNT(DISTINCT episode)                       AS buying_episodes,
       COUNT(*)                                      AS orders,
       MAX(order_date) - MIN(order_date)             AS span_days
FROM flagged
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY buying_episodes DESC, orders DESC, customer_id;
```

## 6. Why This Works

Sessionization is gaps and islands within each customer. PARTITION BY restarts LAG and the running SUM for every customer, so episode numbers are per customer. Counting distinct episode numbers gives the number of bursts without needing another query level.

## 7. Common Pitfalls (generic)

- Leaving out PARTITION BY, which compares one customer's order with another customer's.
- Forgetting that the first order has a NULL gap and must start episode 1.
- Using > 60 on a timestamp difference instead of date arithmetic, which returns an interval.

## 8. Interview Follow-ups

**1. How would you get each episode's start and end?**

Group by customer_id and episode instead of customer_id alone.

**2. How would you make the 60-day threshold depend on the customer?**

Join a per-customer threshold (for example their median gap) and compare gap > threshold.

**3. What's the time-on-site equivalent?**

Web sessions use the same pattern with a 30-minute inactivity gap between events.

## 9. Key Takeaway

Sessionize with LAG for the gap, a flag for 'new session', and a running SUM of flags as the session id.

---
📄 **SQL File:** [`Q200_Customer_Buying_Episodes_Sessionization.sql`](./Q200_Customer_Buying_Episodes_Sessionization.sql)
