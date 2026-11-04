/* =====================================================================
   Q118 · Customers Inactive In Last Six Months
   Category : Date & Time (Recency / Churn)          Difficulty : Hard
   Concepts : LEFT JOIN · MAX · INTERVAL · NULLS FIRST · Fixed Reference Date · CTE
   ---------------------------------------------------------------------
   PROBLEM : Return customers whose most recent order is before 1998-06-30, or who have no orders, with last order date and days since then.
   APPROACH:
     1. CTE: LEFT JOIN customers to orders; take MAX(order_date) and COUNT(o.order_id) per customer.
     2. Cutoff = (DATE '1998-12-31' - INTERVAL '6 months')::date = 1998-06-30.
     3. Keep rows where last order is NULL or before the cutoff.
     4. Order by last_order_date NULLS FIRST, tie-break on customer_id.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH last_orders AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.country,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.order_id) AS lifetime_orders
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.company_name, c.country
)
SELECT
    customer_id,
    company_name,
    country,
    last_order_date,
    lifetime_orders,
    (DATE '1998-12-31' - last_order_date) AS days_since_last_order
FROM last_orders
WHERE last_order_date IS NULL
   OR last_order_date < (DATE '1998-12-31' - INTERVAL '6 months')::date
ORDER BY last_order_date NULLS FIRST, customer_id;
