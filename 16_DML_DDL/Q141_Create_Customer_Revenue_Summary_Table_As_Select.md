# Q141 · Create Customer Revenue Summary Table As Select

> **Revision Card**
> **Category:** DDL (CREATE TABLE AS) | **Difficulty:** Medium
> **Concepts:** CREATE TABLE AS · Aggregation · Primary Key via ALTER · Query the New Table
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** `CREATE TABLE AS` copies data and column types only — no primary key, indexes or defaults.

## 1. Problem

Analysts want a reporting table with one row per ordering customer (order count and net revenue) so dashboards do not re-aggregate order lines every time.

**Objective:** Create `customer_revenue_summary` from an aggregate query, add a primary key on `customer_id`, and return the top 10 customers by revenue from the new table. Runs inside `BEGIN … ROLLBACK`, so the data change is undone after grading.

**Tables:** `orders`, `order_details` → new `customer_revenue_summary`

**Expected output:**

| Column | Description |
|--------|-------------|
| customer_id | Customer identifier |
| order_count | Distinct orders |
| revenue | Net revenue, 2 dp |

| customer_id | order_count | revenue |
|-------------|-------------|---------|
| FOLKO | 2 | 12905.32 |
| GOURL | 1 | 9578.85 |
| BOLID | 2 | 8095.04 |
| ALFKI | 2 | 4703.69 |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `CREATE TABLE customer_revenue_summary AS SELECT ... GROUP BY customer_id`.
2. `ALTER TABLE ... ADD PRIMARY KEY (customer_id)`.
3. `SELECT` from the new table ordered by `revenue DESC, customer_id` with `LIMIT 10`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
CREATE TABLE customer_revenue_summary AS
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id)                                         AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY o.customer_id;

ALTER TABLE customer_revenue_summary ADD PRIMARY KEY (customer_id);

SELECT customer_id, order_count, revenue
FROM customer_revenue_summary
ORDER BY revenue DESC, customer_id
LIMIT 10;
```

## 6. Why This Works

`CREATE TABLE AS` (CTAS) materialises a query result as a new table, inferring column names from the aliases and types from the expressions. Constraints are not copied, so the primary key is added afterwards — which also verifies there is exactly one row per customer. In PostgreSQL, DDL is transactional, so the whole thing disappears on `ROLLBACK`.

## 7. Common Pitfalls (generic)

- Expecting CTAS to copy constraints or indexes from the source tables.
- Leaving expressions without aliases — the column becomes `?column?` or `sum`.
- A CTAS table is a snapshot; it does not refresh when the source data changes.

## 8. Interview Follow-ups

**1. CTAS vs `CREATE MATERIALIZED VIEW`?**

A materialized view stores the query and can be refreshed with `REFRESH MATERIALIZED VIEW`; a CTAS table is a plain table you must rebuild yourself.

**2. How do you create an empty copy of a table's structure?**

`CREATE TABLE t2 (LIKE t1 INCLUDING ALL)` or `CREATE TABLE t2 AS SELECT * FROM t1 WITH NO DATA`.

**3. Is DDL transactional in PostgreSQL?**

Yes — `CREATE`, `ALTER` and `DROP` can be rolled back (unlike MySQL/Oracle, which commit implicitly).

## 9. Key Takeaway

CTAS snapshots a query into a table; add keys afterwards, and remember it never refreshes on its own.

---
📄 **SQL File:** [`Q141_Create_Customer_Revenue_Summary_Table_As_Select.sql`](./Q141_Create_Customer_Revenue_Summary_Table_As_Select.sql)
