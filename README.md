# Northwind SQL Practice

A structured collection of **88 solved SQL interview-style problems** — plus **45 new practice questions** on window functions, date/time, string functions, CASE/conditional logic and DML/DDL — against the classic **Northwind** sample database, organized by concept and written for **PostgreSQL**.

Each question includes:
- A recruiter-friendly **problem statement** framed as a real business requirement
- A fully documented **SQL solution** with inline reasoning comments
- An explanation of **why** each join, aggregation, subquery, or CTE choice was made
- **Sample output**, **common mistakes**, **interview follow-up questions with full answers**, and **learning outcomes**

This repo is intended as a portfolio artifact demonstrating SQL proficiency across aggregation, grouping, subqueries, CTEs, and outer joins — the core toolkit tested in most data analyst / data engineer SQL interviews.

### Revision format

Every question follows a consistent **revision layout** (see [`STYLE.md`](STYLE.md)). Each `.md`
opens with a **Revision Card** (concepts, difficulty, an outcome flag, and the key trap) and then
separates **My Approach → My Solution → Mistakes I Made → Correct/Optimal Solution** from the
deeper teaching notes — so a quick scan shows what the problem tested and where I slipped up.
The paired `.sql` keeps exactly one runnable query (any buggy first attempt is retained but
commented out).

For fast revision, [`FLASHCARDS.md`](FLASHCARDS.md) collects all 133 questions as collapsible
flashcards (question → answer → mistake → learning), grouped by concept. Every question's
**Interview Follow-ups** section also now ships with full written answers.

---

## 📈 Learning Progress

This repository is being built as part of a structured SQL learning journey using the Northwind database. Topics are completed incrementally, with each section containing business-focused problems, detailed explanations, and PostgreSQL solutions.

### SQL Roadmap Progress

- [x] Aggregations
- [x] GROUP BY & HAVING
- [x] Correlated Subqueries
- [x] Common Table Expressions (CTEs)
- [x] LEFT JOIN
- [x] RIGHT JOIN
- [x] FULL OUTER JOIN
- [x] SELF JOIN
- [x] CROSS JOIN
- [x] Set Operators (UNION / INTERSECT / EXCEPT)
- [ ] Window Functions _(practice set added: Q147–Q158)_
- [ ] Ranking Functions _(covered in the window-function set)_
- [ ] Date & Time Analysis _(practice set added: Q159–Q168)_
- [ ] String Functions _(practice set added: Q169–Q176)_
- [ ] CASE & Conditional Logic _(practice set added: Q177–Q183)_
- [ ] DML & DDL _(practice set added: Q184–Q191)_
- [ ] Advanced Analytics
- [ ] Query Optimization
- [ ] PostgreSQL Advanced Concepts

### Current Status

**Completed: 88 Northwind SQL Problems** across 11 concept areas (aggregation through set operators).

**Up next: 45 new practice questions** (Q147–Q191) on window functions, date/time, string functions, CASE/conditional logic and DML/DDL (88 solved + 45 new). Each has a reference solution; its Revision Card says `🆕 not attempted yet` until I solve it and record my attempt.

> **Note on numbering:** questions are numbered in the order they were solved (Q01 onward), so some numbers are skipped where exploratory problems were later removed or merged. The numbering is a timeline, not a gap-free sequence — each file present is a complete, documented solution.

### Skills Demonstrated

- Data Aggregation and Analysis
- Revenue Analytics
- Customer Analytics
- Product Analytics
- Employee Analytics
- Supplier & Logistics Analytics
- Join Operations (INNER, LEFT, RIGHT, FULL OUTER, SELF, CROSS)
- Subqueries & Correlated Subqueries
- Common Table Expressions (CTEs)
- Set Operators (UNION, UNION ALL, INTERSECT, EXCEPT)
- Two-Level Aggregation Patterns
- NULL Handling & COALESCE
- Business-Oriented SQL Problem Solving

### Next Milestones

1. Complete all JOIN types (RIGHT, FULL OUTER, SELF, CROSS)
2. Master Window Functions
3. Solve Advanced Analytical SQL Problems
4. Build End-to-End SQL Case Studies
5. Perform Query Optimization Exercises
6. Create Business Intelligence Style Reports

This repository will continue to grow as more SQL concepts and real-world business scenarios are explored.

---

## 🗂️ Repository Structure

```
northwind-sql-practice/
│
├── README.md
│
├── 01_Aggregations/                  →  5 problems  (aggregation & revenue analysis)
├── 02_GroupBy_Having/                →  3 problems  (GROUP BY / HAVING filters)
├── 03_Category_Product_Analytics/    →  6 problems  (category & product analytics)
├── 04_Correlated_Subqueries/         →  4 problems  (correlated subqueries)
├── 05_CTE/                           →  6 problems  (common table expressions)
├── 06_Left_Join/                     → 16 problems  (LEFT JOIN & anti-joins)
├── 07_Right_Join/                    → 10 problems  (RIGHT JOIN)
├── 08_Full_Outer_Join/              →  8 problems  (FULL OUTER JOIN)
├── 09_Self_Join/                     → 10 problems  (SELF JOIN)
├── 10_Cross_Join/                    →  8 problems  (CROSS JOIN)
├── 11_Set_Operators/                 → 12 problems  (UNION / INTERSECT / EXCEPT)
├── 12_Window_Functions/              → 12 new       (ROW_NUMBER, RANK, LAG/LEAD, running totals)
├── 13_Date_Time/                     → 10 new       (DATE_TRUNC, EXTRACT, AGE, YoY, cohorts)
├── 14_String_Functions/              →  8 new       (CONCAT, SPLIT_PART, REPLACE, LIKE, STRING_AGG)
├── 15_CASE_Conditional/              →  7 new       (CASE buckets, FILTER, pivot, COALESCE/NULLIF)
├── 16_DML_DDL/                       →  8 new       (INSERT/UPDATE/DELETE RETURNING, UPSERT, CTAS, ALTER)
│
└── Assets/                           → (reserved for ER diagrams / schema images)
```

