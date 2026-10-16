# Q97. Countries with More Customers Than Their Entity Average

**Category:** SELECT
**Difficulty:** Expert

---

## Problem Statement

The company wants to identify countries where the number of customers is greater than the average number of entities represented in that country.

For each country, calculate the number of employees, suppliers, and customers. Then calculate the average number of entities for that country and identify countries where the customer count is greater than this entity average.

## Objective

Return countries where:

`total_customers > average(total_employees, total_suppliers, total_customers)`

Display the individual entity counts and the calculated entity average.

---

## Tables Used

- `employees`
- `suppliers`
- `customers`

## Expected Output

| Column Name | Description |
|---|---|
| `country` | Country being evaluated |
| `total_employees` | Number of employees in the country |
| `total_suppliers` | Number of suppliers in the country |
| `total_customers` | Number of customers in the country |
| `entity_average` | Average of the three entity counts |

### Output Format

| country | total_employees | total_suppliers | total_customers | entity_average |
|---|---:|---:|---:|---:|
| USA | 5 | 4 | 13 | 7.33 |
| Germany | 1 | 3 | 11 | 5.00 |

*Sample values are illustrative. Actual values must be obtained from the Northwind database.*

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
- Aggregation
- Arithmetic
- Expressions
- WHERE
- HAVING
- ORDER
- BY

## Approaches

### ✅ Correct Approach

```sql
with data_set as (
  select e.country,
  'employees' as Entity
  from employees e
  Union all
  select c.country,
  'customers' as Entity
  from customers c
  UNION all
  select s.country,
  'suppliers' as Entity
  from suppliers s
),
total_count_as_per_entity as(
  select d.country,
  sum(case when d.entity='employees' then 1 else 0 end) as total_employee,
  sum(case when d.entity='customers' then 1 else 0 end) as total_customers,
  sum(case when d.entity='suppliers' then 1 else 0 end) as total_suppliers
  from data_set d
  group by d.country
  ),
  average_entity as (
    select t.country,
  (t.total_employee+t.total_customers+t.total_suppliers)/3.0 as entity_average
    from total_count_as_per_entity t
  )
  select t.country,t.total_employee,t.total_customers,t.total_suppliers ,a.entity_average
  from total_count_as_per_entity t inner join 
  average_entity a on t.country=a.country
  where t.total_customers>a.entity_average;
```

## Common Mistakes

- Calculating the average from individual rows instead of country-level counts.
- Using the overall average across all countries instead of the three entity counts for the same country.
- Comparing customers against only employees and suppliers.
- Forgetting that the average is calculated separately for each country.
- Filtering before the entity counts have been calculated.
- Using `UNION` instead of `UNION ALL`.

## Difficulty

**Expert**

## Interview Follow-up Questions

**1. Why must the entity counts be calculated before calculating the entity average?**

[Answer will be added after solving.]

**2. How is this different from calculating the average customer count across countries?**

[Answer will be added after solving.]

**3. Could this be solved without a second CTE?**

[Answer will be added after solving.]

**4. Why is `UNION ALL` important when calculating entity counts?**

[Answer will be added after solving.]

**5. What would happen if one of the entity types did not exist in a country?**

[Answer will be added after solving.]

---


## Learning Outcomes

- Perform multi-level aggregation.
- Calculate derived metrics from grouped results.
- Combine multiple entity sources using `UNION ALL`.
- Compare one aggregated metric against a derived metric.
- Build complex country-level analytical queries.
- 📄 SQL File: [`Q97_Countries_With_More_Customers_Than_Their_Entity_Average.sql`](./Q97_Countries_With_More_Customers_Than_Their_Entity_Average.sql)

## Related Questions

- Q95
