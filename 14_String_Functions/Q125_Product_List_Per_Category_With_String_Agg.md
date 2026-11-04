# Q125 · Product List Per Category With String Agg

> **Revision Card**
> **Category:** String Functions (Aggregation) | **Difficulty:** Medium
> **Concepts:** STRING_AGG · ORDER BY inside aggregate · JOIN · GROUP BY · COUNT
> **Outcome:** 🆕 new practice question — not attempted yet
> **Watch out for:** Without `ORDER BY` inside `STRING_AGG`, the list order is not guaranteed.

## 1. Problem

The catalogue editor wants one line per category listing its active products alphabetically, comma-separated, to paste into the print catalogue.

**Objective:** For each category, return the number of non-discontinued products and an alphabetical comma-separated list of their names.

**Tables:** `categories`, `products`

**Expected output:**

| Column | Description |
|--------|-------------|
| category_name | Category name |
| product_count | Number of active products |
| product_list | Product names, alphabetical, separated by `, ` |

| category_name | product_count | product_list |
|---------------|---------------|--------------|
| Beverages | 11 | Chai, Chang, Chartreuse verte, Côte de Blaye, Ipoh Coffee, Lakkalikööri, Laughing Lumberjack Lager, Outback Lager, Rhönbräu Klosterbier, Sasquatch Ale, Steeleye Stout |
| Condiments | 11 | Aniseed Syrup, Chef Anton's Cajun Seasoning, Genen Shouyu, Grandma's Boysenberry Spread, Gula Malacca, Louisiana Fiery Hot Pepper Sauce, Louisiana Hot Spiced Okra, Northwoods Cranberry Sauce, Original Frankfurter grüne Soße, Sirop d'érable, Vegie-spread |
| Confections | 13 | Chocolade, Gumbär Gummibärchen, Maxilaku, NuNuCa Nuß-Nougat-Creme, Pavlova, Schoggi Schokolade, Scottish Longbreads, Sir Rodney's Marmalade, Sir Rodney's Scones, Tarte au sucre, Teatime Chocolate Biscuits, Valkoinen suklaa, Zaanse koeken |
| Dairy Products | 10 | Camembert Pierrot, Flotemysost, Geitost, Gorgonzola Telino, Gudbrandsdalsost, Mascarpone Fabioli, Mozzarella di Giovanni, Queso Cabrales, Queso Manchego La Pastora, Raclette Courdavault |

*(Sample rows are illustrative — the first few rows from the practice dataset, shown to convey shape/format; your data instance may differ.)*

## 2. My Approach

1. Join `categories` to `products` and keep `discontinued = false`.
2. Group by category.
3. `STRING_AGG(product_name, ', ' ORDER BY product_name)` builds the list; `COUNT(*)` counts.
4. Order by `category_name`.

## 3. My Solution (as submitted)

_Not attempted yet._

## 4. Mistakes I Made

_Not attempted yet._

## 5. Correct / Optimal Solution

```sql
SELECT
    c.category_name,
    COUNT(*)                                             AS product_count,
    STRING_AGG(p.product_name, ', ' ORDER BY p.product_name) AS product_list
FROM categories c
JOIN products p ON p.category_id = c.category_id
WHERE p.discontinued = false
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
```

## 6. Why This Works

`STRING_AGG(expr, delimiter ORDER BY ...)` is an aggregate: it collapses each group into one text value. The `ORDER BY` inside the call controls the order of items in the list, independently of the query's outer `ORDER BY`, which controls row order.

## 7. Common Pitfalls (generic)

- Putting the sort only in the outer `ORDER BY` and expecting the list itself to be sorted.
- Using `ARRAY_AGG` when a text value is needed (or vice versa).
- Grouping by name only — two categories with the same name would merge; group by the id as well.

## 8. Interview Follow-ups

**1. How do you remove duplicates from the list?**

`STRING_AGG(DISTINCT product_name, ', ' ORDER BY product_name)` — with `DISTINCT`, the `ORDER BY` expression must be the aggregated expression.

**2. What is the MySQL equivalent?**

`GROUP_CONCAT(product_name ORDER BY product_name SEPARATOR ', ')`.

**3. How do you get an array instead?**

`ARRAY_AGG(product_name ORDER BY product_name)`; `ARRAY_TO_STRING` turns it back into text.

## 9. Key Takeaway

`STRING_AGG(col, sep ORDER BY col)` turns a group into a sorted delimited list — sort inside the aggregate.

---
📄 **SQL File:** [`Q125_Product_List_Per_Category_With_String_Agg.sql`](./Q125_Product_List_Per_Category_With_String_Agg.sql)
