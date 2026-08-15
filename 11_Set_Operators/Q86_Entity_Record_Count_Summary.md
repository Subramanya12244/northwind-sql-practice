# Q86. Entity Record Count Summary

**Category:** Set Operators (UNION ALL + Aggregation)
**Difficulty:** Hard

---

## Problem Statement

The management team wants a summary report showing how many records exist for each business entity — customers, suppliers, and employees — in a single query.

## Objective

Return `Entity_Type` and `Total_Records` for each entity, showing the total row count per table in one unified report.

## Tables Used

- `customers`
- `suppliers`
- `employees`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| Entity_Type | Name of the entity (`'Customer'`, `'Supplier'`, `'Employee'`) |
| Total_Records | Total number of rows in that entity's source table |

**Sample output:**

| Entity_Type | Total_Records |
|-------------|---------------|
| Customer | 91 |
| Supplier | 29 |
| Employee | 9 |

## Concepts Used

- UNION ALL (within CTE)
- CTE (Common Table Expression)
- GROUP BY
- Aggregate Functions (COUNT)
- Subquery / derived table pattern

## The Two Approaches

This question has two valid approaches — both documented here since your review session worked through both.

---

### ❌ First Attempt — Direct UNION of aggregated queries

```sql
select 'employee' as Entity_Type, count(*) from employees e
union
select 'Supplier' as Entity_Type, count(*) from suppliers s
union
select 'Customer' as Entity_Type, count(*) from customers c
```

**Why this technically works but has issues:**

Structurally, this produces the correct result — each SELECT aggregates its own table and returns one row, and UNION combines the three rows. However, there are two problems:

1. **`'employee'` is lowercase** — inconsistent capitalisation vs `'Supplier'` and `'Customer'`. Same issue as Q82/Q83.
2. **UNION instead of UNION ALL** — since each SELECT returns exactly one row (the count), and no two rows have identical `(Entity_Type, count)` values, UNION and UNION ALL are equivalent here. But this is only coincidentally correct — using `UNION` is conceptually wrong. The intent is not "deduplicate these results" (there are no duplicates to remove); the intent is "stack three independent counts." `UNION ALL` is the semantically correct choice.
3. **It doesn't follow the "build one dataset first, then summarise" pattern** — each SELECT does its own aggregation independently. This works for simple counts but doesn't scale to more complex analysis (e.g. "count per entity type AND per country").

---

### ✅ Correct Approach — CTE with UNION ALL, then aggregate

```sql
WITH cte_1 AS (
    SELECT 'Employee' AS Entity_Type FROM employees
    UNION ALL
    SELECT 'Supplier' AS Entity_Type FROM suppliers
    UNION ALL
    SELECT 'Customer' AS Entity_Type FROM customers
)
SELECT Entity_Type, COUNT(*) AS Total_Records
FROM cte_1
GROUP BY Entity_Type;
```

**Why this is the preferred approach:**

The CTE first builds a unified flat dataset where every row carries only its entity type label — one row per employee, one per supplier, one per customer. The outer query then aggregates by `Entity_Type`, counting how many rows of each type exist. This is the "standardise first, then summarise" ETL pattern.

**Why `UNION ALL` inside the CTE (not `UNION`):** the CTE's purpose is to stack all rows from all three tables into one flat list — every row must be preserved. If `UNION` were used, rows with identical `Entity_Type` values would be deduplicated — but every employee row has `Entity_Type = 'Employee'`, so `UNION` would collapse all 9 employee rows into 1. The `COUNT(*)` in the outer query would then count 1 instead of 9. `UNION ALL` is mandatory here to preserve all rows for correct counting.

**Why this approach scales better:** the intermediate dataset (the CTE) can be extended to include more columns (e.g. `city`, `country`) without changing the aggregation logic. The two steps — standardise, then summarise — are cleanly separated, making the query easier to read, debug, and extend.

## Common Mistakes

