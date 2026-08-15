/*
Question:
Return every unique pair of customers who share the same postal code, along with that postal code. Exclude self-pairs and duplicate pairs.

Business Requirement:
Retrieve pairs of customers having the same postal code.

Approach:
See markdown file for full reasoning. Key points:
- *

Expected Output:
| contact_name (c1) | contact_name (c2) | postal_code |
|-------------------|-------------------|-------------|
| Maria Anders | Hanna Moos | 12209 |
| Ana Trujillo | Antonio Moreno | 05021 |

Concepts Used:
- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

Score: 10/10
Takeaway: By Q70, the SELF JOIN pair pattern is fully mastered: `t1.id < t2.id AND t1.common_column = t2.common_column`.

Complexity:
Easy
*/

select c1.contact_name,
c2.contact_name,
c1.postal_code
from customers c1
join customers c2 on c1.customer_id < c2.customer_id
and c1.postal_code = c2.postal_code;
