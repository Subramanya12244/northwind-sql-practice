/*
Question:
Return every unique pair of customers who share the same country, along with that country. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve customer pairs from the same country.

Approach:
See markdown file for full reasoning. Key points:
- *

Expected Output:
| customer_1_name | customer_2_name | country |
|-----------------|-----------------|---------|
| Maria Anders | Ana Trujillo | Germany |
| Maria Anders | Antonio Moreno | Germany |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 10/10
Takeaway: Classic SELF JOIN pattern: `t1.id < t2.id AND t1.common_column = t2.common_column`.

Complexity:
Easy
*/

select c1.contact_name as Customer_1_Name,
c2.contact_name as Customer_2_Name,
c1.country
from customers c1
join customers c2
on c1.customer_id < c2.customer_id
and c1.country = c2.country;
