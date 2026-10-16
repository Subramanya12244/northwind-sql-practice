# Q64 · Employees Having the Same Job Title

> **Revision Card**
> **Category:** Self Join | **Difficulty:** Easy
> **Concepts:** SELF JOIN · INNER JOIN · duplicate-pair elimination (`id < id`)
> **Outcome:** ⚠️ had mistakes (see §4)
> **Watch out for:** don't add a join for data you already have — once `e1.title = e2.title` is in the ON clause, `e1.title` is directly selectable.

## 1. Problem

Retrieve pairs of employees having the same job title.

**Objective:** Return every unique pair of employees who share the same `title` value, along with that shared title. Exclude self-pairs and duplicate pairs.

**Tables:** `employees` (aliased twice: `e1`, `e2`)

**Expected output:**

| Column | Description |
|---|---|
| employee_name1 | Full name of the first employee in the pair |
| employee_name2 | Full name of the second employee in the pair |
| title | The shared job title |

| employee_name1 | employee_name2 | title |
|----------------|----------------|-------|
| Nancy Davolio | Janet Leverling | Sales Representative |
| Nancy Davolio | Margaret Peacock | Sales Representative |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## 2. My Approach

1. Self-join `employees e1` to `employees e2`.
2. In the ON clause, use `e1.employee_id < e2.employee_id` to drop self/duplicate pairs and `e1.title = e2.title` to restrict to shared titles.
3. Select both names plus the shared title (available directly from `e1`).

## 3. My Solution (as submitted)

```sql
-- First attempt: added an unnecessary third join just to read the title
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       j.title
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND e1.title = e2.title
JOIN employees j
    ON e1.employee_id = j.employee_id;
```

## 4. Mistakes I Made

- ⚠️ **Unnecessary third join:** added `JOIN employees j ON e1.employee_id = j.employee_id` just to read `j.title` → since `e1.title = e2.title` is already in the join condition, `e1.title` is directly accessible; the third alias is completely redundant and adds a join with zero benefit. → Fix: drop the third join and select `e1.title`.

## 5. Correct / Optimal Solution

```sql
SELECT CONCAT(e1.first_name,' ',e1.last_name) AS employee_name1,
       CONCAT(e2.first_name,' ',e2.last_name) AS employee_name2,
       e1.title
FROM employees e1
JOIN employees e2
    ON e1.employee_id < e2.employee_id
    AND e1.title = e2.title;
```

## 6. Why This Works

**Why the standard SELF JOIN pair pattern:** `JOIN employees e2 ON e1.employee_id < e2.employee_id AND e1.title = e2.title` accomplishes two things in one condition — `<` eliminates self-pairs and duplicates, and `e1.title = e2.title` restricts the join to only employees sharing the same title.

**Why no third alias is needed:** once you establish `e1.title = e2.title` in the join condition, `e1.title` and `e2.title` are guaranteed to be identical. Either can be used in the SELECT list — `e1.title` is the conventional choice. There is no need to join a third alias just to display a value that's already available from `e1`.

## 7. Common Pitfalls (generic)

- Adding an extra join/alias to fetch a value that is already reachable from an existing alias — pure overhead.
- Using `<>` instead of `<` in the deduplication condition — removes self-pairs but keeps both (A,B) and (B,A).
- Forgetting the `e1.title = e2.title` condition — produces a Cartesian product of all employee pairs.

## 8. Interview Follow-ups

**1. Why is a third join on `employees` unnecessary here, when Q63 required one?**

In Q63, the manager's name came from a different row than either employee — it required fetching a third record from the same table via a third alias. Here, `title` is a column already present on both `e1` and `e2`, and since the join condition guarantees `e1.title = e2.title`, either alias gives you the same value directly. The rule is: only add another join (or alias) if the data you need isn't already reachable from the tables already in the query.

**2. What is the reusable SELF JOIN pair pattern established by this point in the module?**

The standard pattern is: `FROM table t1 JOIN table t2 ON t1.id < t2.id AND t1.common_column = t2.common_column`. The `<` on the primary key eliminates self-pairs and duplicate pairs; the second condition defines what 'same' means for the specific question. This pattern recurs in Q63–Q70 with only the table, key column, and matching column changing.

**3. How would you extend this to count how many pairs share each job title?**

`SELECT e1.title, COUNT(*) AS pair_count FROM employees e1 JOIN employees e2 ON e1.employee_id < e2.employee_id AND e1.title = e2.title GROUP BY e1.title ORDER BY pair_count DESC`.

**4. Could you solve this with `GROUP BY title HAVING COUNT(*) > 1` without a SELF JOIN?**

That approach finds titles with more than one employee, but it doesn't return the actual pairs — just the titles and their employee counts. To return the individual pairs (employee 1, employee 2, title), the SELF JOIN is required. The GROUP BY approach answers 'which titles have multiple holders'; the SELF JOIN answers 'who are those holders, paired up'.

## 9. Key Takeaway

Only join another alias/table if the data you need isn't already reachable from an existing alias — and reuse the standard pair pattern `t1.id < t2.id AND t1.column = t2.column`.

---
📄 **SQL File:** [`Q64_Employees_Having_the_Same_Job_Title.sql`](./Q64_Employees_Having_the_Same_Job_Title.sql)