Query-optimization sections will be added as that roadmap topic is completed.

---

## 🧱 Schema Assumptions

All queries assume the standard Northwind table/column names:

| Table | Key Columns |
|---|---|
| `customers` | `customer_id`, `contact_name`, `company_name` |
| `employees` | `employee_id`, `first_name`, `last_name` |
| `orders` | `order_id`, `customer_id`, `employee_id`, `order_date`, `ship_via`, `shipped_date` |
| `order_details` | `order_id`, `product_id`, `unit_price`, `quantity`, `discount` |
| `products` | `product_id`, `product_name`, `category_id`, `supplier_id`, `unit_price` |
| `categories` | `category_id`, `category_name` |
| `suppliers` | `supplier_id`, `company_name` |
| `shippers` | `shipper_id`, `company_name` |

**Revenue formula used throughout:**
```
revenue = unit_price * quantity * (1 - discount)
```
> `order_details.unit_price` is used — not `products.unit_price` — because it reflects the price at the time of the sale, not the current catalog price.

---

## 📘 Question Index

### 01 — Aggregations & Revenue Analysis

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q01 | Product Revenue | Easy | [📄](01_Aggregations/Q01_Product_Revenue.md) | [🔢](01_Aggregations/Q01_Product_Revenue.sql) |
| Q02 | Category Revenue | Easy | [📄](01_Aggregations/Q02_Category_Revenue.md) | [🔢](01_Aggregations/Q02_Category_Revenue.sql) |
| Q03 | Top 10 Customers by Revenue | Easy | [📄](01_Aggregations/Q03_Top10_Customers_By_Revenue.md) | [🔢](01_Aggregations/Q03_Top10_Customers_By_Revenue.sql) |
| Q04 | Top 5 Employees by Revenue | Easy | [📄](01_Aggregations/Q04_Top5_Employees_By_Revenue.md) | [🔢](01_Aggregations/Q04_Top5_Employees_By_Revenue.sql) |
| Q05 | Top 5 Customers by Number of Orders | Easy | [📄](01_Aggregations/Q05_Top5_Customers_By_Order_Count.md) | [🔢](01_Aggregations/Q05_Top5_Customers_By_Order_Count.sql) |

### 02 — GROUP BY & HAVING

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q06 | Customers Above Average Revenue | Medium | [📄](02_GroupBy_Having/Q06_Customers_Above_Average_Revenue.md) | [🔢](02_GroupBy_Having/Q06_Customers_Above_Average_Revenue.sql) |
| Q07 | Employees Above Average Revenue | Medium | [📄](02_GroupBy_Having/Q07_Employees_Above_Average_Revenue.md) | [🔢](02_GroupBy_Having/Q07_Employees_Above_Average_Revenue.sql) |
| Q08 | Customers Above Average Order Count | Medium | [📄](02_GroupBy_Having/Q08_Customers_Above_Average_Order_Count.md) | [🔢](02_GroupBy_Having/Q08_Customers_Above_Average_Order_Count.sql) |

### 03 — Category & Product Analytics

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q09 | Top Categories by Number of Orders | Medium | [📄](03_Category_Product_Analytics/Q09_Top_Categories_By_Order_Count.md) | [🔢](03_Category_Product_Analytics/Q09_Top_Categories_By_Order_Count.sql) |
| Q10 | Customers Purchasing from Most Categories | Medium | [📄](03_Category_Product_Analytics/Q10_Customers_Purchasing_From_Most_Categories.md) | [🔢](03_Category_Product_Analytics/Q10_Customers_Purchasing_From_Most_Categories.sql) |
| Q11 | Revenue by Shipper | Easy | [📄](03_Category_Product_Analytics/Q11_Revenue_By_Shipper.md) | [🔢](03_Category_Product_Analytics/Q11_Revenue_By_Shipper.sql) |
| Q12 | Employees by Unique Customers Served | Easy | [📄](03_Category_Product_Analytics/Q12_Employees_By_Unique_Customers_Served.md) | [🔢](03_Category_Product_Analytics/Q12_Employees_By_Unique_Customers_Served.sql) |
| Q13 | Products Sold Above Category Average Quantity | Hard | [📄](03_Category_Product_Analytics/Q13_Products_Sold_Above_Category_Average_Quantity.md) | [🔢](03_Category_Product_Analytics/Q13_Products_Sold_Above_Category_Average_Quantity.sql) |
| Q14 | Highest Revenue Product per Category | Hard | [📄](03_Category_Product_Analytics/Q14_Highest_Revenue_Product_Per_Category.md) | [🔢](03_Category_Product_Analytics/Q14_Highest_Revenue_Product_Per_Category.sql) |

### 04 — Correlated Subqueries

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q15 | Customers Above Average Orders (Correlated) | Medium | [📄](04_Correlated_Subqueries/Q15_Customers_Above_Average_Orders_Correlated.md) | [🔢](04_Correlated_Subqueries/Q15_Customers_Above_Average_Orders_Correlated.sql) |
| Q16 | Customers Above Average Revenue (Correlated) | Medium | [📄](04_Correlated_Subqueries/Q16_Customers_Above_Average_Revenue_Correlated.md) | [🔢](04_Correlated_Subqueries/Q16_Customers_Above_Average_Revenue_Correlated.sql) |
| Q17 | Employees Above Average Revenue (Correlated) | Medium | [📄](04_Correlated_Subqueries/Q17_Employees_Above_Average_Revenue_Correlated.md) | [🔢](04_Correlated_Subqueries/Q17_Employees_Above_Average_Revenue_Correlated.sql) |
| Q18 | Customer Revenue Above Employee Average | Hard | [📄](04_Correlated_Subqueries/Q18_Customer_Revenue_Above_Employee_Average.md) | [🔢](04_Correlated_Subqueries/Q18_Customer_Revenue_Above_Employee_Average.sql) |

