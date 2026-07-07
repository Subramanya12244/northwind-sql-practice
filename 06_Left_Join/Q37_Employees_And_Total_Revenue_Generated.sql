/*
Question:
Return all employees along with the total revenue they generated,
including employees with no orders displayed as 0.00.

Business Requirement:
The management team wants a complete employee revenue report — every
employee must appear, and those who have handled no orders should show
a revenue of 0.00 rather than being excluded.

Approach:
1. Start from employees and LEFT JOIN to orders on employee_id, preserving
   every employee regardless of order history.
2. LEFT JOIN again to order_details on order_id — must remain LEFT JOIN
   so NULL-padded rows from step 1 are not dropped at this stage.
3. Calculate discounted revenue per line item:
   unit_price * quantity * (1 - discount).
4. Aggregate with SUM() at the employee level.
5. Wrap in COALESCE(..., 0) — SUM() returns NULL (not 0) for empty groups,
   so COALESCE is required to convert that NULL into 0.00 for display.
6. Cast to numeric and ROUND to 2 decimal places.
7. Use CONCAT() for the employee display name — safer than || for NULL
   name parts, as CONCAT treats NULL as empty string rather than
   propagating NULL through the entire expression.
8. GROUP BY e.employee_id only — sufficient since name columns are
   consumed inside CONCAT() and not referenced as standalone SELECT items.

Expected Output:
| employee_name    | total_revenue |
|------------------|---------------|
| Margaret Peacock | 232890.85     |
| Nancy Davolio    | 128945.75     |
| Andrew Fuller    | 0.00          |

Concepts Used:
- LEFT JOIN (chained, two levels)
- GROUP BY
- Aggregate Functions (SUM)
- NULL Handling (COALESCE)
- ROUND / CAST
- String Concatenation (CONCAT)

Complexity:
Medium
*/

select concat(e.first_name,' ',e.last_name) as employee_name,
coalesce(round(sum(od.unit_price*od.quantity*(1-od.discount))::numeric,2),0) as total_revenue
from employees e
left join orders o on o.employee_id = e.employee_id
left join order_details od on od.order_id = o.order_id
group by e.employee_id;
