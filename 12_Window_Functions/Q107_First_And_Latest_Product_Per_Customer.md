# Q107 · First And Latest Product Per Customer

> **Revision Card**
> **Category:** Window Functions (Value Functions) | **Difficulty:** Hard
> **Concepts:** FIRST_VALUE · LAST_VALUE · Window Frame · ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING · DISTINCT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** LAST_VALUE with the default frame returns the current row; extend the frame to UNBOUNDED FOLLOWING.

## 1. Problem

Customer success wants to understand how buying habits evolve: for each customer, the first product they ever bought and the product on their most recent order line.

**Objective:** For each customer, return the product on their earliest order line and the product on their latest order line (ordered by order date, then order ID, then product ID).

**Tables:** `orders`, `order_details`, `products`, `customers`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| company_name | Customer company name |
| first_product | Product on the customer's earliest order line |
| latest_product | Product on the customer's most recent order line |

| customer_id | company_name | first_product | latest_product |
|-------------|--------------|---------------|----------------|
| ALFKI | Alfreds Futterkiste | Northwoods Cranberry Sauce | Ipoh Coffee |
| ANATR | Ana Trujillo Emparedados | Pavlova | Tunnbröd |
| ANTON | Antonio Moreno Taquería | Guaraná Fantástica | Thüringer Rostbratwurst |
| AROUT | Around the Horn | Queso Cabrales | Chartreuse verte |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join orders, order lines and products.
2. Define a window per customer ordered by `order_date, order_id, product_id` with frame `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.
3. Take `FIRST_VALUE(product_name)` and `LAST_VALUE(product_name)`.
4. Collapse to one row per customer with `DISTINCT`; join customers; order by `customer_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
WITH customer_lines AS (
    SELECT
        o.customer_id,
        o.order_date,
        o.order_id,
        p.product_name,
        FIRST_VALUE(p.product_name) OVER w AS first_product,
        LAST_VALUE(p.product_name)  OVER w AS latest_product
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    JOIN products p       ON p.product_id = od.product_id
    WINDOW w AS (PARTITION BY o.customer_id
                 ORDER BY o.order_date, o.order_id, od.product_id
                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
SELECT DISTINCT
    cl.customer_id,
    c.company_name,
    cl.first_product,
    cl.latest_product
FROM customer_lines cl
JOIN customers c ON c.customer_id = cl.customer_id
ORDER BY customer_id;
```

## 6. Why This Works

`FIRST_VALUE` and `LAST_VALUE` return a value from the first or last row of the window frame. The trap is the default frame. With an `ORDER BY`, it is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, so `LAST_VALUE` just returns the current row. Extending the frame to `UNBOUNDED FOLLOWING` makes the whole partition visible, so `LAST_VALUE` really is the latest line.

Every line of a customer carries the same pair of values, so `DISTINCT` reduces it to one row per customer. The three-column window order makes 'first' and 'last' deterministic when several lines share an order.

## 7. Common Pitfalls (generic)

- Using `LAST_VALUE` with the default frame and getting the current row back.
- Not breaking ties within an order, so 'first product' depends on physical row order.
- Forgetting to deduplicate, producing one row per order line.
- Confusing 'latest order' with 'highest order_id' when IDs are not in date order.

## 8. Interview Follow-ups

**1. Is there a simpler way to get the latest value?**

Yes: `FIRST_VALUE(product_name) OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC, product_id DESC)`. Reversing the order makes the latest row first, and the default frame is then enough.

**2. How else could you collapse to one row per customer?**

Add `ROW_NUMBER()` to the CTE and keep `rn = 1` instead of `DISTINCT`. That is clearer and avoids sorting all columns for deduplication.

**3. What does NTH_VALUE do?**

`NTH_VALUE(x, n)` returns the n-th row's value in the frame, e.g. the second product bought. It has the same frame trap as `LAST_VALUE`.

## 9. Key Takeaway

`LAST_VALUE` needs `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` — the default frame stops at the current row.

---
📄 **SQL File:** [`Q107_First_And_Latest_Product_Per_Customer.sql`](./Q107_First_And_Latest_Product_Per_Customer.sql)
