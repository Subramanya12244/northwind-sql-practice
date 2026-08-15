/* Q93. Countries with Balanced Business Entities */

-- Correct Approach
WITH cte AS (
     SELECT    e.country,
     'employees' AS entity
     FROM      employees e
     UNION all
     SELECT    s.country,
     'supplier' AS entity
     FROM      suppliers s
     UNION all
     SELECT    c.country,
     'customers' AS entity
     FROM      customers c
     )
SELECT country,
       sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) as total_employees,
       sum(
       CASE
       WHEN entity = 'supplier' THEN 1
       ELSE 0
       END
       ) as total_suppliers,
       sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       ) as total_customers
FROM cte
GROUP BY country
HAVING sum(
       CASE
       WHEN entity = 'employees' THEN 1
       ELSE 0
       END
       ) != 0
AND sum(
    CASE
    WHEN entity = 'supplier' THEN 1
    ELSE 0
    END
    ) != 0
AND sum(
       CASE
       WHEN entity = 'customers' THEN 1
       ELSE 0
       END
       )!=0;