### 05 — Common Table Expressions (CTEs)

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q19 | Customers Above Average Revenue Using CTE | Medium | [📄](05_CTE/Q19_Customers_Above_Average_Revenue_CTE.md) | [🔢](05_CTE/Q19_Customers_Above_Average_Revenue_CTE.sql) |
| Q20 | Top 5 Customers by Revenue Using CTE | Easy | [📄](05_CTE/Q20_Top5_Customers_By_Revenue_CTE.md) | [🔢](05_CTE/Q20_Top5_Customers_By_Revenue_CTE.sql) |
| Q21 | Employees Above Average Revenue Using Multiple CTEs | Medium | [📄](05_CTE/Q21_Employees_Above_Average_Revenue_Multiple_CTEs.md) | [🔢](05_CTE/Q21_Employees_Above_Average_Revenue_Multiple_CTEs.sql) |
| Q22 | Top Employee by Revenue Using 3 CTEs | Medium | [📄](05_CTE/Q22_Top_Employee_By_Revenue_3_CTEs.md) | [🔢](05_CTE/Q22_Top_Employee_By_Revenue_3_CTEs.sql) |
| Q23 | Best Customer per Employee | Hard | [📄](05_CTE/Q23_Best_Customer_Per_Employee.md) | [🔢](05_CTE/Q23_Best_Customer_Per_Employee.sql) |
| Q24 | Highest Revenue Product per Category (CTE) | Hard | [📄](05_CTE/Q24_Highest_Revenue_Product_Per_Category_CTE.md) | [🔢](05_CTE/Q24_Highest_Revenue_Product_Per_Category_CTE.sql) |

### 06 — LEFT JOIN

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q25 | Customers and Order Count | Medium | [📄](06_Left_Join/Q25_Customers_And_Order_Count.md) | [🔢](06_Left_Join/Q25_Customers_And_Order_Count.sql) |
| Q26 | Customers and Latest Order Date | Medium | [📄](06_Left_Join/Q26_Customers_And_Latest_Order_Date.md) | [🔢](06_Left_Join/Q26_Customers_And_Latest_Order_Date.sql) |
| Q27 | Products and Total Quantity Sold | Medium | [📄](06_Left_Join/Q27_Products_And_Total_Quantity_Sold.md) | [🔢](06_Left_Join/Q27_Products_And_Total_Quantity_Sold.sql) |
| Q28 | Customers with No Orders | Easy | [📄](06_Left_Join/Q28_Customers_With_No_Orders.md) | [🔢](06_Left_Join/Q28_Customers_With_No_Orders.sql) |
| Q29 | Products Never Ordered | Easy | [📄](06_Left_Join/Q29_Products_Never_Ordered.md) | [🔢](06_Left_Join/Q29_Products_Never_Ordered.sql) |
| Q30 | Products Never Ordered (Variant) | Easy | [📄](06_Left_Join/Q30_Products_Never_Ordered.md) | [🔢](06_Left_Join/Q30_Products_Never_Ordered.sql) |
| Q31 | Customers and Total Revenue | Medium | [📄](06_Left_Join/Q31_Customers_And_Total_Revenue.md) | [🔢](06_Left_Join/Q31_Customers_And_Total_Revenue.sql) |
| Q32 | Customers and Distinct Products Purchased | Medium | [📄](06_Left_Join/Q32_Customers_And_Distinct_Products_Purchased.md) | [🔢](06_Left_Join/Q32_Customers_And_Distinct_Products_Purchased.sql) |
| Q33 | Customers and Total Orders Shipped | Medium | [📄](06_Left_Join/Q33_Customers_And_Total_Orders_Shipped.md) | [🔢](06_Left_Join/Q33_Customers_And_Total_Orders_Shipped.sql) |
| Q34 | Employees and Customers Served | Medium | [📄](06_Left_Join/Q34_Employees_And_Customers_Served.md) | [🔢](06_Left_Join/Q34_Employees_And_Customers_Served.sql) |
| Q35 | Categories and Number of Products | Easy | [📄](06_Left_Join/Q35_Categories_And_Number_Of_Products.md) | [🔢](06_Left_Join/Q35_Categories_And_Number_Of_Products.sql) |
| Q36 | Suppliers and Number of Products | Easy | [📄](06_Left_Join/Q36_Suppliers_And_Number_Of_Products.md) | [🔢](06_Left_Join/Q36_Suppliers_And_Number_Of_Products.sql) |
| Q37 | Employees and Total Revenue Generated | Medium | [📄](06_Left_Join/Q37_Employees_And_Total_Revenue_Generated.md) | [🔢](06_Left_Join/Q37_Employees_And_Total_Revenue_Generated.sql) |
| Q38 | Shippers and Total Orders Handled | Easy | [📄](06_Left_Join/Q38_Shippers_And_Total_Orders_Handled.md) | [🔢](06_Left_Join/Q38_Shippers_And_Total_Orders_Handled.sql) |
| Q39 | Categories and Total Revenue | Medium | [📄](06_Left_Join/Q39_Categories_And_Total_Revenue.md) | [🔢](06_Left_Join/Q39_Categories_And_Total_Revenue.sql) |
| Q40 | Customers and Average Order Value | Hard | [📄](06_Left_Join/Q40_Customers_And_Average_Order_Value.md) | [🔢](06_Left_Join/Q40_Customers_And_Average_Order_Value.sql) |

