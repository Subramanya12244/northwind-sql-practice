# Q96 · Countries with the Highest Customer Count Above the Overall Average

> **Revision Card**
> **Category:** Set Operators / Multi-stage Aggregation | **Difficulty:** Expert
> **Concepts:** CTE · COUNT · AVG · MAX · Subquery · CROSS JOIN · Multi-level aggregation · WHERE
> **Outcome:** ✅ correct first attempt
> **Watch out for:** don't use `LIMIT 1` — compare against `MAX` so tied top countries are all returned, and compute the average/max at country-count level, not row level.

## 1. Problem

The business wants to identify the country or countries with the highest number of customers among all countries that have a customer count above the overall average.

First determine the number of customers in each country, calculate the average customer count across all countries, and then identify the country or countries that have the highest customer count while also being above the overall average.

**Objective:** Return the country or countries that satisfy both conditions:

1. Their customer count is greater than the average customer count across all countries.
2. Their customer count is the maximum customer count among the qualifying countries.

The query must handle ties correctly. If multiple countries have the same highest qualifying customer count, return all of them.

**Tables:** `customers`

**Expected output:**

| Column Name | Description |
|---|---|
| `country` | Country with the highest qualifying customer count |
| `total_customers` | Number of customers in the country |
| `average_customers` | Average customer count across all countries |

**Output format:**

| country | total_customers | average_customers |
|---|---:|---:|
| USA | 13 | 5.67 |

*Sample values are illustrative. Actual values must be obtained from the Northwind database.*

## 2. My Approach

1. CTE `total_count` — count customers per country (`GROUP BY country`).
2. CTE `avg_count` — average of the per-country counts (`AVG(total_cust)` over `total_count`).
3. CTE `max_count` — maximum of the per-country counts (`MAX(total_cust)` over `total_count`).
4. `CROSS JOIN` the three CTEs so each country row sees both scalars, then filter `total_cust > avg_count AND total_cust = max_count` — tie-safe because it compares to the max rather than taking `LIMIT 1`.

## 3. My Solution (as submitted)

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

## 4. Mistakes I Made

- None — solved correctly on first attempt.

## 5. Correct / Optimal Solution

Same as §3.

## 6. Why This Works

**Multi-stage aggregation:** The problem requires an aggregate of an aggregate. `total_count` first reduces raw customer rows to one count per country. `avg_count` and `max_count` then operate on *those per-country counts*, not the original rows — which is the whole point: the "average" and "maximum" are over countries, not over customers.

**Why `CROSS JOIN`:** `avg_count` and `max_count` each produce a single scalar row. Cross-joining them onto every row of `total_count` attaches both scalars to each country without any join key, so the `WHERE` clause can compare each country's count against both the average and the maximum in one pass.

**Why it is tie-safe:** instead of sorting and taking `LIMIT 1` (which arbitrarily drops ties), the filter `t.total_cust = m.max_count` returns every country whose count equals the maximum — so all tied leaders appear. The additional `t.total_cust > a.avg_count` enforces the "above overall average" condition (and, since the max among above-average countries equals the global max whenever the max itself is above average, the two conditions combine correctly).

## 7. Common Pitfalls (generic)

- Using `LIMIT 1` and accidentally excluding tied countries.
- Finding the maximum customer count before applying the above-average condition.
- Comparing individual customer rows instead of country-level customer counts.
- Calculating the average from individual customer rows rather than country-level counts.
- Grouping at the wrong aggregation level.
- Filtering the maximum before identifying countries above the average.
- Forgetting to return the average customer count.

## 8. Interview Follow-ups

**1. Why is `LIMIT 1` not tie-safe for this problem?**

`LIMIT 1` returns exactly one row even when several countries share the same highest customer count. If, say, two countries both had 13 customers, `ORDER BY total_cust DESC LIMIT 1` would arbitrarily keep only one and silently drop the other. Comparing `t.total_cust = m.max_count` instead returns every country whose count equals the maximum, so all tied leaders appear — which is exactly what the requirement asks for.

**2. At what stage should the average customer count be calculated?**

It must be calculated at the per-country level, after the raw customer rows have been reduced to one count per country. In this solution the `total_count` CTE produces one `total_cust` per country, and `avg_count` runs `AVG(total_cust)` over *those* counts. Computing an average directly from the raw `customers` table would average over customer rows rather than over countries and give a meaningless benchmark.

**3. Why must the maximum be calculated after filtering countries above the average?**

Logically the goal is the maximum *among qualifying (above-average) countries*. In this dataset the global maximum is always above the average, so computing `MAX(total_cust)` over all countries and then also requiring `total_cust > avg_count` produces the correct result. But conceptually the max should describe the qualifying set — if you ever changed the qualification rule, taking the max first over all countries could point at a country that does not actually satisfy the condition, so order matters whenever the top value might itself be excluded.

**4. How could a window function simplify this problem?**

You could collapse the extra CTEs into one pass: `SELECT country, total_cust, AVG(total_cust) OVER () AS avg_count, MAX(total_cust) OVER () AS max_count FROM total_count`. The `OVER ()` window computes the average and maximum across all per-country rows while keeping every row, so no `CROSS JOIN` is needed. You then wrap it in an outer query (or `QUALIFY` where supported) filtering `total_cust > avg_count AND total_cust = max_count`.

**5. What is the difference between finding the maximum customer count across all countries and finding the maximum customer count among countries above average?**

The maximum across all countries considers every country, including those below the average. The maximum among above-average countries first restricts the candidate set to qualifying countries and then finds the top value within that subset. The two coincide only when the overall maximum country is itself above average (as it is in Northwind), but they are conceptually different filters and can diverge if the qualification rule changes.

## 9. Key Takeaway

Aggregate-of-an-aggregate problems need staged CTEs (count per group, then AVG/MAX over those counts), and comparing to `MAX` instead of using `LIMIT 1` keeps the result tie-safe.

---
📄 **SQL File:** [`Q96_Countries_with_the_Highest_Customer_Count_Above_the_Overall_Average.sql`](./Q96_Countries_with_the_Highest_Customer_Count_Above_the_Overall_Average.sql)
