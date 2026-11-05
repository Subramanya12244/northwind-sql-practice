# Q194 · Customers Whose Every Order Shipped On Time

> **Revision Card**
> **Category:** Correlated Subqueries (Universal Condition with NOT EXISTS) | **Difficulty:** Medium
> **Concepts:** NOT EXISTS · Correlated subquery · Universal quantification · NULL handling
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** 'Every order is on time' means 'no order is late or unshipped' — test the opposite with NOT EXISTS.

## 1. Problem

Logistics wants a list of customers who have never had a late or still-unshipped order, to use as a reference group for service quality.

**Objective:** List customers with at least one order where none of their orders is unshipped or shipped after its required date, with their number of orders, most orders first.

**Tables:** `customers`, `orders`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer |
| company_name | Company |
| shipped_orders | Number of orders (all on time) |

| customer_id | company_name | shipped_orders |
|-------------|--------------|----------------|
| ANTON | Antonio Moreno Taquería | 2 |
| AROUT | Around the Horn | 2 |
| BLAUS | Blauer See Delikatessen | 2 |
| BLONP | Blondesddsl père et fils | 2 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join customers to their orders and group, so customers without orders drop out.
2. WHERE NOT EXISTS (an order of this customer that is unshipped OR shipped later than required).
3. Order by order count, then customer_id.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT c.customer_id, c.company_name, COUNT(*) AS shipped_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
      AND (o2.shipped_date IS NULL OR o2.shipped_date > o2.required_date)
)
GROUP BY c.customer_id, c.company_name
ORDER BY shipped_orders DESC, c.customer_id;
```

## 6. Why This Works

SQL has no direct 'for all'. The standard way to say 'every order is on time' is 'there is no order that is late', which is NOT EXISTS with a correlated subquery. Unshipped orders have a NULL shipped_date, and a comparison with NULL is unknown, so the subquery tests IS NULL explicitly.

## 7. Common Pitfalls (generic)

- Checking shipped_date <= required_date in the outer WHERE, which drops late orders but keeps the customer.
- Forgetting unshipped orders: shipped_date > required_date is not true for NULL, so they would slip through.
- Using NOT IN with a subquery that can return NULL, which makes NOT IN return no rows at all.

## 8. Interview Follow-ups

**1. How would you return customers whose orders were all late instead?**

Swap the condition: NOT EXISTS (an order that was shipped on time).

**2. How else could you express this?**

GROUP BY customer and HAVING COUNT(*) FILTER (WHERE shipped_date IS NULL OR shipped_date > required_date) = 0.

**3. Why does NOT EXISTS usually perform well?**

PostgreSQL turns it into an anti-join and can stop at the first matching row per customer.

## 9. Key Takeaway

'For every row' is written as 'there is no row that breaks the rule': NOT EXISTS.

---
📄 **SQL File:** [`Q194_Customers_Whose_Every_Order_Shipped_On_Time.sql`](./Q194_Customers_Whose_Every_Order_Shipped_On_Time.sql)