### 07 — RIGHT JOIN

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q41 | Customers and Orders | Easy | [📄](07_Right_Join/Q41_Customers_And_Orders.md) | [🔢](07_Right_Join/Q41_Customers_And_Orders.sql) |
| Q42 | Products and Suppliers | Easy | [📄](07_Right_Join/Q42_Products_And_Suppliers.md) | [🔢](07_Right_Join/Q42_Products_And_Suppliers.sql) |
| Q43 | Employees and Orders | Easy | [📄](07_Right_Join/Q43_Employees_And_Orders.md) | [🔢](07_Right_Join/Q43_Employees_And_Orders.sql) |
| Q44 | Products and Total Quantity Sold | Medium | [📄](07_Right_Join/Q44_Products_And_Total_Quantity_Sold.md) | [🔢](07_Right_Join/Q44_Products_And_Total_Quantity_Sold.sql) |
| Q45 | Customers and Total Revenue | Medium | [📄](07_Right_Join/Q45_Customers_And_Total_Revenue.md) | [🔢](07_Right_Join/Q45_Customers_And_Total_Revenue.sql) |
| Q46 | Employees and Total Orders | Medium | [📄](07_Right_Join/Q46_Employees_And_Total_Orders.md) | [🔢](07_Right_Join/Q46_Employees_And_Total_Orders.sql) |
| Q47 | Categories and Products | Easy | [📄](07_Right_Join/Q47_Categories_And_Products.md) | [🔢](07_Right_Join/Q47_Categories_And_Products.sql) |
| Q48 | Suppliers and Total Revenue | Medium | [📄](07_Right_Join/Q48_Suppliers_And_Total_Revenue.md) | [🔢](07_Right_Join/Q48_Suppliers_And_Total_Revenue.sql) |
| Q49 | Customers and Average Order Value (RIGHT JOIN) | Hard | [📄](07_Right_Join/Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.md) | [🔢](07_Right_Join/Q49_Customers_And_Average_Order_Value_RIGHT_JOIN.sql) |
| Q50 | Top Customer(s) by Revenue — Tie-Safe | Hard | [📄](07_Right_Join/Q50_Top_Customer_By_Revenue_Tie_Safe.md) | [🔢](07_Right_Join/Q50_Top_Customer_By_Revenue_Tie_Safe.sql) |

### 08 — FULL OUTER JOIN

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q51 | Customers and Orders | Medium | [📄](08_Full_Outer_Join/Q51_Customers_And_Orders_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q51_Customers_And_Orders_FULL_OUTER_JOIN.sql) |
| Q52 | Products and Categories | Medium | [📄](08_Full_Outer_Join/Q52_Products_And_Categories_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q52_Products_And_Categories_FULL_OUTER_JOIN.sql) |
| Q53 | Employees and Orders | Medium | [📄](08_Full_Outer_Join/Q53_Employees_And_Orders_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q53_Employees_And_Orders_FULL_OUTER_JOIN.sql) |
| Q54 | Suppliers and Products | Medium | [📄](08_Full_Outer_Join/Q54_Suppliers_And_Products_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q54_Suppliers_And_Products_FULL_OUTER_JOIN.sql) |
| Q55 | Customers and Total Orders | Hard | [📄](08_Full_Outer_Join/Q55_Customers_And_Total_Orders_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q55_Customers_And_Total_Orders_FULL_OUTER_JOIN.sql) |
| Q56 | Products and Total Revenue | Hard | [📄](08_Full_Outer_Join/Q56_Products_And_Total_Revenue_FULL_OUTER_JOIN.md) | [🔢](08_Full_Outer_Join/Q56_Products_And_Total_Revenue_FULL_OUTER_JOIN.sql) |
| Q57 | Employees and Total Revenue | Medium | [📄](08_Full_Outer_Join/Q57_Employees_And_Total_Revenue.md) | [🔢](08_Full_Outer_Join/Q57_Employees_And_Total_Revenue.sql) |
| Q58 | Customer Revenue Comparison (Advanced) | Hard | [📄](08_Full_Outer_Join/Q58_Customer_Revenue_Comparison_Advanced.md) | [🔢](08_Full_Outer_Join/Q58_Customer_Revenue_Comparison_Advanced.sql) |

### 09 — SELF JOIN

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q61 | Employees Without a Manager | Easy | [📄](09_Self_Join/Q61_Employees_Without_a_Manager.md) | [🔢](09_Self_Join/Q61_Employees_Without_a_Manager.sql) |
| Q62 | Employees Who Are Managers | Medium | [📄](09_Self_Join/Q62_Employees_Who_Are_Managers.md) | [🔢](09_Self_Join/Q62_Employees_Who_Are_Managers.sql) |
| Q63 | Employees Reporting to the Same Manager | Medium | [📄](09_Self_Join/Q63_Employees_Reporting_to_the_Same_Manager.md) | [🔢](09_Self_Join/Q63_Employees_Reporting_to_the_Same_Manager.sql) |
| Q64 | Employees Having the Same Job Title | Easy | [📄](09_Self_Join/Q64_Employees_Having_the_Same_Job_Title.md) | [🔢](09_Self_Join/Q64_Employees_Having_the_Same_Job_Title.sql) |
| Q65 | Employees Hired in the Same Year | Easy | [📄](09_Self_Join/Q65_Employees_Hired_in_the_Same_Year.md) | [🔢](09_Self_Join/Q65_Employees_Hired_in_the_Same_Year.sql) |
| Q66 | Customers from the Same Country | Easy | [📄](09_Self_Join/Q66_Customers_from_the_Same_Country.md) | [🔢](09_Self_Join/Q66_Customers_from_the_Same_Country.sql) |
| Q67 | Customers from the Same City | Easy | [📄](09_Self_Join/Q67_Customers_from_the_Same_City.md) | [🔢](09_Self_Join/Q67_Customers_from_the_Same_City.sql) |
| Q68 | Products with the Same Supplier | Easy | [📄](09_Self_Join/Q68_Products_with_the_Same_Supplier.md) | [🔢](09_Self_Join/Q68_Products_with_the_Same_Supplier.sql) |
| Q69 | Products in the Same Category | Easy | [📄](09_Self_Join/Q69_Products_in_the_Same_Category.md) | [🔢](09_Self_Join/Q69_Products_in_the_Same_Category.sql) |
| Q70 | Customers Sharing the Same Postal Code | Easy | [📄](09_Self_Join/Q70_Customers_Sharing_the_Same_Postal_Code.md) | [🔢](09_Self_Join/Q70_Customers_Sharing_the_Same_Postal_Code.sql) |

