/* =====================================================================
   Q40 · Customers and Average Order Value
   Category : LEFT JOIN + CTE          Difficulty : Hard
   Concepts : CTE · LEFT JOIN (chained, two levels) · GROUP BY (two levels)
              · SUM · AVG · COALESCE · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Average order value per customer, with no-order customers
             shown as 0.00. Needs TWO levels of aggregation: sum line
             items to order totals, then average those per customer.
   APPROACH:
     1. CTE sum_value: GROUP BY order_id, SUM line items -> one total
        revenue per order (also exposes order_id as the join key).
     2. Outer query: LEFT JOIN customers -> orders -> sum_value (all LEFT).
     3. AVG(s.total_revenue) now averages per-order totals per customer.
     4. COALESCE(..., 0) for no-order customers (AVG -> NULL).
     5. GROUP BY customer.
   MISTAKES I MADE:
     • First attempt averaged line items directly (AVG over order_details)
       -> wrong grain. Fix: sum to order totals in a CTE first, then AVG.
     • Second attempt used a CTE with no GROUP BY order_id, so there was
       no key to join back on and the join was invalid. Fix: GROUP BY
       order_id in the CTE so each total maps to its order.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPTS (both WRONG — kept for reference) ───────────
-- Attempt 1 — averages line items, not orders (wrong grain):
-- SELECT c.contact_name,
--     COALESCE(ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0)
-- FROM customers c
-- LEFT JOIN orders o ON o.customer_id = c.customer_id
-- LEFT JOIN order_details od ON od.order_id = o.order_id
-- GROUP BY c.contact_name, c.customer_id;
--
-- Attempt 2 — CTE with no GROUP BY order_id, broken join (no key):
-- WITH sum_value AS (
--     SELECT COALESCE(ROUND(SUM(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) AS total_revenue
--     FROM order_details od
-- )
-- ... LEFT JOIN sum_value ON o   -- invalid: no join condition, no order_id

-- ── FINAL CORRECT SOLUTION (runnable) ────────────────────────────────
with sum_value as
(
    select
        order_id,
        coalesce(
            round(
                sum(od.unit_price * od.quantity * (1 - od.discount))::numeric
            , 2), 0) as total_revenue
    from order_details od
    group by order_id
)
select c.contact_name,
coalesce(
    round(
        avg(s.total_revenue)::numeric
    , 2), 0) as average_order_value
from customers c
left join orders o on o.customer_id = c.customer_id
left join sum_value s on s.order_id = o.order_id
group by c.contact_name, c.customer_id;