- **Using `UNION` inside the CTE instead of `UNION ALL`** — deduplicates the intermediate dataset, causing `COUNT(*)` to return 1 for every entity type instead of the actual row count. This is the most critical mistake in this question.
- **First attempt: `'employee'` lowercase** — inconsistent capitalisation. Use `'Employee'` consistently.
- **First attempt: using `UNION` between three pre-aggregated queries** — works coincidentally (three rows with distinct values won't be deduplicated), but is semantically incorrect and doesn't demonstrate the "ETL pipeline" thinking the question is testing.
- **Selecting unnecessary columns inside the CTE** — the CTE only needs `Entity_Type` for grouping. Adding name, city, etc. increases the dataset size without improving the result.

## Difficulty

**Hard**

## Interview Follow-up Questions

**1. Why must `UNION ALL` (not `UNION`) be used inside the CTE?**

The CTE's job is to produce a flat list of all rows across all three tables, each tagged with its entity type. If `UNION` were used instead of `UNION ALL`, it would deduplicate the intermediate dataset. Since every employee row has `Entity_Type = 'Employee'`, `UNION` would collapse all 9 employee rows into a single row (they are identical — they all contain only the string `'Employee'`). The outer `COUNT(*)` would then count 1 employee instead of 9. `UNION ALL` preserves every row, making `COUNT(*)` in the outer query produce the correct totals. This is the single most important distinction in this question.

**2. What is the "standardise first, then summarise" pattern, and why does it matter in real data engineering?**

The pattern mirrors how ETL (Extract, Transform, Load) pipelines work: first bring data from multiple sources into a common, uniform format (the CTE with `UNION ALL`); then aggregate, filter, or transform that unified dataset (the outer `SELECT ... GROUP BY`). This separation of concerns makes the code easier to reason about — the CTE handles data unification, the outer query handles analysis. It also makes the query more extensible: to add country-level counts, you add `country` to the CTE and the GROUP BY, without restructuring the overall approach. The first attempt (UNION of pre-aggregated queries) fuses both steps together, which works for simple counts but doesn't extend cleanly.

**3. How would you extend this to show the count per entity type AND per country in one query?**

Add `country` to the CTE (using `'N/A'` for shippers or employees if needed) and group by both columns:
```sql
WITH entity_data AS (
    SELECT 'Customer' AS entity_type, country FROM customers
    UNION ALL
    SELECT 'Supplier', country FROM suppliers
    UNION ALL
    SELECT 'Employee', country FROM employees
)
SELECT entity_type, country, COUNT(*) AS total_records
FROM entity_data
GROUP BY entity_type, country
ORDER BY entity_type, total_records DESC;
```

**4. Could you solve this without a CTE — using a subquery instead?**

Yes — the CTE is just a named subquery. An equivalent inline version:
```sql
SELECT Entity_Type, COUNT(*) AS Total_Records
FROM (
    SELECT 'Employee' AS Entity_Type FROM employees
    UNION ALL
    SELECT 'Supplier' FROM suppliers
    UNION ALL
    SELECT 'Customer' FROM customers
) sub
GROUP BY Entity_Type;
```
Both the CTE version and the subquery version are logically identical. The CTE is preferred for readability and reusability (the CTE can be referenced multiple times in the outer query if needed).

**5. The first attempt used UNION between pre-aggregated queries. When is that approach appropriate vs the CTE+UNION ALL approach?**

Pre-aggregated UNION (first approach) is appropriate when: each SELECT independently computes a summary that can't be easily combined into a single flat dataset — e.g. "show me the max revenue from customers, the max revenue from suppliers, and the total freight from orders" are three structurally different aggregations that can only be cleanly expressed as separate queries combined by UNION. The CTE+UNION ALL approach is appropriate when: all sources contribute the same type of row and you want a consistent aggregation across them — exactly this question. The rule: if you're counting or aggregating the same metric (row count, revenue, etc.) per entity type, use CTE+UNION ALL. If you're computing different aggregations per source, use UNION of pre-aggregated queries.

## Learning Outcomes

- Understand that `UNION ALL` is mandatory inside a CTE when that CTE is used as the source for `COUNT(*)` — `UNION` would deduplicate and produce wrong counts.
- Internalise the "standardise first (UNION ALL), then summarise (GROUP BY)" ETL pattern — a fundamental data engineering workflow.
- Know when to prefer the CTE+UNION ALL approach vs UNION of pre-aggregated queries based on whether the aggregation is uniform across sources.
- Recognise that the CTE approach scales more naturally to multi-dimensional analysis (adding `country`, `city`, date ranges) without restructuring the query.

---

📄 **SQL File:** [`Q86_Entity_Record_Count_Summary.sql`](./Q86_Entity_Record_Count_Summary.sql)