### 10 — CROSS JOIN

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q71 | Employee–Category Combinations | Easy | [📄](10_Cross_Join/Q71_Employee-Category_Combinations.md) | [🔢](10_Cross_Join/Q71_Employee-Category_Combinations.sql) |
| Q72 | Product–Shipper Combinations | Easy | [📄](10_Cross_Join/Q72_Product-Shipper_Combinations.md) | [🔢](10_Cross_Join/Q72_Product-Shipper_Combinations.sql) |
| Q73 | Supplier–Category Combinations | Easy | [📄](10_Cross_Join/Q73_Supplier-Category_Combinations.md) | [🔢](10_Cross_Join/Q73_Supplier-Category_Combinations.sql) |
| Q74 | Customer–Supplier Combinations | Easy | [📄](10_Cross_Join/Q74_Customer-Supplier_Combinations.md) | [🔢](10_Cross_Join/Q74_Customer-Supplier_Combinations.sql) |
| Q75 | Employee–Shipper Combinations | Easy | [📄](10_Cross_Join/Q75_Employee-Shipper_Combinations.md) | [🔢](10_Cross_Join/Q75_Employee-Shipper_Combinations.sql) |
| Q76 | Customer–Category Combinations | Easy | [📄](10_Cross_Join/Q76_Customer-Category_Combinations.md) | [🔢](10_Cross_Join/Q76_Customer-Category_Combinations.sql) |
| Q77 | Product–Employee Combinations | Easy | [📄](10_Cross_Join/Q77_Product-Employee_Combinations.md) | [🔢](10_Cross_Join/Q77_Product-Employee_Combinations.sql) |
| Q78 | Supplier–Shipper Combinations | Easy | [📄](10_Cross_Join/Q78_Supplier-Shipper_Combinations.md) | [🔢](10_Cross_Join/Q78_Supplier-Shipper_Combinations.sql) |

### 11 — Set Operators (UNION / INTERSECT / EXCEPT)

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q79 | Customer and Supplier Contact Directory | Easy | [📄](11_Set_Operators/Q79_Customer_And_Supplier_Contact_Directory.md) | [🔢](11_Set_Operators/Q79_Customer_And_Supplier_Contact_Directory.sql) |
| Q80 | Product and Category Name List | Easy | [📄](11_Set_Operators/Q80_Product_And_Category_Name_List.md) | [🔢](11_Set_Operators/Q80_Product_And_Category_Name_List.sql) |
| Q81 | Company Name Directory | Easy | [📄](11_Set_Operators/Q81_Company_Name_Directory.md) | [🔢](11_Set_Operators/Q81_Company_Name_Directory.sql) |
| Q82 | Contact Directory with Type Label | Medium | [📄](11_Set_Operators/Q82_Contact_Directory_With_Type_Label.md) | [🔢](11_Set_Operators/Q82_Contact_Directory_With_Type_Label.sql) |
| Q83 | Master Contact Directory | Medium | [📄](11_Set_Operators/Q83_Master_Contact_Directory.md) | [🔢](11_Set_Operators/Q83_Master_Contact_Directory.sql) |
| Q84 | Master Company Directory | Medium | [📄](11_Set_Operators/Q84_Master_Company_Directory.md) | [🔢](11_Set_Operators/Q84_Master_Company_Directory.sql) |
| Q85 | Master Location Directory | Medium | [📄](11_Set_Operators/Q85_Master_Location_Directory.md) | [🔢](11_Set_Operators/Q85_Master_Location_Directory.sql) |
| Q86 | Entity Record Count Summary | Hard | [📄](11_Set_Operators/Q86_Entity_Record_Count_Summary.md) | [🔢](11_Set_Operators/Q86_Entity_Record_Count_Summary.sql) |
| Q92 | Countries with More Customers Than Employees and Suppliers | Hard | [📄](11_Set_Operators/Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.md) | [🔢](11_Set_Operators/Q92_Countries_with_More_Customers_Than_Employees_and_Suppliers.sql) |
| Q93 | Countries with Balanced Business Entities | Advanced | [📄](11_Set_Operators/Q93_Countries_with_Balanced_Business_Entities.md) | [🔢](11_Set_Operators/Q93_Countries_with_Balanced_Business_Entities.sql) |
| Q96 | Countries with the Highest Customer Count Above the Overall Average | Expert | [📄](11_Set_Operators/Q96_Countries_with_the_Highest_Customer_Count_Above_the_Overall_Average.md) | [🔢](11_Set_Operators/Q96_Countries_with_the_Highest_Customer_Count_Above_the_Overall_Average.sql) |
| Q97 | Countries with More Customers Than Their Entity Average | Expert | [📄](11_Set_Operators/Q97_Countries_with_More_Customers_Than_Their_Entity_Average.md) | [🔢](11_Set_Operators/Q97_Countries_with_More_Customers_Than_Their_Entity_Average.sql) |

