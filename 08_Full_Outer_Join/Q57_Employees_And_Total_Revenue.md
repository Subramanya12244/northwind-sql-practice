# Q57. Employees and Total Revenue

**Category:** FULL OUTER JOIN
**Difficulty:** Medium

---

## Problem Statement
Generate a report showing all employees and the total revenue generated from the orders they handled. The report must include employees who handled orders, employees who never handled an order, and orders that are not assigned to any employee, so that management gets a complete, unbiased picture of revenue attribution across the sales team.

## Objective
Return the employee name and the total revenue attributed to that employee, including employees with zero revenue and a catch-all row for unassigned orders.

## Tables Used
- `employees`
- `orders`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| employee_name | Full name of the employee (NULL if the order has no assigned employee) |
| total_revenue | Sum of `unit_price * quantity * (1 - discount)` for that employee, rounded to 2 decimals |

**Sample output:**

| employee_name | total_revenue |
|----------------|---------------|
| Nancy Davolio | 125420.35 |
| Andrew Fuller | 98452.70 |
| Steven Buchanan | 0.00 |
| NULL | 520.00 |

*(Steven Buchanan represents an employee who never handled an order; the final NULL row represents orders present in the data with no employee assigned)*

## Concepts Used
- FULL OUTER JOIN (chained across two joins)
- COALESCE for zero-revenue defaulting
- CONCAT vs `||` NULL-propagation behaviour
- ::numeric cast before ROUND()
- GROUP BY with FULL OUTER JOIN

## Why This Approach

**Why FULL OUTER JOIN, twice, in a chain**
The requirement explicitly asks for three categories of rows: matched employee-order pairs, employees with no orders, and orders with no employee. A single join type cannot produce all three:
- `employees LEFT JOIN orders` would preserve unmatched employees but silently drop orders with a NULL `employee_id`.
- `employees RIGHT JOIN orders` would preserve unassigned orders but drop employees who never sold anything.

Only `FULL OUTER JOIN` preserves both sides simultaneously. This is chained a second time into `order_details` for the same reason — an order could theoretically fail to match order line items, and we don't want the outer-join guarantee broken partway through the chain. This mirrors **Q48**, which used the same LEFT/RIGHT JOIN logic pattern; Q57 simply upgrades every join in the chain to FULL OUTER JOIN to guarantee zero row loss on *either* side, at *any* stage of the pipeline.

**Why every join in the chain must stay FULL OUTER JOIN**
If the second join (`orders FULL OUTER JOIN order_details`) were downgraded to an INNER JOIN, any employee whose order had no matching `order_details` rows (or any order that failed to join) would be silently dropped from the result — even though the first FULL OUTER JOIN preserved it. The outer-join guarantee only holds if it is maintained at *every* stage of a chained join. This is the same principle documented for chained LEFT/RIGHT JOINs.

**Why COALESCE is required here**
`SUM()` returns `NULL`, not `0`, for a group with no matching rows (e.g. Steven Buchanan, who has no orders to sum). Without `COALESCE(..., 0)`, the report would show `NULL` instead of `0.00` for employees with no sales, which is misleading in a revenue report. This is different from `COUNT()`, which naturally returns `0` for empty groups and would not need COALESCE.

**Why `::numeric` before `ROUND()`**
PostgreSQL's `ROUND()` function requires a `numeric` type when a precision argument (`2`) is supplied — it does not accept `double precision`. Since `unit_price`, `quantity`, and `discount` arithmetic can produce a `double precision` result, the expression must be cast to `::numeric` before rounding, or PostgreSQL raises a function-does-not-exist error.

**Why `order_details.unit_price`, not `products.unit_price`**
`products.unit_price` reflects the *current* catalog price, which may have changed since the sale occurred. `order_details.unit_price` is the *historical, point-of-sale* price, which is what actually generated the revenue. Using the catalog price would silently corrupt every historical revenue calculation.

**CONCAT vs `||` — a real quirk in this query**
The submitted query uses `CONCAT(e.first_name, ' ', e.last_name)`. In PostgreSQL, `CONCAT()` treats `NULL` arguments as empty strings rather than propagating `NULL`. This means for the unassigned-order row — where `e.first_name` and `e.last_name` are both `NULL` because no employee matched — `CONCAT()` returns a single space `' '`, **not** `NULL`. The expected output in this problem specifically calls for `NULL` in that row. This is a genuine mismatch between the submitted query and the stated requirement, documented below under Common Mistakes and corrected using the `||` operator instead, since `||` propagates `NULL` when any operand is `NULL`.

