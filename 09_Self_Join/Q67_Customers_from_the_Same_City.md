# Q67. Customers from the Same City

**Category:** SELF JOIN
**Difficulty:** Easy

---

## Problem Statement

Retrieve pairs of customers from the same city.

## Objective

Return every unique pair of customers who share the same city, along with that city. Exclude self-pairs and duplicate pairs.

## Tables Used

- `customers (aliased twice: c1, c2)`

## Expected Output

| Column Name | Description |
|-------------|-------------|
| customer_1_name | Contact name of the first customer |
| customer_2_name | Contact name of the second customer |
| city | The shared city |

**Sample output:**

| customer_1_name | customer_2_name | city |
|-----------------|-----------------|------|
| Maria Anders | Hanna Moos | Berlin |
| Ana Trujillo | Antonio Moreno | México D.F. |

*(Sample values are illustrative, based on the standard Northwind dataset.)*

## Concepts Used

- SELF JOIN
- INNER JOIN
- Duplicate pair elimination (id < id)

## Why This Approach

**Why structurally identical to Q66:** "same city" is the same pattern as "same country" — only the matching column changes from `country` to `city`. The join structure, alias pattern, and deduplication condition are unchanged.

**The mistake to avoid:** the join condition `c1.city = c2.city` is the correct "same" condition — but the SELECT list must also show `c1.city`, not `c1.country`. These are easy to conflate when rapidly adapting one query to another, as Q67's mistake demonstrates.

### ❌ Attempt — Correct join condition, wrong SELECT column:

```sql
select c1.contact_name as Customer_1_Name,
c2.contact_name as Customer_2_Name,
c1.country  -- ❌ should be c1.city
from customers c1
join customers c2
on c1.customer_id < c2.customer_id
and c1.city = c2.city;
```

**Why it fails:** Join condition is correct (`c1.city = c2.city`) but SELECT shows `c1.country` instead of `c1.city`.


## Common Mistakes

- **Column selection error — selected `c1.country` instead of `c1.city`:** `c1.country  -- ❌ wrong column selected` — The join condition correctly compared `c1.city = c2.city`, but the SELECT list showed `c1.country` — a copy-paste error from Q66. Always verify the SELECT list matches the question's dimension, not just the join condition.

## Difficulty

**Easy**

## Interview Follow-up Questions

**1. Q67 had the correct join condition but wrong SELECT column. What does this suggest about a common mistake type in SQL?**

It demonstrates that SQL errors are not always in the logic of the query — sometimes the query finds the right rows (correct join, correct filtering) but displays the wrong attribute. The join condition determines which rows are returned; the SELECT list determines what is shown for those rows. Both must independently match the requirement. A quick sanity check: 'does every column in my SELECT list answer the question being asked?' would catch this.

**2. How does this differ from Q66 structurally?**

Q66 and Q67 are structurally identical — same table, same alias pattern, same `<` deduplication. The only differences are: (1) the join condition uses `city` instead of `country`, and (2) the SELECT list shows `city` instead of `country`. This demonstrates that the SELF JOIN pair pattern is truly a template where only the matching dimension changes.

**3. How would you find customers from the same city AND the same country in one query?**

Add both conditions to the join: `ON c1.customer_id < c2.customer_id AND c1.city = c2.city AND c1.country = c2.country`. Since city is inherently within a country, this is equivalent to just matching on city — but explicitly including country makes the intent clearer and is more defensive against cities with the same name in different countries.

**4. How would you find cities with more than 2 customers without using a SELF JOIN?**

`SELECT city, COUNT(*) AS customer_count FROM customers GROUP BY city HAVING COUNT(*) > 2 ORDER BY customer_count DESC`. For just counting and filtering, GROUP BY HAVING is simpler. SELF JOIN is only needed when the output must show the actual pairs.

## Learning Outcomes

- Always verify both the join condition AND the SELECT list against the question's requirement — errors in either produce wrong output.
- Reinforce that the SELF JOIN pair template only changes the matching column and the primary key alias between questions.

---

**Score from review session: 9.5/10**

**Interview Takeaway:** Always double-check the selected columns, not just the join condition.

📄 **SQL File:** [`Q67_Customers_from_the_Same_City.sql`](./Q67_Customers_from_the_Same_City.sql)