> **Numbering note:** questions are numbered in solving order, so a few numbers (Q59–Q60, Q87–Q91, Q94–Q95) are skipped where exploratory problems were later merged or removed. Every file present is a complete, documented solution.

### 12 — Window Functions _(new practice set — not yet attempted)_

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q147 | Latest Order Per Customer | Easy | [📄](12_Window_Functions/Q147_Latest_Order_Per_Customer.md) | [🔢](12_Window_Functions/Q147_Latest_Order_Per_Customer.sql) |
| Q148 | Rank Vs Dense Rank Product Prices | Easy | [📄](12_Window_Functions/Q148_Rank_Vs_Dense_Rank_Product_Prices.md) | [🔢](12_Window_Functions/Q148_Rank_Vs_Dense_Rank_Product_Prices.sql) |
| Q149 | Top 3 Products By Revenue Per Category | Medium | [📄](12_Window_Functions/Q149_Top_3_Products_By_Revenue_Per_Category.md) | [🔢](12_Window_Functions/Q149_Top_3_Products_By_Revenue_Per_Category.sql) |
| Q150 | Running Total Of Monthly Revenue | Easy | [📄](12_Window_Functions/Q150_Running_Total_Of_Monthly_Revenue.md) | [🔢](12_Window_Functions/Q150_Running_Total_Of_Monthly_Revenue.sql) |
| Q151 | Three Month Moving Average Revenue | Medium | [📄](12_Window_Functions/Q151_Three_Month_Moving_Average_Revenue.md) | [🔢](12_Window_Functions/Q151_Three_Month_Moving_Average_Revenue.sql) |
| Q152 | Month Over Month Revenue Change | Medium | [📄](12_Window_Functions/Q152_Month_Over_Month_Revenue_Change.md) | [🔢](12_Window_Functions/Q152_Month_Over_Month_Revenue_Change.sql) |
| Q153 | Days Until Next Customer Order | Medium | [📄](12_Window_Functions/Q153_Days_Until_Next_Customer_Order.md) | [🔢](12_Window_Functions/Q153_Days_Until_Next_Customer_Order.sql) |
| Q154 | Customer Share Of Total Revenue | Medium | [📄](12_Window_Functions/Q154_Customer_Share_Of_Total_Revenue.md) | [🔢](12_Window_Functions/Q154_Customer_Share_Of_Total_Revenue.sql) |
| Q155 | Customer Revenue Quartiles | Medium | [📄](12_Window_Functions/Q155_Customer_Revenue_Quartiles.md) | [🔢](12_Window_Functions/Q155_Customer_Revenue_Quartiles.sql) |
| Q156 | First And Latest Product Per Customer | Hard | [📄](12_Window_Functions/Q156_First_And_Latest_Product_Per_Customer.md) | [🔢](12_Window_Functions/Q156_First_And_Latest_Product_Per_Customer.sql) |
| Q157 | Employee Revenue Percentile Rank | Hard | [📄](12_Window_Functions/Q157_Employee_Revenue_Percentile_Rank.md) | [🔢](12_Window_Functions/Q157_Employee_Revenue_Percentile_Rank.sql) |
| Q158 | Average Gap Between Employee Orders | Hard | [📄](12_Window_Functions/Q158_Average_Gap_Between_Employee_Orders.md) | [🔢](12_Window_Functions/Q158_Average_Gap_Between_Employee_Orders.sql) |

### 13 — Date & Time _(new practice set — not yet attempted)_

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q159 | Orders Per Year And Month | Easy | [📄](13_Date_Time/Q159_Orders_Per_Year_And_Month.md) | [🔢](13_Date_Time/Q159_Orders_Per_Year_And_Month.sql) |
| Q160 | Revenue By Quarter | Easy | [📄](13_Date_Time/Q160_Revenue_By_Quarter.md) | [🔢](13_Date_Time/Q160_Revenue_By_Quarter.sql) |
| Q161 | Late Shipments With Days Late | Easy | [📄](13_Date_Time/Q161_Late_Shipments_With_Days_Late.md) | [🔢](13_Date_Time/Q161_Late_Shipments_With_Days_Late.sql) |
| Q162 | Average Days To Ship Per Shipper | Medium | [📄](13_Date_Time/Q162_Average_Days_To_Ship_Per_Shipper.md) | [🔢](13_Date_Time/Q162_Average_Days_To_Ship_Per_Shipper.sql) |
| Q163 | Unshipped Orders Older Than 30 Days | Medium | [📄](13_Date_Time/Q163_Unshipped_Orders_Older_Than_30_Days.md) | [🔢](13_Date_Time/Q163_Unshipped_Orders_Older_Than_30_Days.sql) |
| Q164 | Employee Age At Hire And Tenure | Medium | [📄](13_Date_Time/Q164_Employee_Age_At_Hire_And_Tenure.md) | [🔢](13_Date_Time/Q164_Employee_Age_At_Hire_And_Tenure.sql) |
| Q165 | Orders By Day Of Week | Medium | [📄](13_Date_Time/Q165_Orders_By_Day_Of_Week.md) | [🔢](13_Date_Time/Q165_Orders_By_Day_Of_Week.sql) |
| Q166 | Year Over Year Revenue Growth | Hard | [📄](13_Date_Time/Q166_Year_Over_Year_Revenue_Growth.md) | [🔢](13_Date_Time/Q166_Year_Over_Year_Revenue_Growth.sql) |
| Q167 | Customers Inactive In Last Six Months | Hard | [📄](13_Date_Time/Q167_Customers_Inactive_In_Last_Six_Months.md) | [🔢](13_Date_Time/Q167_Customers_Inactive_In_Last_Six_Months.sql) |
| Q168 | First Order Month Cohort Size | Hard | [📄](13_Date_Time/Q168_First_Order_Month_Cohort_Size.md) | [🔢](13_Date_Time/Q168_First_Order_Month_Cohort_Size.sql) |

