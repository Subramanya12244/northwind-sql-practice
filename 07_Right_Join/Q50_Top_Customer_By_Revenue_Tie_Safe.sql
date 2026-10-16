/* =====================================================================
   Q50 · Top Customer(s) by Revenue — Tie-Safe (Interview Level)
   Category : RIGHT JOIN + CTE + CROSS JOIN     Difficulty : Hard
   Concepts : CTE (chained) · RIGHT JOIN · CROSS JOIN · GROUP BY
              · SUM · MAX · COALESCE · Tie Handling · ROUND/CAST
   ---------------------------------------------------------------------
   PROBLEM : Return the customer(s) with the highest total revenue,
             returning ALL of them if several tie for the top spot.
   APPROACH:
     1. CTE revenue: total discounted revenue per customer (RIGHT JOIN chain;
        zero-revenue customers are irrelevant to a top-revenue query).
        GROUP BY customer_id, contact_name.
     2. CTE max_rev: SELECT MAX(total_revenue) — exactly ONE row.
     3. CROSS JOIN max_rev (1 row) with revenue (N rows) = scalar broadcast;
        WHERE total_revenue >= max_rev returns every tied customer.
     Note: avoid LIMIT 1 (drops ties); = alternatives: scalar subquery or RANK()=1.
   MISTAKES I MADE:
     • none — clean on first attempt
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT (correct — this is the solution) ────────────
WITH revenue AS
(
    SELECT
        c.contact_name,
        COALESCE(
            ROUND(
                SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric,
                2
            ),
            0
        ) AS total_revenue
    FROM customers c
    RIGHT JOIN orders o
        ON c.customer_id = o.customer_id
    RIGHT JOIN order_details od
        ON o.order_id = od.order_id
    GROUP BY
        c.customer_id,
        c.contact_name
),
max_rev AS
(
    SELECT
        MAX(total_revenue) AS max_rev
    FROM revenue
)
SELECT
    r.contact_name,
    r.total_revenue
FROM max_rev m
CROSS JOIN revenue r
WHERE r.total_revenue >= m.max_rev;
