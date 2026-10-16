/* =====================================================================
   Q49 · Customers and Average Order Value (RIGHT JOIN)
   Category : RIGHT JOIN + CTE          Difficulty : Hard
   Concepts : CTE · RIGHT JOIN (chained, two levels) · GROUP BY (two levels)
              · SUM · AVG · COALESCE · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Return all customers with their average ORDER value (not line-
             item value), showing 0.00 for customers with no orders. RIGHT JOIN only.
   APPROACH:
     1. CTE order_totals: SUM line items per order_id (correct grain for
        averaging). RIGHT JOIN orders to keep orders with no line items.
     2. Outer: RIGHT JOIN customers as the final right table — preserves
        every customer regardless of order history.
     3. AVG(order_revenue) per customer; COALESCE NULL -> 0.00.
     4. GROUP BY contact_name, customer_id.
   MISTAKES I MADE:
     • Chain was customers->orders->order_details, preserving order_details
       (not customers) -> no-order customers were dropped. Fix: reverse to
       order_details->orders->customers.
     • contact_name in SELECT but missing from GROUP BY -> PostgreSQL error.
     • Outer GROUP BY on contact_name alone -> merges same-name customers.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (buggy — kept for reference, do not run) ─────
-- WITH sum_rev AS (
--     SELECT
--         c.contact_name,
--         COALESCE(ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric, 2), 0) AS total_revenue
--     FROM customers c
--     RIGHT JOIN orders o ON c.customer_id = o.customer_id
--     RIGHT JOIN order_details od ON o.order_id = od.order_id
--     GROUP BY c.customer_id, o.order_id        -- contact_name not in GROUP BY
-- )
-- SELECT contact_name, AVG(total_revenue) AS average_order_value
-- FROM sum_rev
-- GROUP BY contact_name;                         -- customer_id missing; order_details preserved, not customers

-- ── FINAL CORRECT SOLUTION ───────────────────────────────────────────
WITH order_totals AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS order_revenue
    FROM order_details od
    RIGHT JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.contact_name,
    COALESCE(
        ROUND(AVG(ot.order_revenue)::numeric, 2),
        0
    ) AS average_order_value
FROM order_totals ot
RIGHT JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.contact_name, c.customer_id;