### 14 — String Functions _(new practice set — not yet attempted)_

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q169 | Employee Full Name And Initials | Easy | [📄](14_String_Functions/Q169_Employee_Full_Name_And_Initials.md) | [🔢](14_String_Functions/Q169_Employee_Full_Name_And_Initials.sql) |
| Q170 | Customers Matching Name Patterns | Easy | [📄](14_String_Functions/Q170_Customers_Matching_Name_Patterns.md) | [🔢](14_String_Functions/Q170_Customers_Matching_Name_Patterns.sql) |
| Q171 | Longest Product Names | Easy | [📄](14_String_Functions/Q171_Longest_Product_Names.md) | [🔢](14_String_Functions/Q171_Longest_Product_Names.sql) |
| Q172 | Split Contact Name Into First And Last | Medium | [📄](14_String_Functions/Q172_Split_Contact_Name_Into_First_And_Last.md) | [🔢](14_String_Functions/Q172_Split_Contact_Name_Into_First_And_Last.sql) |
| Q173 | Normalize Postal Codes With Replace | Medium | [📄](14_String_Functions/Q173_Normalize_Postal_Codes_With_Replace.md) | [🔢](14_String_Functions/Q173_Normalize_Postal_Codes_With_Replace.sql) |
| Q174 | Product List Per Category With String Agg | Medium | [📄](14_String_Functions/Q174_Product_List_Per_Category_With_String_Agg.md) | [🔢](14_String_Functions/Q174_Product_List_Per_Category_With_String_Agg.sql) |
| Q175 | Parse Category Description Keywords | Hard | [📄](14_String_Functions/Q175_Parse_Category_Description_Keywords.md) | [🔢](14_String_Functions/Q175_Parse_Category_Description_Keywords.sql) |
| Q176 | Customer Cities Per Country With Distinct String Agg | Hard | [📄](14_String_Functions/Q176_Customer_Cities_Per_Country_With_Distinct_String_Agg.md) | [🔢](14_String_Functions/Q176_Customer_Cities_Per_Country_With_Distinct_String_Agg.sql) |

### 15 — CASE & Conditional Logic _(new practice set — not yet attempted)_

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q177 | Product Price Bands | Easy | [📄](15_CASE_Conditional/Q177_Product_Price_Bands.md) | [🔢](15_CASE_Conditional/Q177_Product_Price_Bands.sql) |
| Q178 | Product Count And Average Price Per Band | Easy | [📄](15_CASE_Conditional/Q178_Product_Count_And_Average_Price_Per_Band.md) | [🔢](15_CASE_Conditional/Q178_Product_Count_And_Average_Price_Per_Band.sql) |
| Q179 | Employee Shipping Status Counts | Medium | [📄](15_CASE_Conditional/Q179_Employee_Shipping_Status_Counts.md) | [🔢](15_CASE_Conditional/Q179_Employee_Shipping_Status_Counts.sql) |
| Q180 | Pivot Category Revenue By Year | Medium | [📄](15_CASE_Conditional/Q180_Pivot_Category_Revenue_By_Year.md) | [🔢](15_CASE_Conditional/Q180_Pivot_Category_Revenue_By_Year.sql) |
| Q181 | Custom Country Sort Order With CASE | Medium | [📄](15_CASE_Conditional/Q181_Custom_Country_Sort_Order_With_CASE.md) | [🔢](15_CASE_Conditional/Q181_Custom_Country_Sort_Order_With_CASE.sql) |
| Q182 | Average Order Value With NULLIF And COALESCE | Medium | [📄](15_CASE_Conditional/Q182_Average_Order_Value_With_NULLIF_And_COALESCE.md) | [🔢](15_CASE_Conditional/Q182_Average_Order_Value_With_NULLIF_And_COALESCE.sql) |
| Q183 | Customer Value Segment Summary | Hard | [📄](15_CASE_Conditional/Q183_Customer_Value_Segment_Summary.md) | [🔢](15_CASE_Conditional/Q183_Customer_Value_Segment_Summary.sql) |

### 16 — DML & DDL _(new practice set — not yet attempted)_

| # | Question | Difficulty | MD | SQL |
|---|---|---|---|---|
| Q184 | Insert New Shipper With Returning | Easy | [📄](16_DML_DDL/Q184_Insert_New_Shipper_With_Returning.md) | [🔢](16_DML_DDL/Q184_Insert_New_Shipper_With_Returning.sql) |
| Q185 | Raise Prices For One Supplier | Easy | [📄](16_DML_DDL/Q185_Raise_Prices_For_One_Supplier.md) | [🔢](16_DML_DDL/Q185_Raise_Prices_For_One_Supplier.sql) |
| Q186 | Update Prices Using A Join With FROM | Medium | [📄](16_DML_DDL/Q186_Update_Prices_Using_A_Join_With_FROM.md) | [🔢](16_DML_DDL/Q186_Update_Prices_Using_A_Join_With_FROM.sql) |
| Q187 | Delete Small Order Lines With Returning | Medium | [📄](16_DML_DDL/Q187_Delete_Small_Order_Lines_With_Returning.md) | [🔢](16_DML_DDL/Q187_Delete_Small_Order_Lines_With_Returning.sql) |
| Q188 | Upsert Customers With On Conflict | Hard | [📄](16_DML_DDL/Q188_Upsert_Customers_With_On_Conflict.md) | [🔢](16_DML_DDL/Q188_Upsert_Customers_With_On_Conflict.sql) |
| Q189 | Create Order And Lines With Chained CTE Inserts | Hard | [📄](16_DML_DDL/Q189_Create_Order_And_Lines_With_Chained_CTE_Inserts.md) | [🔢](16_DML_DDL/Q189_Create_Order_And_Lines_With_Chained_CTE_Inserts.sql) |
| Q190 | Create Customer Revenue Summary Table As Select | Medium | [📄](16_DML_DDL/Q190_Create_Customer_Revenue_Summary_Table_As_Select.md) | [🔢](16_DML_DDL/Q190_Create_Customer_Revenue_Summary_Table_As_Select.sql) |
| Q191 | Add Column And Check Constraint To Products | Hard | [📄](16_DML_DDL/Q191_Add_Column_And_Check_Constraint_To_Products.md) | [🔢](16_DML_DDL/Q191_Add_Column_And_Check_Constraint_To_Products.sql) |

