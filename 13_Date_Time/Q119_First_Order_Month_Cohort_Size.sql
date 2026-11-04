/* =====================================================================
   Q119 · First Order Month Cohort Size
   Category : Date & Time (Cohort Analysis)          Difficulty : Hard
   Concepts : DATE_TRUNC · MIN · CTE · GROUP BY · Running SUM Window
   ---------------------------------------------------------------------
   PROBLEM : Return, per first-order year and month, the number of newly acquired customers and the cumulative total.
   APPROACH:
     1. CTE first_orders: per customer, DATE_TRUNC('month', MIN(order_date))::date.
     2. Group by cohort month and COUNT(*) customers.
     3. Running total with SUM(COUNT(*)) OVER (ORDER BY cohort_month).
     4. Split into integer year and month; order by both.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
WITH first_orders AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT
    EXTRACT(YEAR FROM cohort_month)::int  AS cohort_year,
    EXTRACT(MONTH FROM cohort_month)::int AS cohort_month_num,
    COUNT(*)                              AS new_customers,
    SUM(COUNT(*)) OVER (ORDER BY cohort_month)::int AS cumulative_customers
FROM first_orders
GROUP BY cohort_month
ORDER BY cohort_year, cohort_month_num;
