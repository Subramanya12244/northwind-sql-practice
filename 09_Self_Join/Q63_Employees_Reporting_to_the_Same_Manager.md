# Q63. Employees Reporting to the Same Manager

**Category:** SELF JOIN
**Difficulty:** Medium

---

## Problem Statement

Retrieve pairs of employees who report to the same manager.

## Objective

Return every unique, non-duplicate pair of employees who share the same `reports_to` value, along with their manager's name. Do not return an employee paired with themselves, and do not return duplicate pairs (A,B and B,A).

## Tables Used

- `employees (aliased three times: e1 = employee 1, e2 = employee 2, m = manager)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name1 | Full name of the first employee in the pair |
| employee_name2 | Full name of the second employee in the pair |
| manager_name | Full name of the shared manager |

**Sample output:**

| employee_name1 | employee_name2 | manager_name |
|----------------|----------------|--------------|
| Nancy Davolio | Janet Leverling | Andrew Fuller |
| Nancy Davolio | Margaret Peacock | Andrew Fuller |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN (triple alias)
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why three aliases on `employees`:** this query needs three logical roles from the same table — employee 1 (`e1`), employee 2 (`e2`), and their shared manager (`m`). Each alias is a separate reference to the same physical table. `e1` and `e2` are joined on sharing the same `reports_to` value. `m` is then joined to retrieve the manager's name via `m.employee_id = e1.reports_to`.

**Why `e1.employee_id < e2.employee_id`:** without this condition, every pair appears twice — once as (A, B) and once as (B, A) — and every employee is paired with themselves (A, A). The `<` condition enforces a strict ordering that guarantees each pair appears exactly once and self-pairs are excluded.

**Why `m.employee_id = e1.reports_to` (not `e1.employee_id`):** the manager is identified by the `reports_to` value — the person both employees report to. Joining on `m.employee_id = e1.employee_id` would make the manager the same as employee 1, which is wrong. The join condition must link to the value being shared, not to the employee themselves.

**Why `e1.employee_id < e2.employee_id` in the `WHERE` clause rather than `ON`:** both placements produce identical results for `INNER JOIN`. Moving it to `WHERE` separates the "join logic" from the "deduplication logic," making the query easier to read and reason about.

### ❌ Attempt 1 — Manager shown as employee 1 (wrong column in SELECT):

```sql
select concat(e1.first_name,' ',e1.last_name) as employee_name1,
concat(e2.first_name,' ',e2.last_name) as employee_name2,
concat(e1.first_name,' ',e1.last_name) as manager_name
from employees e1
join employees e2
on e1.reports_to = e2.reports_to
and e1.employee_id < e2.employee_id
```

**Why it fails:** e1 is an employee, not the manager. A third alias `m` is needed joined on `m.employee_id = e1.reports_to`.

### ❌ Attempt 2 — Manager joined on wrong column:

```sql
select concat(e1.first_name,' ',e1.last_name) as employee_name1,
concat(e2.first_name,' ',e2.last_name) as employee_name2,
concat(m.first_name,' ',m.last_name) as manager_name
from employees e1
join employees e2
on e1.reports_to = e2.reports_to
join employees m
on m.employee_id = e1.employee_id
and e1.employee_id < e2.employee_id
```

**Why it fails:** `m.employee_id = e1.employee_id` makes manager = employee 1. Correct: `m.employee_id = e1.reports_to`.


## Common Mistakes

- **Attempt 1 — Manager aliased as employee 1:** `concat(e1.first_name,' ',e1.last_name) as manager_name` — `e1` is an employee, not the manager. The manager is identified by `reports_to`, requiring a third alias `m` joined on `m.employee_id = e1.reports_to`.
- **Attempt 2 — Manager joined on wrong column:** `join employees m on m.employee_id = e1.employee_id` — This sets manager = employee 1, not the actual manager. The correct join is `m.employee_id = e1.reports_to`.

## Difficulty

**Medium**

## Interview Follow-up Questions

**1. Why do you need three aliases on the same `employees` table?**

Because the query needs to represent three distinct logical entities that all come from the same physical table: employee 1 (e1), employee 2 (e2), and their shared manager (m). Each alias creates an independent reference to the table — e1 and e2 are joined on sharing the same reports_to value, and m is joined to fetch the manager's display name. Without three aliases, you'd have no way to distinguish the manager record from the employee records in the SELECT or JOIN conditions.

**2. Why is `e1.employee_id < e2.employee_id` the correct deduplication condition, and what would happen without it?**

Without `<`, every pair (A, B) would appear twice — once as (A, B) and once as (B, A). Additionally, each employee would be paired with themselves (A, A) since they share the same `reports_to` value as themselves. The `<` condition imposes a strict ordering: only the pair where e1's ID is numerically lower than e2's ID is kept. This guarantees each unique pair appears exactly once and self-pairs are excluded. Using `<>` (not equal) would remove self-pairs but still return (A, B) and (B, A) as duplicates.

**3. How would you extend this to also count how many peer pairs each manager has?**

Wrap the query in a CTE or subquery and count pairs per manager: `WITH pairs AS (... the query above ...) SELECT manager_name, COUNT(*) AS peer_pairs FROM pairs GROUP BY manager_name ORDER BY peer_pairs DESC`.

**4. Could you solve this without a third alias for the manager? What would you lose?**

Yes — you could use `e1.reports_to AS manager_id` in the SELECT instead of joining a third alias. You'd get the manager's ID but not their name. To display the name, a third join on `employees m` is necessary. If only the manager ID (not name) is needed, three aliases are redundant.

## Learning Outcomes

- Master the triple-alias SELF JOIN pattern for queries requiring three logical roles from the same table.
- Know why `e1.employee_id < e2.employee_id` eliminates both self-pairs and duplicate pairs in one condition.
- Understand the common mistake of joining the manager alias on the wrong column — `e1.employee_id` (who the employee is) vs `e1.reports_to` (who they report to).

---

**Score from review session: 10/10**

**Interview Takeaway:** When 3 logical roles come from the same table, use 3 aliases. Always join the manager alias on `m.employee_id = e1.reports_to` — not `e1.employee_id`.

📄 **SQL File:** [`Q63_Employees_Reporting_to_the_Same_Manager.sql`](./Q63_Employees_Reporting_to_the_Same_Manager.sql)