---

## 🎯 Key SQL Patterns Covered

| Pattern | Questions |
|---|---|
| `LEFT JOIN ... WHERE x.col IS NULL` (anti-join) | Q28, Q29, Q30 |
| `COUNT(column)` vs `COUNT(*)` over outer joins | Q25, Q33, Q35, Q36, Q38 |
| `COALESCE` for NULL-to-zero on `SUM()` | Q27, Q31, Q37, Q39 |
| Chained `LEFT JOIN` — all links must stay `LEFT` | Q31, Q32, Q33, Q37, Q39, Q40 |
| Two-level aggregation via CTE (aggregate then aggregate again) | Q13, Q40 |
| CTE + scalar subquery for "above average" comparisons | Q06–Q08, Q19–Q21 |
| Correlated subquery for "above this group's own average" | Q18 |
| `RANK()` with `PARTITION BY` for top-N-per-group with tie handling | Q14, Q23, Q24 |
| `COUNT(DISTINCT ...)` for breadth vs volume metrics | Q09, Q10, Q12, Q32, Q34 |
| `CONCAT()` vs `\|\|` for NULL-safe name concatenation | Q34, Q37 |
| `JOIN ... ON` with inequality conditions | Q21 |
| `NULLS LAST` in `ORDER BY` for correct NULL sort position | Q26 |
| `RIGHT JOIN` to preserve the right-hand table (direction vs table order) | Q41–Q50 |
| `FULL OUTER JOIN` to keep unmatched rows from both sides | Q51–Q58 |
| Self-join pair pattern `t1.id < t2.id AND t1.key = t2.key` (dedup pairs) | Q63, Q66–Q70 |
| Self-join on hierarchy (`employee.reports_to = manager.employee_id`) | Q61–Q63 |
| `CROSS JOIN` for exhaustive combinations (Cartesian product) | Q71–Q78 |
| `UNION` vs `UNION ALL` (dedup vs keep-all; column count/type/order rules) | Q79–Q85 |
| Literal type-label columns in a UNION directory (`'Customer'`, …) | Q82–Q85 |
| `UNION ALL` + `GROUP BY` in a CTE for multi-entity counts | Q86 |
| `INTERSECT` / `EXCEPT` and set-based "above average" comparisons | Q92, Q93, Q96, Q97 |
| `|| ` vs `CONCAT()` NULL propagation in outer joins | Q57 |
| `ROW_NUMBER()` / `RANK()` / `DENSE_RANK()` for latest-per-group and top-N-per-group | Q147–Q149 |
| Running totals and moving averages with `SUM`/`AVG() OVER (ORDER BY …)` | Q150, Q151 |
| `LAG` / `LEAD` for period-over-period change and gaps | Q152, Q153, Q158 |
| Share of total with `SUM() OVER ()`; `NTILE`, `PERCENT_RANK`, `CUME_DIST` | Q154, Q155, Q157 |
| `DATE_TRUNC` / `EXTRACT` bucketing, date differences, `AGE` | Q159–Q165 |
| Year-over-year growth, inactivity windows and cohorts | Q166–Q168 |
| String functions: `||`/`CONCAT`, `SPLIT_PART`, `POSITION`, `REPLACE`, `LIKE`/`ILIKE`, `STRING_AGG` | Q169–Q176 |
| `CASE` bucketing, conditional aggregation (`FILTER`), pivots, `CASE` in `ORDER BY`, `COALESCE`/`NULLIF` | Q177–Q183 |
| DML with `RETURNING`, `UPDATE ... FROM`, `ON CONFLICT` upsert, data-modifying CTEs, CTAS, `ALTER TABLE` constraints | Q184–Q191 |

---

## 🧠 Why This Project

This repository was built to demonstrate not just *that* a query produces the right answer, but *why* a particular join type, aggregation strategy, or subquery pattern was the correct technical choice — the kind of reasoning expected in real SQL technical interviews.

Each question pairs a working solution with:
- The underlying decision-making behind every structural choice
- Common pitfalls and exactly why they fail
- The follow-up questions an interviewer is likely to ask — with full answers
- Learning outcomes that frame the transferable skill, not just the specific query

---

## 🛠️ How to Use

1. Load the Northwind sample database into a local PostgreSQL instance.
2. Open any `.sql` file directly — each is self-contained with a full header comment covering the business context, approach, and expected output.
3. Read the matching `.md` file for the full breakdown: problem framing, reasoning, sample output, wrong approaches (where applicable), and interview Q&A.

---

## 📄 License

Free to use and adapt for personal learning, portfolio, or interview-preparation purposes.
