# Q58. Customer Revenue Comparison (Advanced)

**Category:** FULL OUTER JOIN / CTE / Tie-Safe Top-N
**Difficulty:** Hard

---

## Problem Statement
The finance team wants a reconciliation report showing all customers and their revenue, followed by an analysis of which customer(s) generated the single highest amount of revenue. The report must first reconcile all three data scenarios — customers who generated revenue, customers with no orders, and orders that exist without a valid customer — before identifying the top performer(s).

## Objective
Return the customer's contact name and their total revenue, restricted to whichever customer(s) generated the single highest revenue amount. If multiple customers are tied for the highest revenue, all tied customers must appear — not just one.

## Tables Used
- `customers`
- `orders`
- `order_details`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name | Customer's contact name (NULL if the order has no valid matching customer) |
| total_revenue | Sum of `unit_price * quantity * (1 - discount)` for that customer, rounded to 2 decimals |

**Sample output:**

| contact_name | total_revenue |
|----------------|---------------|
| Ernst Handel | 128945.75 |
| NULL | 500.00 |

*(Illustrative only — actual rows returned depend on which contact_name(s) hold the true maximum total_revenue in the dataset; if two real customers tie for first place, both appear, and a single winner produces a single row)*

## Concepts Used
- FULL OUTER JOIN (chained, for reconciliation)
- CTE (Common Table Expression)
- COALESCE for zero-revenue defaulting
- ::numeric cast before ROUND()
- Tie-safe maximum comparison (subquery `>=`, not `LIMIT 1`)
- GROUP BY with FULL OUTER JOIN

## Why This Approach

**Why the reconciliation step must still use FULL OUTER JOIN, even though only the top row(s) are ultimately returned**
The base `rev` CTE must contain the *complete* picture — every customer, matched or not, and every order, attributed or not — because the maximum calculated in the final `WHERE` clause is only trustworthy if it's computed over the full, unbiased dataset. If the reconciliation step used an INNER JOIN or a one-sided JOIN, the max could be silently computed over a smaller, biased subset, and a legitimate top-revenue customer could be excluded before the comparison even happens. This is structurally the same reconciliation pattern as **Q57**, chaining `customers → orders → order_details` with FULL OUTER JOIN at every step so no side of any join loses rows.

**Why a CTE, rather than a subquery inline in the FROM clause**
The revenue-per-customer calculation is needed twice: once as the row set being filtered, and once again (aggregated further, via `MAX`) as the comparison threshold. A CTE (`rev`) computes this expensive aggregation exactly once and names it, making the final query readable as "select from the revenue report where revenue is at least the maximum revenue in that same report" — expressing the tie-safe top-N pattern in plain SQL rather than duplicating the join logic twice.

**Why `WHERE total_revenue >= (SELECT MAX(total_revenue) FROM rev)`, not `ORDER BY total_revenue DESC LIMIT 1`**
`LIMIT 1` returns exactly one row, arbitrarily, whenever there is a tie for first place — which row comes back depends on physical row order, not business logic, and is not guaranteed to be stable across query re-runs. Comparing every row against the true maximum with `>=` is tie-safe: every customer whose revenue equals the maximum is returned, whether that's one customer or five. This is the same anti-pattern documented in prior "top N" questions — `LIMIT 1` silently drops legitimate ties.

**Why COALESCE is required in the `rev` CTE**
`SUM()` returns `NULL` for any customer group with zero matching order/order_details rows (a customer with no orders). Without `COALESCE(..., 0)`, that customer's `total_revenue` would be `NULL`, and `NULL` values are automatically excluded from any comparison, including `MAX()` and `>=`. Leaving revenue as `NULL` wouldn't just look wrong cosmetically — it would make the tie-safe comparison logic in the final query silently incorrect, since `NULL >= anything` is never true.

**Why `::numeric` before `ROUND()`**
As with every revenue query in this series, PostgreSQL's `ROUND(value, precision)` requires `value` to be of type `numeric`. The raw multiplication of `unit_price`, `quantity`, and `(1 - discount)` can resolve to `double precision`, so the cast is required to avoid a function-not-found error.

**Why GROUP BY includes `customer_id`, not just `contact_name`**
`contact_name` alone is not guaranteed unique across the `customers` table — two different customers could coincidentally share a contact name. Grouping by `customer_id` (a true primary key) alongside `contact_name` guarantees each group represents exactly one real customer, while still allowing `contact_name` to be selected in the output.

