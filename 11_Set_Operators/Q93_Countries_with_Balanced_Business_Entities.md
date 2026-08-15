# Q93. Countries with Balanced Business Entities

**Category:** SELECT
**Difficulty:** Advanced

---

## Problem Statement

The company wants to identify countries that have representation across all three entity types: employees, suppliers, and customers. A country should be considered balanced only when it has at least one employee, at least one supplier, and at least one customer.

## Objective

Return countries that contain at least one employee, one supplier, and one customer. Display the number of each entity type for every qualifying country.

---

## Tables Used

- `employees`
- `suppliers`
- `customers`

## Expected Output

The query should return the following columns:

| Column Name | Description |
|---|---|
| `country` | Country containing all three entity types |
| `total_employees` | Number of employees in the country |
| `total_suppliers` | Number of suppliers in the country |
| `total_customers` | Number of customers in the country |

### Output Format

| country | total_employees | total_suppliers | total_customers |
|---|---:|---:|---:|
| USA | 5 | 4 | 13 |
| Germany | 1 | 3 | 11 |

*Sample values are illustrative. Actual values should be obtained from the Northwind database.*

---

## Concepts Used

- UNION
- ALL
- CTE
- Conditional
- Aggregation
- CASE
- SUM
- GROUP
- BY
- HAVING

## Approaches

### ✅ Correct Approach

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
       )!=0
```

## Why This Approach

### Data Combination

Combine employees, suppliers, and customers into a common dataset containing `country` and an entity-type identifier.

### Conditional Aggregation

Count each entity type independently for every country.

### Grouping

Group the combined data by country so that each country produces one result row.

### Filtering

Only retain countries that have a non-zero count for all three entity types.

---

## Common Mistakes

- Returning countries that have only one or two of the required entity types.
- Using `UNION` instead of `UNION ALL`, which can remove duplicate rows before aggregation.
- Filtering individual rows instead of filtering the aggregated country-level results.
- Forgetting to group by `country`.
- Using `COUNT(*)` for each entity type without distinguishing the entity type.

## Difficulty

**Advanced**

## Interview Follow-up Questions

**1. Why is `UNION ALL` preferable to `UNION` for this type of aggregation?**

[Answer will be added after solving.]

**2. How can you verify that a country contains all three entity types?**

[Answer will be added after solving.]

**3. Could this problem be solved using three separate CTEs and joins?**

[Answer will be added after solving.]

**4. Why is conditional aggregation useful for this problem?**

[Answer will be added after solving.]

**5. What is the difference between filtering with `WHERE` and filtering the aggregated result with `HAVING`?**

[Answer will be added after solving.]

---


## Learning Outcomes

- Combine multiple entity sources using `UNION ALL`.
- Perform conditional aggregation.
- Identify groups satisfying multiple conditions.
- Use `HAVING` for post-aggregation filtering.
- Build multi-source analytical queries.
- 📄 SQL File: [`Q91_Countries_With_Balanced_Business_Entities.sql`](./Q91_Countries_With_Balanced_Business_Entities.sql)
