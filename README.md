# Northwind SQL Practice

A structured collection of 40 SQL interview-style practice problems solved against the classic **Northwind** sample database, organized by concept and written for **PostgreSQL**.

Each question includes:
- A recruiter-friendly **problem statement** framed as a real business requirement
- A fully documented **SQL solution** with inline reasoning comments
- An explanation of **why** each join, aggregation, subquery, or CTE choice was made
- **Sample output**, **common mistakes**, **interview follow-up questions with full answers**, and **learning outcomes**

This repo is intended as a portfolio artifact demonstrating SQL proficiency across aggregation, grouping, subqueries, CTEs, and outer joins — the core toolkit tested in most data analyst / data engineer SQL interviews.

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
- [ ] FULL OUTER JOIN
- [ ] SELF JOIN
- [ ] CROSS JOIN
- [ ] Window Functions
- [ ] Ranking Functions
- [ ] Advanced Analytics
- [ ] Query Optimization
- [ ] PostgreSQL Advanced Concepts

### Current Status

**Completed: 40 Northwind SQL Problems**

### Skills Demonstrated

- Data Aggregation and Analysis
- Revenue Analytics
- Customer Analytics
- Product Analytics
- Employee Analytics
- Supplier & Logistics Analytics
- Join Operations (INNER, LEFT)
- Subqueries & Correlated Subqueries
- Common Table Expressions (CTEs)
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
├── 01_Aggregations/                  → Q01–Q05
├── 02_GroupBy_Having/                → Q06–Q08
├── 03_Category_Product_Analytics/    → Q09–Q14
├── 04_Correlated_Subqueries/         → Q15–Q18
├── 05_CTE/                           → Q19–Q24
├── 06_Left_Join/                     → Q25–Q40
│
├── 07_Right_Join/                    → planned
├── 08_Full_Outer_Join/               → planned
├── 09_Self_Join/                     → planned
├── 10_Cross_Join/                    → planned
├── 11_Window_Functions/              → planned
├── 12_Ranking_Functions/             → planned
├── 13_Advanced_Analytics/            → planned
├── 14_Query_Optimization/            → planned
│
└── Assets/                           → (reserved for ER diagrams / schema images)
```

Folders 07–14 will be added as those roadmap topics are completed.

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