## Common Mistakes
- Using `ORDER BY total_revenue DESC LIMIT 1` instead of the `>= MAX(...)` subquery pattern — arbitrarily drops tied customers, returning only one when several deserve to appear.
- Computing the `MAX()` from a join that isn't FULL OUTER JOIN throughout — biases the maximum calculation by silently excluding unmatched customers or orphaned orders before the comparison is even made.
- Forgetting `COALESCE` in the `rev` CTE — leaves `NULL` revenue for customers with no orders, which then fails silently against every `>=` comparison in the outer query.
- Re-running the full three-table join twice (once for the row set, once for the max) instead of using a CTE — duplicates expensive join logic and risks the two copies drifting out of sync if one is edited later.
- Omitting `::numeric` before `ROUND(..., 2)` — throws a PostgreSQL error.

## Difficulty
**Hard**

## Interview Follow-up Questions

**1. Why is `WHERE total_revenue >= (SELECT MAX(total_revenue) FROM rev)` considered "tie-safe," and what specifically breaks if you use `LIMIT 1` instead?**
The `>=` comparison against a computed maximum returns *every* row whose value equals that maximum, with no assumption about row count — one row if there's a single winner, several if there's a genuine tie. `LIMIT 1` instead returns exactly one row based on whatever order the rows happen to arrive in (which, without an explicit `ORDER BY`, isn't even guaranteed to be the highest value at all, and even with `ORDER BY DESC` and a tie, the choice of *which* tied row comes first is arbitrary and can change between query plans or re-runs). In a finance reconciliation report, silently dropping a legitimate top-revenue customer because of tie-breaking is a correctness bug, not a stylistic choice.

**2. Why must the CTE computing revenue use FULL OUTER JOIN even though the final query might discard most of the rows?**
The final query's correctness depends entirely on the `MAX(total_revenue)` subquery being computed over the complete, unbiased dataset. If the CTE used a join type that dropped unmatched customers or unassigned orders, the computed maximum itself could be wrong — either too low (missing a genuine top performer) or, in edge cases, matching a value that shouldn't have been eligible at all. Reconciliation and comparison are two separate concerns, but the comparison is only as trustworthy as the reconciliation feeding it.

**3. What would happen to this query's correctness if COALESCE were removed from the CTE, and why?**
Every customer with no orders would have `total_revenue = NULL` instead of `0`. In SQL, `NULL` is not comparable using standard operators — `NULL >= 5` evaluates to `UNKNOWN`, not `TRUE` or `FALSE`, so those rows would simply be excluded from the final result no matter what. This wouldn't cause a visible error, which makes it a particularly dangerous silent bug: the report would look correct but be quietly wrong for every customer with zero orders.

**4. Why is a CTE preferred over a plain subquery here, and are there situations where a subquery would be equally valid?**
A CTE is preferred for readability and to avoid recomputing the same three-table FULL OUTER JOIN twice within a single query — the `rev` CTE is referenced both as the row source in the outer `SELECT` and as the row source for the `MAX()` subquery. A plain nested subquery would work identically in terms of correctness (PostgreSQL's planner can often produce the same execution plan either way), but would require writing the entire join logic out twice, increasing the risk of the two copies silently drifting apart if one is edited without the other. CTEs also support recursion and materialization hints in more advanced use cases, which plain subqueries don't offer.

**5. How would you modify this query to return the top 3 revenue-generating customers (with ties handled correctly) instead of just the single highest?**
Replace the `MAX()`-based filter with `DENSE_RANK()` in the CTE: compute `DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank` inside (or on top of) the `rev` CTE, then filter the outer query with `WHERE revenue_rank <= 3`. `DENSE_RANK()` is essential here rather than `RANK()` or `ROW_NUMBER()`: `ROW_NUMBER()` would arbitrarily break ties and could omit a legitimate 3rd-place tie; `RANK()` would leave gaps in the ranking after a tie (e.g., two customers tied at rank 1 pushes the next customer to rank 3, not 2), while `DENSE_RANK()` correctly keeps consecutive integer ranks even through ties, matching business expectations for "top 3, ties included."

## Learning Outcomes
- Master the tie-safe top-N pattern (`WHERE value >= (SELECT MAX(value) ...)`) as the correct alternative to `LIMIT 1` whenever ties are possible and business-meaningful.
- Understand that a reconciliation join (FULL OUTER JOIN) and a comparison filter are separate concerns, but the comparison's correctness depends entirely on the reconciliation being unbiased.
- Reinforce why NULL values silently fail standard comparison operators, and why this makes COALESCE a correctness requirement, not just cosmetic polish.
- Recognize when a CTE is the right tool to avoid duplicating expensive join logic within a single query.
- Preview how `DENSE_RANK()` generalizes the tie-safe top-1 pattern into a tie-safe top-N pattern.

---

📄 **SQL File:** [`Q58_Customer_Revenue_Comparison_Advanced.sql`](./Q58_Customer_Revenue_Comparison_Advanced.sql)
