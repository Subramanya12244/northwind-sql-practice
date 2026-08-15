# Q66. Customers from the Same Country

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve customer pairs from the same country.

## Objective

Return every unique pair of customers who share the same country, along with that country. Exclude self-pairs and duplicate pairs.

## Tables Used

- `customers (aliased twice: c1, c2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_1_name | Contact name of the first customer |
| customer_2_name | Contact name of the second customer |
| country | The shared country |

**Sample output:**

| customer_1_name | customer_2_name | country |
|-----------------|-----------------|---------|
| Maria Anders | Ana Trujillo | Germany |
| Maria Anders | Antonio Moreno | Germany |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why this is the purest form of the standard SELF JOIN pair pattern:** `ON c1.customer_id < c2.customer_id AND c1.country = c2.country` — the `<` deduplicates, the `=` defines the "same" condition. No date functions, no third aliases, no aggregation. This is the template that all previous pair questions were building toward.

**Pattern summary established by Q66:**
```
FROM table t1
JOIN table t2
ON t1.id < t2.id
AND t1.common_column = t2.common_column
```
The `id < id` condition is the universal deduplication mechanism; the second condition defines what "same" means for the specific question.

## Common Mistakes

- Forgetting `c1.country = c2.country` — without it, every customer is paired with every other customer (a Cartesian product within the SELF JOIN).
- Using `<>` instead of `<` — removes self-pairs but still returns each pair twice (A,B) and (B,A).

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. What does the condition `c1.customer_id < c2.customer_id` accomplish, and why is `<` better than `<>`?**

`<>` (not equal) removes self-pairs (A,A) but still returns both (A,B) and (B,A) as separate rows — duplicating every pair. `<` (strictly less than) only allows the pair where c1's ID is numerically lower, ensuring each unordered pair appears exactly once. It eliminates both self-pairs and duplicate pairs in a single condition.

**2. By Q66, this pattern has become 'mechanical' — what are the two elements that always change between SELF JOIN pair questions?**

1. The table and its primary key column (e.g. `customer_id`, `employee_id`, `product_id`). 2. The 'same' condition — the column being compared for equality (e.g. `country`, `title`, `category_id`, `hire_year`). Everything else — the `<` deduplication, the alias structure, the SELECT pattern — stays identical.

**3. How would you count how many customer pairs share each country?**

`SELECT c1.country, COUNT(*) AS pair_count FROM customers c1 JOIN customers c2 ON c1.customer_id < c2.customer_id AND c1.country = c2.country GROUP BY c1.country ORDER BY pair_count DESC`.

**4. How would you find countries with at least 3 customers (but without SELF JOIN)?**

`SELECT country, COUNT(*) AS customer_count FROM customers GROUP BY country HAVING COUNT(*) >= 3 ORDER BY customer_count DESC`. This answers 'how many customers per country' — a simpler aggregation question. The SELF JOIN is needed when you specifically want the pairs themselves, not just the counts.

## Learning Outcomes

- Confirm mastery of the standard SELF JOIN pair pattern: `t1.id < t2.id AND t1.column = t2.column`.
- Understand the difference between `<>` (removes self-pairs only) and `<` (removes self-pairs AND duplicates).
- Know when SELF JOIN is needed (to return pairs) vs when GROUP BY HAVING is sufficient (to count entities with a shared attribute).

---

**Score from review session: 10/10**

**Interview Takeaway:** Classic SELF JOIN pattern: `t1.id < t2.id AND t1.common_column = t2.common_column`.

📄 **SQL File:** [`Q66_Customers_from_the_Same_Country.sql`](./Q66_Customers_from_the_Same_Country.sql)
