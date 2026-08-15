# Q70. Customers Sharing the Same Postal Code

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve pairs of customers having the same postal code.

## Objective

Return every unique pair of customers who share the same postal code, along with that postal code. Exclude self-pairs and duplicate pairs.

## Tables Used

- `customers (aliased twice: c1, c2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| contact_name (c1) | Contact name of the first customer |
| contact_name (c2) | Contact name of the second customer |
| postal_code | The shared postal code |

**Sample output:**

| contact_name (c1) | contact_name (c2) | postal_code |
|-------------------|-------------------|-------------|
| Maria Anders | Hanna Moos | 12209 |
| Ana Trujillo | Antonio Moreno | 05021 |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why this confirms full mastery of the SELF JOIN pair pattern:** Q70 is a clean application of the established template with no mistakes, no extra complexity, and no additional joins. `ON c1.customer_id < c2.customer_id AND c1.postal_code = c2.postal_code` — the pattern is now mechanical.

**The complete SELF JOIN pair template:**
```sql
FROM table t1
JOIN table t2
    ON t1.primary_key < t2.primary_key       -- deduplication
    AND t1.match_column = t2.match_column     -- the 'same' condition
```
Both elements are always present. The specific table, key, and match column are the only things that change per question.

## Common Mistakes


## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Summarise the SELF JOIN pair pattern established across Q63–Q70 in one formula.**

`FROM table t1 JOIN table t2 ON t1.id < t2.id AND t1.common_column = t2.common_column`. The `id < id` condition eliminates self-pairs and duplicate pairs in one step. The `common_column = common_column` condition defines what 'same' means for the specific business question. The only variation is when a third alias (Q63) or a third table join (Q69) is needed to display a name or value not available directly on t1 or t2.

**2. When should you use `<` vs `<=` vs `<>` in SELF JOIN deduplication?**

`<` (strictly less than): eliminates self-pairs AND duplicate pairs — the standard choice for pair queries. Each pair (A,B) appears exactly once. `<=` (less than or equal): removes self-pairs only partially — (A,A) is excluded but (A,B) and (B,A) still both appear. Never use for pair deduplication. `<>` (not equal): removes self-pairs (A,A) but keeps both (A,B) and (B,A) — duplicates remain. Only useful if you specifically want both orderings of each pair for a downstream process.

**3. How would you extend any of these pair queries to also count how many pairs each entity is involved in?**

Use a CTE to get the pairs, then count appearances per entity: `WITH pairs AS (SELECT c1.contact_name AS c1, c2.contact_name AS c2, c1.postal_code FROM customers c1 JOIN customers c2 ON c1.customer_id < c2.customer_id AND c1.postal_code = c2.postal_code) SELECT c1, COUNT(*) AS pair_count FROM pairs GROUP BY c1 ORDER BY pair_count DESC`.

**4. Is there a case where SELF JOIN produces more rows than expected even with the `<` condition?**

Yes — when the match column has NULL values. `NULL = NULL` evaluates to NULL (unknown) in SQL join conditions, so rows with NULL postal codes will never match each other and won't appear in the result. If you want to pair rows with matching NULLs, you need: `ON c1.customer_id < c2.customer_id AND (c1.postal_code = c2.postal_code OR (c1.postal_code IS NULL AND c2.postal_code IS NULL))`. In standard datasets like Northwind this is rarely an issue, but worth knowing for production data.

## Learning Outcomes

- Confirm complete mastery of the SELF JOIN pair pattern: `t1.id < t2.id AND t1.column = t2.column`.
- Know the difference between `<`, `<=`, and `<>` for SELF JOIN deduplication — `<` is the universal correct choice for unique pairs.
- Understand the NULL matching edge case in SELF JOIN conditions — `NULL = NULL` is false in join conditions, so rows with NULL match columns never pair with each other.

---

**Score from review session: 10/10**

**Interview Takeaway:** By Q70, the SELF JOIN pair pattern is fully mastered: `t1.id < t2.id AND t1.common_column = t2.common_column`.

📄 **SQL File:** [`Q70_Customers_Sharing_the_Same_Postal_Code.sql`](./Q70_Customers_Sharing_the_Same_Postal_Code.sql)
