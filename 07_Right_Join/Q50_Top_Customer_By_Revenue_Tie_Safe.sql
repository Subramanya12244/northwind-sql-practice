/*
Question:
Return the customer(s) with the highest total revenue, correctly
returning all customers if multiple are tied for the top spot.

Business Requirement:
The sales director wants to identify the top revenue-generating
customer(s). If multiple customers share the highest revenue, all
must be returned — no tied customer should be silently dropped.

---
COMMON MISTAKES TO AVOID
---

Mistake 1 — Using LIMIT 1 (silently drops tied customers):
    SELECT contact_name, total_revenue
    FROM revenue
    ORDER BY total_revenue DESC
    LIMIT 1;  -- ❌ returns only one row even when ties exist

Mistake 2 — GROUP BY contact_name only (merges same-name customers):
    GROUP BY c.contact_name  -- ❌ always include customer_id as well

Mistake 3 — ROW_NUMBER() instead of RANK() (non-deterministic for ties):
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) = 1  -- ❌
    -- assigns 1 to only one tied customer arbitrarily

Mistake 4 — Strict = on floating-point values (risky):
    WHERE r.total_revenue = m.max_rev  -- ⚠️ use >= instead

Mistake 5 — Missing ::numeric cast before ROUND() (PostgreSQL error):
    ROUND(SUM(...)  , 2)  -- ❌ double precision not accepted
    ROUND(SUM(...)::numeric, 2)  -- ✅ cast required

Mistake 6 — CROSS JOINing a multi-row CTE (Cartesian explosion):
    -- Only safe when the CROSS JOIN'd CTE returns exactly ONE row.
    -- max_rev uses SELECT MAX(...) with no GROUP BY = guaranteed one row.

---
CORRECT APPROACH
---

Approach:
1. CTE revenue: compute total discounted revenue per customer using
   RIGHT JOIN chain (orders and order_details are the preserved tables
   here — customers with zero revenue are irrelevant to a top-revenue
   query, so join direction does not affect correctness for this use case).
   GROUP BY c.customer_id, c.contact_name — both required.

2. CTE max_rev: SELECT MAX(total_revenue) — produces exactly ONE row
   containing the company-wide highest revenue value.

3. Final SELECT: CROSS JOIN max_rev (one row) with revenue (N rows) —
   attaches the max value to every customer row (scalar broadcast).
   WHERE r.total_revenue >= m.max_rev filters to only the customer(s)
   matching the maximum, naturally returning every tied customer.

Why CROSS JOIN is safe here:
   max_rev is guaranteed to produce exactly one row (no GROUP BY).
   CROSS JOIN between 1 row and N rows = N rows (no multiplication).

Why >= instead of =:
   Safer for floating-point revenue values where tiny rounding
   differences could cause strict equality to fail silently.

Why not LIMIT 1:
   LIMIT 1 silently drops tied customers — the most common wrong
   answer for this type of interview question.

Alternative approaches (all correct, all tie-safe):
   -- Scalar subquery:
   WHERE total_revenue = (SELECT MAX(total_revenue) FROM revenue)

   -- Window function (RANK, not ROW_NUMBER):
   RANK() OVER (ORDER BY total_revenue DESC) = 1

Expected Output:
| contact_name | total_revenue |
|--------------|---------------|
| Ernst Handel | 128945.75     |

(If two customers tie, both rows are returned.)

Concepts Used:
- CTE (multiple)
- RIGHT JOIN (chained, two levels)
- CROSS JOIN (scalar broadcast — one-row CTE)
- GROUP BY
- Aggregate Functions (SUM, MAX, COALESCE)
- Tie Handling
- ROUND / CAST

Complexity:
Hard
*/

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
