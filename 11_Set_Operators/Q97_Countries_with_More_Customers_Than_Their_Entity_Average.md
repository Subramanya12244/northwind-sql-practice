# Q97 · Countries with More Customers Than Their Entity Average

> **Revision Card**
> **Category:** Set Operators (UNION ALL) + Multi-level Aggregation | **Difficulty:** Expert
> **Concepts:** UNION ALL · CTE · Conditional Aggregation (SUM + CASE) · GROUP BY · Derived metric · WHERE
> **Outcome:** ✅ correct first attempt
> **Watch out for:** the average is **per-country** across its own three entity counts — not the overall average across all countries.

## 1. Problem

The company wants to identify countries where the number of customers is greater than the average number of entities represented in that country.

For each country, calculate the number of employees, suppliers, and customers. Then calculate the average number of entities for that country and identify countries where the customer count is greater than this entity average.

**Objective:** Return countries where `total_customers > average(total_employees, total_suppliers, total_customers)`. Display the individual entity counts and the calculated entity average.

**Tables:** `employees`, `suppliers`, `customers`

**Expected output:**

| Column Name | Description |
|---|---|
| `country` | Country being evaluated |
| `total_employees` | Number of employees in the country |
| `total_suppliers` | Number of suppliers in the country |
| `total_customers` | Number of customers in the country |
| `entity_average` | Average of the three entity counts |

**Output format:**

| country | total_employees | total_suppliers | total_customers | entity_average |
|---|---:|---:|---:|---:|
| USA | 5 | 4 | 13 | 7.33 |
| Germany | 1 | 3 | 11 | 5.00 |

*Sample values are illustrative. Actual values must be obtained from the Northwind database.*

## 2. My Approach

1. CTE `data_set` — `UNION ALL` of `(country, entity)` from employees, customers, suppliers.
2. CTE `total_count_as_per_entity` — conditional aggregation: count each entity type per country (`SUM(CASE ...)`), grouped by country.
3. CTE `average_entity` — per country, compute `(employees + customers + suppliers) / 3.0` as `entity_average`.
4. Join the per-country counts to the per-country average and keep rows where `total_customers > entity_average`.

## 3. My Solution (as submitted)

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

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Standardise then aggregate:** `data_set` uses `UNION ALL` to stack one labelled row per source record. `UNION ALL` (not `UNION`) is essential — deduplicating would collapse identical `(country, entity)` rows and destroy the counts.

**Per-country conditional aggregation:** `total_count_as_per_entity` turns the flat labelled rows into three counts per country in a single grouped pass.

**The per-country derived metric:** `average_entity` computes `(employees + customers + suppliers) / 3.0` *for each country separately*. Dividing by `3.0` (not `3`) forces floating-point division so the average isn't truncated. This is the crux of the question: the benchmark is a country's own entity mix, not a global average across all countries.

**Final comparison:** joining the counts to the per-country average on `country` and filtering `total_customers > entity_average` yields exactly the countries where customers dominate that country's own entity balance.

## 7. Common Pitfalls (generic)

- Calculating the average from individual rows instead of country-level counts.
- Using the overall average across all countries instead of the three entity counts for the same country.
- Comparing customers against only employees and suppliers.
- Forgetting that the average is calculated separately for each country.
- Filtering before the entity counts have been calculated.
- Using `UNION` instead of `UNION ALL`.

## 8. Interview Follow-ups

**1. Why must the entity counts be calculated before calculating the entity average?**

The entity average is defined as `(total_employees + total_suppliers + total_customers) / 3`, so those three counts must exist first. The `total_count_as_per_entity` CTE produces the per-country counts, and only then can `average_entity` combine them into the per-country average. Without the counts, there is nothing to average — the average is a derived metric built on top of the aggregation stage.

**2. How is this different from calculating the average customer count across countries?**

Here the average is computed *within each country*, across that country's three entity types (employees, suppliers, customers), giving a per-country benchmark. The "average customer count across countries" (as in Q96) is computed *across countries*, averaging each country's customer count into one global scalar. This question compares a country's customers to its own entity mix; Q96 compares each country's customers to the overall average across all countries.

**3. Could this be solved without a second CTE?**

Yes — the per-country average is just an arithmetic expression on the three counts, so it can be computed inline rather than in a separate `average_entity` CTE. You can filter directly in the outer query, e.g. `WHERE total_customers > (total_employee + total_customers + total_suppliers) / 3.0`, or repeat that expression in the `SELECT` to display it. The second CTE mainly improves readability and avoids writing the formula twice.

**4. Why is `UNION ALL` important when calculating entity counts?**

`UNION ALL` preserves every source row, which is what the counts depend on. The branches emit only `(country, entity)` pairs, so many rows are identical — every German customer produces the same `('Germany', 'customers')` row. `UNION` would deduplicate these, collapsing all German customers into one row and making the conditional `SUM(CASE ...)` under-count. `UNION ALL` keeps one row per record so each count reflects the true number of entities.

**5. What would happen if one of the entity types did not exist in a country?**

Because the counts come from `SUM(CASE WHEN entity = ... THEN 1 ELSE 0 END)`, a missing entity type simply yields 0 for that column — not NULL and not a missing row — as long as the country appears in at least one branch. The average still divides by 3, so a country with zero employees and zero suppliers but many customers gets a low entity_average, making it very likely to pass `total_customers > entity_average`. A country that appears in no branch at all would not show up in the result.

## 9. Key Takeaway

Build per-country counts with `UNION ALL` + conditional aggregation, derive the per-country average (dividing by `3.0` for real division), then compare each country against its own benchmark — not a global one.

---
📄 **SQL File:** [`Q97_Countries_with_More_Customers_Than_Their_Entity_Average.sql`](./Q97_Countries_with_More_Customers_Than_Their_Entity_Average.sql)
