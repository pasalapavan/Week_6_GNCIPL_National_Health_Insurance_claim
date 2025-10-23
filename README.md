# 🩺 National Health Insurance Claims (NHIC) — SQL Project

## 📖 Introduction
The **National Health Insurance Claims (NHIC)** project demonstrates how SQL can be used to manage, clean, and analyze healthcare insurance data effectively.  
This project focuses on transforming raw insurance claim records into structured, meaningful insights through data modeling, cleaning, and analysis using **PostgreSQL**.  

The goal is to understand claim patterns, payment behaviors, and health-related trends such as **BMI**, **smoking habits**, and **regional variations** in insurance claims.

---

## 🧩 Project Structure

| File | Description |
|------|--------------|
| **`nhic.sql`** | Contains all SQL queries — table creation, joins, cleaning, transformations, and analysis. |
| **`report.docx`** | A detailed documentation report explaining the SQL workflow and steps involved. |

---

## 🧱 Database Design

### Tables Created
1. **insurance_claims** – Contains patient claim details (age, BMI, smoker status, bill amount, claim dates, etc.)
2. **patient_details** – Stores patient information such as full name, number of children, and age.
3. **regions** – Maps regional names with region codes.
4. **nhic** – Final merged table combining all three tables using SQL joins.

---

## 🧼 Data Cleaning Steps
- Removed null and duplicate values.
- Trimmed extra spaces in text fields.
- Removed special characters using `REGEXP_REPLACE`.
- Added new computed columns:
  - `amount_paid` = `bill_amount - claimed_amount`
  - `duration` = `insurance_claimed_date - insurance_apply_date`
  - `year_billing` = year extracted from `insurance_apply_date`

---

## 📊 Data Analysis
Key analytical insights were derived using SQL:
- **Region-wise claim percentages**
- **BMI and smoking status vs. claim likelihood**
- **Claim duration and billing year trends**

Example analytical query:
```sql
SELECT 
    region,
    ROUND(
        SUM(CASE WHEN insuranceclaim = 1 THEN 1 ELSE 0 END)::decimal * 100 / COUNT(*), 2
    ) AS claimed_percentage
FROM nhic
GROUP BY region
ORDER BY region;



💾 Output

The final cleaned and combined dataset was exported as:

nhic.csv


This CSV file can be used for further data visualization or predictive modeling in tools like Python, Power BI, or Tableau.

🛠️ Tools & Technologies

PostgreSQL

SQL

Excel / CSV

Microsoft Word (for documentation)

🧠 Key Learnings

Importance of relational database design and normalization.

Hands-on experience with SQL joins, subqueries, and window functions.

Effective data cleaning and transformation techniques.

Analytical SQL for real-world datasets.

📁 Author

Pavan Pasala
📧 pasalapavan28@gmail.com

🔗 LinkedIn
 (Add your link here)

🏁 Conclusion

This project showcases how SQL can be a powerful tool in data preprocessing and analysis, especially in domains like healthcare insurance where data quality and relational design are crucial.
Through systematic cleaning, joining, and analysis, the NHIC project transforms raw claim data into actionable insights for better decision-making.
