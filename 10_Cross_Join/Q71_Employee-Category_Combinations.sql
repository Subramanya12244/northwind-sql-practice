/* =====================================================================
   Q71 · Employee–Category Combinations
   Category : CROSS JOIN          Difficulty : Easy
   Concepts : CROSS JOIN · Cartesian product · No ON clause · CONCAT
   ---------------------------------------------------------------------
   PROBLEM : Every employee paired with every product category
             (every employee × every category).
   APPROACH:
     1. Recognise "every X with every Y" -> CROSS JOIN.
     2. Use only employees and categories; no relationship joins.
     3. CROSS JOIN with no ON clause -> N × M = 9 × 8 = 72 rows.
     4. Build employee_name with CONCAT(first_name,' ',last_name).
   MISTAKES I MADE:
     • Added ON clause to CROSS JOIN -> remove it (ON makes it an INNER JOIN).
     • Joined 5 tables (products/order_details/orders) -> only 2 tables needed.
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (wrong — ON clause + unnecessary joins) ─────
-- select concat(e.first_name,' ',e.last_name) as employee_name,
-- c.category_name
-- from categories c
-- cross join products p on p.category_id = c.category_id
-- cross join order_details od on od.product_id = p.product_id
-- cross join orders o on o.order_id = od.order_id
-- cross join employees e on e.employee_id = o.employee_id

-- ── FINAL CORRECT SOLUTION ──────────────────────────────────────────
SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    c.category_name
FROM employees e
CROSS JOIN categories c;
