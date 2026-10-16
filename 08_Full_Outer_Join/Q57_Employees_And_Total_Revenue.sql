/* =====================================================================
   Q57 · Employees and Total Revenue
   Category : FULL OUTER JOIN        Difficulty : Medium
   Concepts : FULL OUTER JOIN (chained) · COALESCE · CONCAT vs || NULL
              propagation · ::numeric cast before ROUND() · GROUP BY
   ---------------------------------------------------------------------
   PROBLEM : Return every employee and total revenue generated, including
             employees with no orders (0.00) and a NULL row for orders
             with no assigned employee.
   APPROACH:
     1. FULL OUTER JOIN employees to orders on employee_id.
     2. FULL OUTER JOIN result to order_details on order_id (same join
        type so no row from step 1 is silently dropped).
     3. SUM((unit_price * quantity * (1-discount))::numeric), ROUND 2 dp.
     4. COALESCE(..., 0) so no-order employees show 0.00, not NULL.
     5. GROUP BY e.first_name, e.last_name, e.employee_id.
   MISTAKES I MADE:
     • Used CONCAT(first_name,' ',last_name) → CONCAT treats NULL as empty
       string, so unassigned-order rows show ' ' (a space), not the NULL
       the requirement needs → fix: use || which propagates NULL.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (WRONG — CONCAT masks NULL employee name) ───
-- CONCAT(NULL, ' ', NULL) -> ' ' (a space), not NULL. The query runs and
-- revenue is correct, but employee_name fails the required NULL output
-- for the unassigned-order row. Kept commented for reference.
--
-- SELECT
--     CONCAT(e.first_name,' ',e.last_name) AS employee_name,
--     COALESCE(
--         ROUND(
--             SUM((od.unit_price * od.quantity * (1 - od.discount))::numeric),
--             2
--         ),
--         0
--     ) AS total_revenue
-- FROM employees e
-- FULL OUTER JOIN orders o
--     ON e.employee_id = o.employee_id
-- FULL OUTER JOIN order_details od
--     ON od.order_id = o.order_id
-- GROUP BY
--     e.first_name,
--     e.last_name,
--     e.employee_id;

-- ── FINAL CORRECT SOLUTION (|| propagates NULL) ─────────────────────
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
'a' || NULL || 'b'      -> NULL   (NULL propagates through the expression)
Use || whenever a NULL component should make the whole result NULL.

Note — join chain integrity:
Both joins must stay FULL OUTER JOIN. Downgrading orders -> order_details
to INNER/LEFT would silently drop employee/order rows with no matching
order_details line, even though the first FULL OUTER JOIN preserved them.

Note — ::numeric cast:
ROUND(value, 2) requires numeric in PostgreSQL; the raw arithmetic may be
double precision, so cast to avoid "function round(double precision,
integer) does not exist".
*/
