/* =====================================================================
   Q196 · Revenue By Discount Tier
   Category : CASE & Conditional Logic (Bucketing a Float Column)     Difficulty : Medium
   Concepts : CASE · Half-open ranges · REAL precision · GROUP BY ordinal · SUM · AVG
   ---------------------------------------------------------------------
   PROBLEM : Bucket order lines into No discount, Under 10%, 10% to under 15%, and 15% or more; show lines, units, net revenue (2 dp) and average quantity (1 dp) per tier, in tier order.
   APPROACH:
     1. CASE with half-open ranges: = 0, < 0.1, < 0.15, else.
     2. GROUP BY 1 groups by the CASE expression.
     3. Number the labels so ORDER BY discount_tier sorts them in tier order.
   MISTAKES I MADE:
     • not attempted yet
   ===================================================================== */

-- ── REFERENCE SOLUTION ──────────────────────────────────────────────
SELECT CASE
         WHEN discount = 0    THEN '1. No discount'
         WHEN discount < 0.1  THEN '2. Under 10%'
         WHEN discount < 0.15 THEN '3. 10% to under 15%'
         ELSE                      '4. 15% or more'
       END                                                          AS discount_tier,
       COUNT(*)                                                     AS order_lines,
       SUM(quantity)                                                AS units,
       ROUND(SUM(unit_price * quantity * (1 - discount))::numeric, 2) AS net_revenue,
       ROUND(AVG(quantity), 1)                                      AS avg_quantity
FROM order_details
GROUP BY 1
ORDER BY discount_tier;
