/*
Question:
Return every employee and the total revenue they generated, including employees
with no orders and orders with no assigned employee.

Business Requirement:
Generate a report showing all employees and the total revenue generated from the
orders they handled. The report must include employees who handled orders,
employees who never handled an order, and orders that are not assigned to any
employee, so management gets a complete, unbiased picture of revenue attribution.

Approach:
1. FULL OUTER JOIN employees to orders on employee_id, so unmatched employees
   and unassigned orders are both preserved.
2. FULL OUTER JOIN the result to order_details on order_id, keeping the same
   join type so no row from step 1 can be silently dropped.
3. Group by employee identity and aggregate revenue with SUM(unit_price * quantity
   * (1 - discount)).
4. Cast to ::numeric before ROUND() (PostgreSQL requires numeric type for the
   2-argument ROUND()).
5. Wrap SUM in COALESCE(..., 0) so employees with no orders show 0.00, not NULL.

This is structurally identical to Q48 (same employee/order/order_details revenue
logic), but upgraded from LEFT/RIGHT JOIN to FULL OUTER JOIN throughout, since the
requirement needs unmatched rows preserved on BOTH sides simultaneously.

WRONG APPROACH (as submitted) — CONCAT() masks NULL employee names:

    SELECT
        CONCAT(e.first_name,' ',e.last_name) AS employee_name,
        COALESCE(
            ROUND(
                SUM((od.unit_price * od.quantity * (1 - od.discount))::numeric),
                2
            ),
            0
        ) AS total_revenue
    FROM employees e
    FULL OUTER JOIN orders o
        ON e.employee_id = o.employee_id
    FULL OUTER JOIN order_details od
        ON od.order_id = o.order_id
    GROUP BY
        e.first_name,
        e.last_name,
        e.employee_id;

    -- Why this fails the stated requirement:
    -- CONCAT() in PostgreSQL treats NULL arguments as empty strings rather than
    -- propagating NULL. For the unassigned-order row, e.first_name and
    -- e.last_name are both NULL (no employee matched), so
    -- CONCAT(NULL, ' ', NULL) evaluates to ' ' (a single space) — not NULL.
    -- The expected output explicitly requires NULL in that row. The query runs
    -- without error and the revenue math is correct, but the employee_name
    -- column does not match the required output for the unassigned-order case.

CORRECT APPROACH — use the || operator, which propagates NULL:
*/

SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(
        ROUND(
            SUM((od.unit_price * od.quantity * (1 - od.discount))::numeric),
            2
        ),
        0
    ) AS total_revenue
FROM employees e
FULL OUTER JOIN orders o
    ON e.employee_id = o.employee_id
FULL OUTER JOIN order_details od
    ON od.order_id = o.order_id
GROUP BY
    e.first_name,
    e.last_name,
    e.employee_id;

/*
Note — CONCAT vs || NULL behaviour:
CONCAT('a', NULL, 'b')  -> 'ab'   (NULL treated as empty string)
'a' || NULL || 'b'      -> NULL   (NULL propagates through the whole expression)
Use || whenever a NULL component should make the entire result NULL (e.g. to
correctly represent "no employee" rather than a blank/space placeholder).

Note — join chain integrity:
Both joins above must remain FULL OUTER JOIN. Downgrading the second join
(orders -> order_details) to INNER or LEFT JOIN would silently drop any
employee/order row that has no matching order_details row, even though the
first FULL OUTER JOIN preserved it.

Note — ::numeric cast:
ROUND(value, 2) requires `value` to be of type numeric in PostgreSQL. The raw
arithmetic (unit_price * quantity * (1 - discount)) may resolve to double
precision, so the explicit ::numeric cast avoids a "function round(double
precision, integer) does not exist" error.

Expected Output:
| employee_name    | total_revenue |
|-------------------|---------------|
| Nancy Davolio     | 125420.35     |
| Andrew Fuller     | 98452.70      |
| Steven Buchanan   | 0.00          |
| NULL              | 520.00        |

Concepts Used:
- FULL OUTER JOIN (chained)
- COALESCE for zero-default aggregation
- CONCAT vs || NULL-propagation behaviour
- ::numeric cast before ROUND()
- GROUP BY with FULL OUTER JOIN

Complexity:
Medium
*/