## Common Mistakes
- Using `CONCAT()` when a `NULL` employee name is the desired output — `CONCAT()` silently converts `NULL` names into an empty string (visually a stray space), not an actual `NULL` value. Use `e.first_name || ' ' || e.last_name` instead if a true `NULL` is required.
- Forgetting `COALESCE` on `SUM()` — produces `NULL` instead of `0.00` for employees with no orders, which reads as "unknown" rather than "zero," a meaningful distinction in a revenue report.
- Downgrading the second join in the chain to `INNER JOIN` or `LEFT JOIN` — breaks the outer-join guarantee established by the first join and silently drops rows.
- Omitting `::numeric` before `ROUND(..., 2)` — throws a PostgreSQL error since `ROUND` with a precision argument requires the `numeric` type.
- Using `products.unit_price` instead of `order_details.unit_price` — produces revenue figures based on current prices rather than the price at time of sale.

## Difficulty
**Medium**

## Interview Follow-up Questions

**1. Why does a FULL OUTER JOIN chain require every join in the chain to remain a FULL OUTER JOIN, not just the first one?**
A join chain is evaluated step by step, and each step's join type determines what rows survive into the next step. If the first FULL OUTER JOIN preserves an unmatched employee (with NULL order columns), but the second join in the chain is an INNER JOIN, that row will be dropped the moment the engine tries to match `order.order_id` against `order_details.order_id` — because there's no order, there's nothing to inner-join against, so the row disappears. The outer-join guarantee is only as strong as its weakest link in the chain.

**2. Why does CONCAT() behave differently from the `||` operator with NULL values, and when does this matter?**
`CONCAT()` is a PostgreSQL function that explicitly treats NULL arguments as empty strings, so `CONCAT(NULL, ' ', NULL)` returns `' '` — a string, not NULL. The `||` operator follows standard SQL NULL-propagation rules: if any operand is NULL, the entire expression evaluates to NULL. This matters whenever you need to distinguish "genuinely no employee" (NULL) from "employee whose name happens to be blank" — reporting logic, filtering with `WHERE employee_name IS NULL`, and export/ETL pipelines all behave differently depending on which one you use.

**3. Why is COALESCE necessary for SUM/AVG/MIN/MAX but not for COUNT?**
`SUM`, `AVG`, `MIN`, and `MAX` are only computed over rows that exist in a group; if a group has zero matching rows (e.g., an employee with no orders), there is nothing to aggregate, and the SQL standard defines the result as NULL — "no value," not "zero value." `COUNT(*)` or `COUNT(column)`, by contrast, counts rows, and counting zero rows naturally and correctly returns `0`. This is a fundamental distinction in how empty-group aggregation is defined in SQL, and it's why revenue reports almost always need COALESCE while headcount/order-count reports usually don't.

**4. What's the difference between COUNT(*) and COUNT(column) in this kind of query, and why does it matter here?**
`COUNT(*)` counts every row in the group regardless of NULLs, while `COUNT(column)` counts only rows where that specific column is non-NULL. In a FULL OUTER JOIN chain like this one, a row for an employee with no orders will have NULL values in every `orders` and `order_details` column. `COUNT(*)` on such a row would incorrectly report `1` (counting the phantom placeholder row), while `COUNT(od.order_id)` would correctly report `0`, since there is no real order_details row. This query avoids the issue entirely by using SUM (which naturally ignores NULLs), but the distinction becomes critical the moment a COUNT is added to a report like this.

**5. How would you rewrite this query if you only wanted employees who generated zero revenue, excluding the unassigned-order row entirely?**
Wrap the existing query as a CTE or subquery and filter in the outer query with `WHERE employee_name IS NOT NULL AND total_revenue = 0`. Filtering in the `WHERE` clause of the original query directly would not work, because `total_revenue` is a computed aggregate alias not yet available at the `WHERE` stage (predates GROUP BY); it would need to go in a `HAVING` clause instead, e.g., `HAVING COALESCE(SUM(...), 0) = 0`, combined with excluding the NULL-name row via an added condition on `e.employee_id IS NOT NULL`.

## Learning Outcomes
- Understand that FULL OUTER JOIN guarantees must be preserved consistently across every step of a multi-table join chain, not just the first join.
- Recognize the practical difference between `CONCAT()` and `||` when NULL-safety of the output actually matters to downstream consumers.
- Reinforce when COALESCE is required (SUM/AVG/MIN/MAX) versus redundant (COUNT).
- Apply the `::numeric` cast rule for ROUND() consistently across revenue-calculation queries.
- Build the habit of validating that submitted SQL actually satisfies the *stated* expected output — not just that it runs without error.

---

📄 **SQL File:** [`Q57_Employees_And_Total_Revenue.sql`](./Q57_Employees_And_Total_Revenue.sql)
