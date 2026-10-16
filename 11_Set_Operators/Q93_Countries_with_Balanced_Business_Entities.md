# Q93 · Countries with Balanced Business Entities

> **Revision Card**
> **Category:** Set Operators (UNION ALL + Conditional Aggregation) | **Difficulty:** Advanced
> **Concepts:** UNION ALL · CTE · Conditional Aggregation (SUM + CASE) · GROUP BY · HAVING
> **Outcome:** ✅ correct first attempt
> **Watch out for:** filter with `HAVING` on each entity's aggregate count (`!= 0`), not on individual rows — a country qualifies only when all three counts are non-zero.

## 1. Problem

The company wants to identify countries that have representation across all three entity types: employees, suppliers, and customers. A country should be considered balanced only when it has at least one employee, at least one supplier, and at least one customer.

**Objective:** Return countries that contain at least one employee, one supplier, and one customer. Display the number of each entity type for every qualifying country.

**Tables:** `employees`, `suppliers`, `customers`

**Expected output:**

| Column Name | Description |
|---|---|
| `country` | Country containing all three entity types |
| `total_employees` | Number of employees in the country |
| `total_suppliers` | Number of suppliers in the country |
| `total_customers` | Number of customers in the country |

**Output format:**

| country | total_employees | total_suppliers | total_customers |
|---|---:|---:|---:|
| USA | 5 | 4 | 13 |
| Germany | 1 | 3 | 11 |

*Sample values are illustrative. Actual values should be obtained from the Northwind database.*

## 2. My Approach

1. **Data combination** — combine employees, suppliers, and customers into a common dataset containing `country` and an entity-type identifier, using `UNION ALL` inside a CTE.
2. **Conditional aggregation** — count each entity type independently for every country with `SUM(CASE WHEN entity = ... THEN 1 ELSE 0 END)`.
3. **Grouping** — group the combined data by country so that each country produces one result row.
4. **Filtering** — keep only countries where all three per-entity counts are non-zero, using `HAVING` on each `SUM(CASE ...)` expression.

## 3. My Solution (as submitted)

```sql
WITH cte AS (
     SELECT    e.country,
     'employees' AS entity
     FROM      employees e
     UNION all
     SELECT    s.country,
     'supplier' AS entity
     FROM      suppliers s
     UNION all
     SELECT    c.country,
     'customers' AS entity
     FROM      customers c
     )
SELECT country,
       sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) as total_employees,
       sum(
       CASE
       WHEN entity = 'supplier' THEN 1
       ELSE 0
       END
       ) as total_suppliers,
       sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       ) as total_customers
FROM cte
GROUP BY country
HAVING sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) != 0
AND sum(
    CASE
    WHEN entity = 'supplier' THEN 1
    ELSE 0
    END
    ) != 0
AND sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       ) != 0;
```

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Data combination:** Combine employees, suppliers, and customers into a common dataset containing `country` and an entity-type identifier. `UNION ALL` preserves every row — essential because the counts depend on every individual record being present.

**Conditional aggregation:** Count each entity type independently for every country. `SUM(CASE WHEN entity = 'employees' THEN 1 ELSE 0 END)` tallies only the employee rows per country, and the parallel expressions do the same for suppliers and customers — all in a single pass over the grouped data.

**Grouping:** Group the combined data by country so that each country produces exactly one result row carrying all three counts.

**Filtering:** Only retain countries that have a non-zero count for all three entity types. Because the condition is on aggregate results, it must live in `HAVING` (post-aggregation), not `WHERE` (pre-aggregation). Requiring all three `SUM(CASE ...) != 0` guarantees the country has at least one of each entity — the definition of "balanced."

## 7. Common Pitfalls (generic)

- Returning countries that have only one or two of the required entity types.
- Using `UNION` instead of `UNION ALL`, which can remove duplicate rows before aggregation and corrupt the counts.
- Filtering individual rows instead of filtering the aggregated country-level results.
- Forgetting to group by `country`.
- Using `COUNT(*)` for each entity type without distinguishing the entity type.

## 8. Interview Follow-ups

**1. Why is `UNION ALL` preferable to `UNION` for this type of aggregation?**

`UNION ALL` keeps every row, which is exactly what counting requires. Here each branch produces only `(country, entity)` pairs, so many rows are identical — e.g. every USA employee yields the same `('USA', 'employees')` row. `UNION` would deduplicate those identical rows, collapsing all USA employees into a single row and making `SUM(CASE WHEN entity = 'employees' THEN 1 ELSE 0 END)` return 1 instead of 5. `UNION ALL` preserves one row per source record, so the counts are correct.

**2. How can you verify that a country contains all three entity types?**

After the `UNION ALL` + `GROUP BY country`, compute a per-entity count with `SUM(CASE WHEN entity = ... THEN 1 ELSE 0 END)` for employees, suppliers, and customers. A country is "balanced" only when all three of those aggregate counts are greater than zero. The `HAVING` clause enforces this by requiring each `SUM(CASE ...) != 0`, so any country missing even one entity type is dropped.

**3. Could this problem be solved using three separate CTEs and joins?**

Yes — you could build one CTE per entity (`SELECT country, COUNT(*) FROM employees GROUP BY country`, etc.) and `INNER JOIN` them on `country`. Because an inner join only keeps countries present in all three, the join itself enforces the "all three entity types" rule, removing the need for the `HAVING` check. The `UNION ALL` + conditional aggregation approach is more compact and scans each source once, but the three-CTE join is often more readable and extends naturally if you need entity-specific columns.

**4. Why is conditional aggregation useful for this problem?**

Conditional aggregation (`SUM(CASE WHEN entity = ... THEN 1 ELSE 0 END)`) lets you produce three separate counts from a single pass over one combined, grouped dataset. Instead of three queries or three joins, each `CASE` acts as a filter that contributes 1 only for its own entity type, so one `GROUP BY country` yields `total_employees`, `total_suppliers`, and `total_customers` side by side — perfect for both display and the `HAVING` filter.

**5. What is the difference between filtering with `WHERE` and filtering the aggregated result with `HAVING`?**

`WHERE` filters individual rows before grouping and aggregation, so it cannot reference `SUM`/`COUNT` results. `HAVING` filters after `GROUP BY`, operating on the aggregate values. The balanced-country condition depends on per-entity counts that only exist after aggregation, so it must live in `HAVING` (`HAVING SUM(CASE ...) != 0`). Trying to express it in `WHERE` would be impossible because the counts do not yet exist at that stage.

## 9. Key Takeaway

Combine independent sources with `UNION ALL`, count each type with conditional aggregation, then use `HAVING` to require every per-entity count be non-zero — the standard pattern for "groups that satisfy multiple presence conditions."

---
📄 **SQL File:** [`Q93_Countries_with_Balanced_Business_Entities.sql`](./Q93_Countries_with_Balanced_Business_Entities.sql)
