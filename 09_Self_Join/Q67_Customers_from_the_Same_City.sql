/*
Question:
Return every unique pair of customers who share the same city, along with that city. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve pairs of customers from the same city.

Approach:
See markdown file for full reasoning. Key points:



-- Attempt — Correct join condition, wrong SELECT column:
-- Reason it fails: Join condition is correct (`c1.city = c2.city`) but SELECT shows `c1.country` instead of `c1.city`.
--
-- 
select c1.contact_name as Customer_1_Name,-- c2.contact_name as Customer_2_Name,-- c1.country  -- ❌ should be c1.city-- from customers c1-- join customers c2-- on c1.customer_id < c2.customer_id-- and c1.city = c2.city;

Expected Output:
| customer_1_name | customer_2_name | city |
|-----------------|-----------------|------|
| Maria Anders | Hanna Moos | Berlin |
| Ana Trujillo | Antonio Moreno | México D.F. |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 9.5/10
Takeaway: Always double-check the selected columns, not just the join condition.

Complexity:
Easy
*/

SELECT
    c1.contact_name AS customer_1_name,
    c2.contact_name AS customer_2_name,
    c1.city
FROM customers c1
JOIN customers c2
    ON c1.customer_id < c2.customer_id
    AND c1.city = c2.city;
