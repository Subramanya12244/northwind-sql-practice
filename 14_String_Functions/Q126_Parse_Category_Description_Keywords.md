# Q126 · Parse Category Description Keywords

> **Revision Card**
> **Category:** String Functions (Parsing) | **Difficulty:** Hard
> **Concepts:** SPLIT_PART · REPLACE · LENGTH · TRIM · Delimiter Counting
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** The last item in Northwind descriptions is joined with `and`, so a plain comma count is one short.

## 1. Problem

Merchandising wants to tag each category with its headline keyword and know how many product types its description lists, e.g. "Soft drinks, coffees, teas, beers, and ales" has 5.

**Objective:** For each category, return the first keyword of the description (text before the first comma), the number of comma-separated items, and the final item with any leading `and ` removed.

**Tables:** `categories`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_id | Category identifier |
| category_name | Category name |
| first_keyword | Text before the first comma |
| item_count | Commas + 1 (descriptions without commas count as 1) |
| last_item | Final item, with a leading `and ` removed |

| category_id | category_name | first_keyword | item_count | last_item |
|-------------|---------------|---------------|------------|-----------|
| 1 | Beverages | Soft drinks | 5 | ales |
| 2 | Condiments | Sweet and savory sauces | 4 | seasonings |
| 3 | Confections | Desserts | 3 | sweet breads |
| 4 | Dairy Products | Cheeses | 1 | Cheeses |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. `SPLIT_PART(description, ',', 1)` gives the first keyword.
2. Count commas with `LENGTH(description) - LENGTH(REPLACE(description, ',', ''))`, then add 1.
3. Take the last comma field with `SPLIT_PART(description, ',', -1)`, `TRIM` it and strip a leading `and ` with `REGEXP_REPLACE`.
4. Order by `category_id`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    category_id,
    category_name,
    TRIM(SPLIT_PART(description, ',', 1))                                   AS first_keyword,
    LENGTH(description) - LENGTH(REPLACE(description, ',', '')) + 1         AS item_count,
    REGEXP_REPLACE(TRIM(SPLIT_PART(description, ',', -1)), '^and ', '')     AS last_item
FROM categories
ORDER BY category_id;
```

## 6. Why This Works

Counting a delimiter by comparing the length before and after `REPLACE` is a portable trick: every removed comma shortens the text by one. `SPLIT_PART` with a negative index (PostgreSQL 14+) counts fields from the end. `TRIM` removes the space after each comma and the anchored regex `^and ` removes the Oxford-comma conjunction only at the start of the last item.

## 7. Common Pitfalls (generic)

- Counting `' and '` occurrences as extra items — the description uses `, and`, so the comma count already includes the last item.
- Forgetting `TRIM` and returning values with a leading space.
- Using `REPLACE(text, 'and ', '')` — it also removes `and ` inside words such as `candies`.

## 8. Interview Follow-ups

**1. How would you return one row per item instead?**

`SELECT category_id, TRIM(item) FROM categories, UNNEST(STRING_TO_ARRAY(description, ',')) AS item` or `REGEXP_SPLIT_TO_TABLE(description, ',\s*')`.

**2. What does `SPLIT_PART` return when the field does not exist?**

An empty string, not NULL — wrap in `NULLIF(..., '')` if NULL is needed.

**3. How else could you count items?**

`ARRAY_LENGTH(STRING_TO_ARRAY(description, ','), 1)`.

## 9. Key Takeaway

Count delimiters with `LENGTH - LENGTH(REPLACE())`, pick fields with `SPLIT_PART` (negative index from the end) and clean with `TRIM`/anchored regex.

---
📄 **SQL File:** [`Q126_Parse_Category_Description_Keywords.sql`](./Q126_Parse_Category_Description_Keywords.sql)
