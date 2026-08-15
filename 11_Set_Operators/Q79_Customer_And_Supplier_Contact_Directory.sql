/*
Question:
Return a single unified list of contact names from both customers
and suppliers, with duplicates removed.

Business Requirement:
Create a combined contact directory merging customer contacts and
supplier contacts into one alphabetical list.

Approach:
1. SELECT contact_name FROM customers — all customer contacts.
2. UNION SELECT contact_name FROM suppliers — all supplier contacts.
3. UNION (not UNION ALL) automatically removes duplicate names
   that appear in both tables.
4. Both SELECTs return one column of compatible type (varchar) —
   the two UNION rules are satisfied.

UNION vs JOIN:
   JOIN  — combines COLUMNS from rows sharing a key (wider rows)
   UNION — combines ROWS from queries sharing the same structure (longer list)
   customers and suppliers have no shared key, so JOIN is not applicable here.

UNION vs UNION ALL:
   UNION     — deduplicates (use when duplicates are unwanted)
   UNION ALL — keeps all rows including duplicates (faster, no dedup step)

ORDER BY (if needed — add after the final SELECT):
   SELECT contact_name FROM customers
   UNION
   SELECT contact_name FROM suppliers
   ORDER BY contact_name;

Expected Output:
| contact_name     |
|------------------|
| Maria Anders     |
| Ana Trujillo     |
| Charlotte Cooper |

Concepts Used:
- UNION
- Set Operators

Complexity:
Easy
*/

select c.contact_name from customers c
union
select s.contact_name from suppliers s;
