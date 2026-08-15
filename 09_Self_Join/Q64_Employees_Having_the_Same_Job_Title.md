# Q64. Employees Having the Same Job Title

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve pairs of employees having the same job title.

## Objective

Return every unique pair of employees who share the same `title` value, along with that shared title. Exclude self-pairs and duplicate pairs.

## Tables Used

- `employees (aliased twice: e1, e2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name1 | Full name of the first employee in the pair |
| employee_name2 | Full name of the second employee in the pair |
| title | The shared job title |

**Sample output:**

| employee_name1 | employee_name2 | title |
|----------------|----------------|-------|
| Nancy Davolio | Janet Leverling | Sales Representative |
| Nancy Davolio | Margaret Peacock | Sales Representative |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why the standard SELF JOIN pair pattern:** `JOIN employees e2 ON e1.employee_id < e2.employee_id AND e1.title = e2.title` accomplishes two things in one condition — `<` eliminates self-pairs and duplicates, and `e1.title = e2.title` restricts the join to only employees sharing the same title.

**Why no third alias is needed:** once you establish `e1.title = e2.title` in the join condition, `e1.title` and `e2.title` are guaranteed to be identical. Either can be used in the SELECT list — `e1.title` is the conventional choice. There is no need to join a third alias just to display a value that's already available from `e1`.

### ❌ Attempt 1 — Unnecessary third join on employees:

```sql
select concat(e1.first_name,' ',e1.last_name) as employee_name1,
concat(e2.first_name,' ',e2.last_name) as employee_name2,
j.title
from
employees e1
join employees e2
on e1.employee_id < e2.employee_id
and e1.title = e2.title
join employees j
on e1.employee_id = j.employee_id
```

**Why it fails:** The third join fetches `j.title`, but `e1.title` is already identical to `e2.title` via the join condition. Completely redundant.


## Common Mistakes

- **Attempt 1 — Unnecessary third join:** `join employees j on e1.employee_id = j.employee_id` — Since `e1.title = e2.title` is already in the join condition, `e1.title` is directly accessible. A third alias just to display `title` is completely redundant — it adds a join with zero benefit.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Why is a third join on `employees` unnecessary here, when Q63 required one?**

In Q63, the manager's name came from a different row than either employee — it required fetching a third record from the same table via a third alias. Here, `title` is a column already present on both `e1` and `e2`, and since the join condition guarantees `e1.title = e2.title`, either alias gives you the same value directly. The rule is: only add another join (or alias) if the data you need isn't already reachable from the tables already in the query.

**2. What is the reusable SELF JOIN pair pattern established by this point in the module?**

The standard pattern is: `FROM table t1 JOIN table t2 ON t1.id < t2.id AND t1.common_column = t2.common_column`. The `<` on the primary key eliminates self-pairs and duplicate pairs; the second condition defines what 'same' means for the specific question. This pattern recurs in Q63–Q70 with only the table, key column, and matching column changing.

**3. How would you extend this to count how many pairs share each job title?**

`SELECT e1.title, COUNT(*) AS pair_count FROM employees e1 JOIN employees e2 ON e1.employee_id < e2.employee_id AND e1.title = e2.title GROUP BY e1.title ORDER BY pair_count DESC`.

**4. Could you solve this with `GROUP BY title HAVING COUNT(*) > 1` without a SELF JOIN?**

That approach finds titles with more than one employee, but it doesn't return the actual pairs — just the titles and their employee counts. To return the individual pairs (employee 1, employee 2, title), the SELF JOIN is required. The GROUP BY approach answers 'which titles have multiple holders'; the SELF JOIN answers 'who are those holders, paired up'.

## Learning Outcomes

- Internalise the rule: only join another alias/table if the data needed isn't already reachable from existing aliases.
- Reinforce the standard SELF JOIN pair pattern: `t1.id < t2.id AND t1.column = t2.column`.

---

**Score from review session: 9.5/10**

**Interview Takeaway:** Only join another table if you actually need data that isn't already available from existing aliases.

📄 **SQL File:** [`Q64_Employees_Having_the_Same_Job_Title.sql`](./Q64_Employees_Having_the_Same_Job_Title.sql)
