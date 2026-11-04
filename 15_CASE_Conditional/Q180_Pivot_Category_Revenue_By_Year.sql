/* =====================================================================
   Q180 · Pivot Category Revenue By Year
   Category : Conditional Aggregation (Pivot)     Difficulty : Medium
   Concepts : Pivot · SUM FILTER · EXTRACT · COALESCE · JOIN
   ---------------------------------------------------------------------
   PROBLEM : Return net revenue per category for 1996, 1997 and 1998 as separate columns, plus a total column, each rounded to 2 dp.
   APPROACH:
     1. Join categories → products → order_details → orders.
     2. For each year, SUM(net) FILTER (WHERE EXTRACT(YEAR FROM order_date) = yyyy).
     3. COALESCE(..., 0) and round each column.
     4. Group by category and order by category_name.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT
    c.category_name,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1996), 0)::numeric, 2) AS rev_1996,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1997), 0)::numeric, 2) AS rev_1997,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount))
          FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1998), 0)::numeric, 2) AS rev_1998,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2)    AS rev_total
FROM categories c
JOIN products p       ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
JOIN orders o         ON o.order_id    = od.order_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
