# Q201 · Each Customer's Favourite Product With LATERAL

> **Revision Card**
> **Category:** Correlated Subqueries (LATERAL Top-1 per Group) | **Difficulty:** Hard
> **Concepts:** CROSS JOIN LATERAL · Correlated subquery in FROM · ORDER BY + LIMIT 1 · Tie-breaking
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** LATERAL lets the subquery refer to c.customer_id; CROSS JOIN drops customers with no orders.

## 1. Problem

The CRM team wants to personalise emails with each customer's most-bought product.

**Objective:** For every customer who has ordered, show the product they bought the most units of (ties broken by product name) and the units, highest first.

**Tables:** `customers`, `orders`, `order_details`, `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer |
| company_name | Company |
| product_name | Most-bought product |
| units | Units of that product |

| customer_id | company_name | product_name | units |
|-------------|--------------|--------------|-------|
| BOLID | Bólido Comidas preparadas | Inlagd Sill | 47 |
| BLONP | Blondesddsl père et fils | Rössle Sauerkraut | 43 |
| GOURL | Gourmet Lanchonetes | Rogede sild | 40 |
| GREAL | Great Lakes Food Market | Chartreuse verte | 40 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. FROM customers c CROSS JOIN LATERAL (subquery).
2. The subquery sums units per product for c.customer_id, orders by units DESC, product_name, LIMIT 1.
3. Order the result by units, then customer_id.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT c.customer_id, c.company_name, top.product_name, top.units
FROM customers c
CROSS JOIN LATERAL (
    SELECT p.product_name, SUM(d.quantity) AS units
    FROM orders o
    JOIN order_details d ON d.order_id = o.order_id
    JOIN products p ON p.product_id = d.product_id
    WHERE o.customer_id = c.customer_id
    GROUP BY p.product_name
    ORDER BY units DESC, p.product_name
    LIMIT 1
) AS top
ORDER BY top.units DESC, c.customer_id;
```

## 6. Why This Works

A LATERAL subquery runs once per outer row and can use that row's columns, which makes 'top N per group' direct: sort inside the subquery and take LIMIT 1. CROSS JOIN LATERAL keeps only customers for whom the subquery returns a row, i.e. customers with orders; LEFT JOIN LATERAL ... ON true would keep the others with NULLs.

## 7. Common Pitfalls (generic)

- Leaving out LATERAL: a plain subquery in FROM can't see c.customer_id.
- No tie-breaker in the inner ORDER BY, which makes the chosen product depend on the plan.
- Using LEFT JOIN LATERAL without ON true (it requires an ON clause).

## 8. Interview Follow-ups

**1. How would you return the top 3 products per customer?**

Change LIMIT 1 to LIMIT 3; the outer query then has up to three rows per customer.

**2. What's the window-function alternative?**

ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY units DESC, product_name) over a grouped CTE, keeping rn = 1.

**3. When is LATERAL faster?**

When an index lets each inner query stop after a few rows, for example top-N by date with an index on (customer_id, order_date).

## 9. Key Takeaway

LATERAL is a per-row subquery in FROM: the cleanest way to write top-N per group.

---
📄 **SQL File:** [`Q201_Each_Customers_Favourite_Product_With_LATERAL.sql`](./Q201_Each_Customers_Favourite_Product_With_LATERAL.sql)
