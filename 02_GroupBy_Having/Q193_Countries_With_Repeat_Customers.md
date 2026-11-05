# Q193 · Countries With Repeat Customers

> **Revision Card**
> **Category:** GROUP BY & HAVING (Two-Level Aggregation) | **Difficulty:** Medium
> **Concepts:** CTE · Two-level GROUP BY · COUNT FILTER · HAVING · Percentages
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Count orders per customer first, then count customers per country: one GROUP BY can't do both.

## 1. Problem

Customer success wants to know where customers come back: in which countries do customers place more than one order?

**Objective:** For each country, count customers who ordered at all, how many of them ordered at least twice, and the repeat share in percent (1 dp). Only list countries with at least one repeat customer, highest share first.

**Tables:** `customers`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| country | Customer country |
| ordering_customers | Customers with at least one order |
| repeat_customers | Customers with two or more orders |
| repeat_pct | repeat_customers ÷ ordering_customers × 100, 1 dp |

| country | ordering_customers | repeat_customers | repeat_pct |
|---------|--------------------|------------------|------------|
| Sweden | 2 | 2 | 100.0 |
| Mexico | 5 | 2 | 40.0 |
| Spain | 4 | 1 | 25.0 |
| France | 10 | 2 | 20.0 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. CTE: orders per customer (customer_id, country, COUNT).
2. Outer query: group the CTE by country.
3. COUNT(*) FILTER (WHERE order_count >= 2) gives repeat customers; HAVING keeps countries with at least one.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH customer_orders AS (
    SELECT c.customer_id, c.country, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT country,
       COUNT(*)                                    AS ordering_customers,
       COUNT(*) FILTER (WHERE order_count >= 2)    AS repeat_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE order_count >= 2) / COUNT(*), 1) AS repeat_pct
FROM customer_orders
GROUP BY country
HAVING COUNT(*) FILTER (WHERE order_count >= 2) >= 1
ORDER BY repeat_pct DESC, country;
```

## 6. Why This Works

The question has two levels: orders per customer, then customers per country. Aggregating twice needs two steps, so the first count lives in a CTE. FILTER (WHERE …) counts only the rows that meet a condition without a CASE expression, and multiplying by 100.0 forces decimal division.

## 7. Common Pitfalls (generic)

- Grouping by country directly and counting orders, which measures order volume, not repeat customers.
- Integer division: COUNT(...) / COUNT(*) * 100 truncates to 0 or 100; use 100.0.
- Repeating the FILTER expression in HAVING is fine; referring to the alias repeat_customers in HAVING is not allowed in PostgreSQL.

## 8. Interview Follow-ups

**1. How would you count customers with no orders in the denominator?**

Start from customers with a LEFT JOIN to orders and count COUNT(o.order_id) per customer, so non-buyers appear with 0.

**2. Could you do this without a CTE?**

Yes, with a derived table in FROM, but the CTE names the intermediate step and reads better.

**3. How would you compare repeat rates across years?**

Add DATE_TRUNC('year', order_date) to the first grouping and group the outer query by country and year.

## 9. Key Takeaway

When a metric aggregates an aggregate, compute the inner level in a CTE and aggregate it again.

---
📄 **SQL File:** [`Q193_Countries_With_Repeat_Customers.sql`](./Q193_Countries_With_Repeat_Customers.sql)
