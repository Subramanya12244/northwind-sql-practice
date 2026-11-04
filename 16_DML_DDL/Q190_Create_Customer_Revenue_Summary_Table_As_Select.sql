/* =====================================================================
   Q190 · Create Customer Revenue Summary Table As Select
   Category : DDL (CREATE TABLE AS)     Difficulty : Medium
   Concepts : CREATE TABLE AS · Aggregation · Primary Key via ALTER · Query the New Table
   ---------------------------------------------------------------------
   PROBLEM : Create customer_revenue_summary from an aggregate query, add a primary key on customer_id, and return the top 10 customers by revenue from the new table. Runs inside BEGIN … ROLLBACK, so the data change is undone after grading.
   APPROACH:
     1. CREATE TABLE customer_revenue_summary AS SELECT ... GROUP BY customer_id.
     2. ALTER TABLE ... ADD PRIMARY KEY (customer_id).
     3. SELECT from the new table ordered by revenue DESC, customer_id with LIMIT 10.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
CREATE TABLE customer_revenue_summary AS
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id)                                         AS order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY o.customer_id;

ALTER TABLE customer_revenue_summary ADD PRIMARY KEY (customer_id);

SELECT customer_id, order_count, revenue
FROM customer_revenue_summary
ORDER BY revenue DESC, customer_id
LIMIT 10;
