/*
Question:
Return all employees along with the number of distinct customers they
have served, including employees with no orders displayed as 0.

Business Requirement:
The management team wants a complete employee-customer breadth report —
every employee must appear, and those who have handled no orders should
show a customer count of 0 rather than being excluded.

Approach:
1. Start from employees and LEFT JOIN to orders on employee_id, preserving
   every employee regardless of order history.
2. Use COUNT(DISTINCT o.customer_id) to count unique customers per
   employee. DISTINCT is essential — without it, an employee handling
   multiple orders for the same customer would count that customer
   multiple times, inflating the figure.
3. COUNT returns 0 (not NULL) for empty groups, so COALESCE is not
   required here — unlike SUM(), which returns NULL for empty groups.
4. Concatenate first_name and last_name for a single display name column.
5. GROUP BY employee_id (the unique key) along with first_name and
   last_name, since they are non-aggregated selected columns.

Expected Output:
| employee_name    | customers_served |
|------------------|------------------|
| Nancy Davolio    | 45               |
| Janet Leverling  | 40               |
| Andrew Fuller    | 0                |

Concepts Used:
- LEFT JOIN
- GROUP BY
- Aggregate Functions (COUNT DISTINCT)
- String Concatenation
- NULL Handling

Complexity:
Medium
*/

SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT o.customer_id) AS customers_served
FROM employees e
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY customers_served DESC;
