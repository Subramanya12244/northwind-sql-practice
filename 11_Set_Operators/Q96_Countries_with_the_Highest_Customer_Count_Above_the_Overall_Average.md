# Q96. Countries with the Highest Customer Count Above the Overall Average

**Category:** SELECT
**Difficulty:** Expert

---

## Problem Statement

The business wants to identify the country or countries with the highest number of customers among all countries that have a customer count above the overall average.

First determine the number of customers in each country, calculate the average customer count across all countries, and then identify the country or countries that have the highest customer count while also being above the overall average.

## Objective

Return the country or countries that satisfy both conditions:

1. Their customer count is greater than the average customer count across all countries.
2. Their customer count is the maximum customer count among the qualifying countries.

The query must handle ties correctly. If multiple countries have the same highest qualifying customer count, return all of them.

---

## Tables Used

- `customers`

## Expected Output

| Column Name | Description |
|---|---|
| `country` | Country with the highest qualifying customer count |
| `total_customers` | Number of customers in the country |
| `average_customers` | Average customer count across all countries |

### Output Format

| country | total_customers | average_customers |
|---|---:|---:|
| USA | 13 | 5.67 |

*Sample values are illustrative. Actual values must be obtained from the Northwind database.*

---

## Concepts Used

- CTE
- COUNT
- AVG
- MAX
- Subquery
- CROSS
- JOIN
- Aggregate
- of
- an
- Aggregate
- Multiple
- aggregation
- levels
- filtering
- WHERE
- HAVING

## Approaches

### ✅ Correct Approach

```sql
with total_count as (
  SELECT c.country,
  sum(case when c.country is not null then 1 else 0 end) as total_cust
  from customers c
  group by c.country
),
avg_count as (
  select avg(total_cust) as avg_count
  from total_count
) ,
max_count as (
  select max(total_cust) as max_count
  from total_count
)
select t.country,
t.total_cust,
a.avg_count,
m.max_count
from total_count t CROSS JOIN
avg_count a CROSS JOIN 
max_count m
where t.total_cust>a.avg_count
and t.total_cust=m.max_count;
```

## Common Mistakes

- Using `LIMIT 1` and accidentally excluding tied countries.
- Finding the maximum customer count before applying the above-average condition.
- Comparing individual customer rows instead of country-level customer counts.
- Calculating the average from individual customer rows rather than country-level counts.
- Grouping at the wrong aggregation level.
- Filtering the maximum before identifying countries above the average.
- Forgetting to return the average customer count.

## Difficulty

**Expert**

## Interview Follow-up Questions

**1. Why is `LIMIT 1` not tie-safe for this problem?**

[Answer will be added after solving.]

**2. At what stage should the average customer count be calculated?**

[Answer will be added after solving.]

**3. Why must the maximum be calculated after filtering countries above the average?**

[Answer will be added after solving.]

**4. How could a window function simplify this problem?**

[Answer will be added after solving.]

**5. What is the difference between finding the maximum customer count across all countries and finding the maximum customer count among countries above average?**

[Answer will be added after solving.]

---


## Learning Outcomes

- Solve multi-stage aggregation problems.
- Work with aggregate results from previous aggregation levels.
- Apply multiple filtering conditions in the correct order.
- Handle ties correctly.
- Understand why naive `LIMIT 1` solutions can be incorrect.
- Build robust analytical SQL queries using CTEs and subqueries.
- 📄 SQL File: [`Q96_Countries_With_Highest_Customer_Count_Above_Average.sql`](./Q96_Countries_With_Highest_Customer_Count_Above_Average.sql)

## Related Questions

- Q95
