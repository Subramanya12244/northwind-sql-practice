# Q38. Shippers and Total Orders Handled

**Category:** LEFT JOIN
**Difficulty:** Easy

---

## Problem Statement

The logistics department wants a report showing every shipping company and the total number of orders handled. Shipping companies that have not handled any orders should also appear with an order count of 0.

## Objective

Return all shipping companies along with the total number of orders they have handled, ensuring shippers with no orders appear with a count of 0.

## Tables Used

- `shippers`
- `orders`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| company_name | Name of the shipping company |
| total_orders | Total number of orders handled by this shipper (0 if none) |

**Sample output:**

| company_name | total_orders |
|--------------|--------------|
| Speedy Express | 249 |
| United Package | 326 |
| Federal Shipping | 255 |
| New Shipper Co | 0 |

*(Sample values are illustrative, based on the standard Northwind dataset, and intended to show shape/format — not guaranteed to match your exact data instance.)*

## Concepts Used

- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT)
- NULL Handling

## Why This Approach

**Why `LEFT JOIN shippers → orders`:** preserves every shipper row regardless of whether any orders reference them. An `INNER JOIN` would silently drop shippers with zero orders, violating the requirement. `LEFT JOIN` keeps every row from `shippers` and produces a NULL-padded row for any shipper with no matching orders.

**Why `COUNT(o.order_id)` and not `COUNT(*)`:** for a shipper with no orders, the `LEFT JOIN` produces one output row with `o.order_id = NULL`. `COUNT(o.order_id)` counts only non-NULL values, returning `0` correctly. `COUNT(*)` would count the NULL-padded row as `1`, incorrectly implying one order exists. This is the same critical distinction as Q35, Q36 — always count a column from the joined table, never `COUNT(*)`, when outer join NULL rows are possible.

**Why the join condition is `ship_via = shipper_id`:** `orders.ship_via` is the foreign key referencing `shippers.shipper_id`. The columns have different names in Northwind, so the join condition must explicitly map them — `ON o.ship_via = s.shipper_id`. Your solution omits the table aliases on the join columns (`ship_via = shipper_id`), which works in PostgreSQL as long as the column names are unambiguous across the tables in scope, but including aliases (`o.ship_via = s.shipper_id`) is a safer and more readable habit that prevents ambiguity errors if additional tables are ever added to the query.

**Why `GROUP BY s.company_name, s.shipper_id`:** `shipper_id` is the unique key; `company_name` is included because it is a non-aggregated selected column. Both are required in `GROUP BY` to satisfy PostgreSQL's rule and to prevent silent merges of shippers with identical names.

## Common Mistakes

- Using `INNER JOIN`, which drops shippers with no orders from the result.
- Using `COUNT(*)` instead of `COUNT(o.order_id)`, returning `1` for empty shippers instead of `0`.
- Writing the join condition without table aliases (`ship_via = shipper_id`) — works here but becomes ambiguous and error-prone when the query is extended with additional tables.
- Grouping on `company_name` alone instead of including `shipper_id`.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Why is this query structurally the same as Q35 and Q36, and what changes?**

The structure is identical — `LEFT JOIN parent → child`, `COUNT(child.key)`, `GROUP BY parent_id, parent_name`. Only the tables and join key change: `shippers`/`shipper_id`/`ship_via` replaces `categories`/`category_id` or `suppliers`/`supplier_id`. The anti-`COUNT(*)` rule, the LEFT JOIN requirement, and the GROUP BY discipline are all unchanged. Recognising this template across different table pairs is the core skill being reinforced.

**2. Your SQL writes `ship_via = shipper_id` without table aliases in the ON clause. What risk does this carry?**

In this specific query it works because `ship_via` only exists in `orders` and `shipper_id` only exists in `shippers` — PostgreSQL can resolve them unambiguously. But if a third table were added that also had a column named `ship_via` or `shipper_id`, the query would either break with an ambiguity error or silently join on the wrong column. The safe habit is always to qualify join columns with their table alias: `ON o.ship_via = s.shipper_id`.

**3. How would you extend this to also show total revenue handled per shipper?**

Join in `order_details` and sum revenue alongside the order count:

```sql
SELECT
    s.company_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS total_revenue
FROM shippers s
LEFT JOIN orders o ON o.ship_via = s.shipper_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY s.company_name, s.shipper_id
ORDER BY total_revenue DESC;
```

Note: `COUNT(DISTINCT o.order_id)` is used here instead of `COUNT(o.order_id)` because joining `order_details` produces multiple rows per order (one per line item), which would inflate the plain order count without `DISTINCT`.

**4. How would you find which shipper handles the highest average order value?**

Use a CTE to compute per-order revenue, then average per shipper:

```sql
WITH order_revenue AS (
    SELECT order_id,
           SUM(unit_price * quantity * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
)
SELECT
    s.company_name,
    ROUND(AVG(r.order_total)::numeric, 2) AS avg_order_value
FROM shippers s
LEFT JOIN orders o ON o.ship_via = s.shipper_id
LEFT JOIN order_revenue r ON r.order_id = o.order_id
GROUP BY s.company_name, s.shipper_id
ORDER BY avg_order_value DESC;
```

**5. In the real Northwind dataset all three shippers have orders. Why use LEFT JOIN anyway?**

Because the query design should be correct by intent, not by coincidence of current data. A new shipper could be added to the system before being assigned any orders — with `INNER JOIN`, that shipper would silently disappear from the logistics report, giving management an incomplete picture. `LEFT JOIN` future-proofs the query at zero performance cost for three small tables.

## Learning Outcomes

- Reinforce the `LEFT JOIN` + `COUNT(joined_column)` template as a directly transferable pattern across any "all entities with their activity count" report.
- Understand the importance of qualifying join columns with table aliases to prevent silent ambiguity bugs as queries grow.
- Recognise that `COUNT` never needs `COALESCE`, and that using it anyway (while harmless) signals an incomplete understanding of aggregate NULL behaviour.

---

📄 **SQL File:** [`Q38_Shippers_And_Total_Orders_Handled.sql`](./Q38_Shippers_And_Total_Orders_Handled.sql)
