-- dropping the table if exists insurance details 
drop table if exists insurance_claims;
-- Tell PostgreSQL to interpret dates as Day-Month-Year
SET datestyle = dmy;

-- -- creating a table name insurance_claims
create table insurance_claims(
	patient_id int primary key,
	age numeric,
	sex numeric,
	bmi numeric,
	smoker numeric,
	region_code numeric,
	bill_amount numeric(10, 2),
	insuranceclaim numeric(10, 2), 
	insurance_apply_date date,
	insurance_claimed_date date,
	claimed_amount numeric(10, 2)
);

-- displaying the table
select * from insurance_claims;

-- no of rows
SELECT COUNT(*) AS total_rows
FROM insurance_claims;

-- no of columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'insurance_claims';

-- describe
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'insurance_claims';


-- creating patient table
create table patient_details (
	patient_id numeric primary key,
	full_name varchar(50),
	children numeric,
	age numeric
);

-- retrieving the data of patient_details table
select * from patient_details;


-- describe
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'patient_details';

-- no of rows
SELECT COUNT(*) AS total_rows
FROM patient_details;

-- no of columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'patient_details';



-- create a table of regions
create table regions (
	region varchar(20),
	region_code numeric
);


-- retrieving the data of regions table
select * from regions;

-- describe
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'regions';

-- no of rows
SELECT COUNT(*) AS total_rows
FROM regions;

-- no of columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'regions';

drop table if exists nhic;
-- combining all the table using joins into one table as nhic
create table nhic as (
select p.patient_id, p.full_name, p.age, p.children, i.sex, r.region_code, r.region, i.bmi, i.smoker, i.bill_amount, i.insuranceclaim,i.insurance_apply_date, i.insurance_claimed_date, i.claimed_amount
from insurance_claims i
join patient_details p
on i.patient_id = p.patient_id
left join regions r
on r.region_code = i.region_code
);

-- retrieving data
select * from nhic;


-- add a column amount paid
alter table nhic
add column amount_paid numeric(10, 2);

-- storing values in that column
update nhic 
set amount_paid = bill_amount - claimed_amount;


-- add a column Durati
alter table nhic 
add column duration numeric;

update nhic 
set duration = insurance_claimed_date - insurance_apply_date;

-- check for null values
select
	count(*) filter(where patient_id is null) as patient_id, 
	count(*) filter(where full_name is null) as full_name,
	count(*) filter(where age is null) as age,
	count(*) filter(where children is null) as children,
	count(*) filter(where sex is null) as sex,
	count(*) filter(where region_code is null) as region_code,
	count(*) filter(where region is null) as region,
	count(*) filter(where bmi is null) as bmi,
	count(*) filter(where smoker is null) as smoker,
	count(*) filter(where bill_amount is null) as bill_amount,
	count(*) filter(where insuranceclaim is null) as insuranceclaim,
	count(*) filter(where insurance_apply_date is null) as insurance_apply_date,
	count(*) filter(where insurance_claimed_date is null) as insurance_claimed_date,
	count(*) filter(where claimed_amount is null) as claimed_amount,
	count(*) filter(where amount_paid is null) as amount_paid,
	count(*) filter(where duration is null) as duration
from nhic;

-- check duplicates
with dup as (select 
	*,
	row_number() over(partition by patient_id, full_name, age, children, sex, region_code, region, bmi, smoker, bill_amount, insuranceclaim, insurance_apply_date, insurance_claimed_date, claimed_amount, amount_paid, duration  order by patient_id) as rn
from nhic)
select * from dup 
where rn > 1;



-- check for duplicates and clean duplicates
with dup as (select 
	*,
	row_number() over(partition by patient_id, full_name, age, children, sex, region_code, region, bmi, smoker, bill_amount, insuranceclaim, insurance_apply_date, insurance_claimed_date, claimed_amount, amount_paid, duration order by patient_id) as rn
from nhic)
delete from nhic 
where patient_id in (
	select patient_id
	from dup where rn>1
);


-- values trimming for extra spaces
UPDATE nhic
SET 
    full_name = TRIM(full_name),
    region    = TRIM(region);

-- remove special characters, global flag, replaces all occurrences in the string.
UPDATE nhic
SET full_name = REGEXP_REPLACE(full_name, '[^a-zA-Z0-9\s]', '', 'g'),
    region    = REGEXP_REPLACE(region, '[^a-zA-Z0-9\s]', '', 'g');


-- added a column year to check the data duration
alter table nhic 
add column year_billing int;

update nhic
set year_billing = extract(year from insurance_apply_date);

--               Data Analysis
-- start and end date of insurance claims
select min(year_billing) as claims_start_year, max(year_billing) as claim_end_year from nhic;

-- showing data of nhic
select * from nhic;


-- region wise claimed percentage
SELECT 
    region,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN insuranceclaim = 1 THEN 1 ELSE 0 END) AS claimed_count,
    SUM(CASE WHEN insuranceclaim = 0 THEN 1 ELSE 0 END) AS not_claimed_count,
    ROUND(
        SUM(CASE WHEN insuranceclaim = 1 THEN 1 ELSE 0 END)::decimal * 100 / COUNT(*), 2
    ) AS claimed_percentage,
    ROUND(
        SUM(CASE WHEN insuranceclaim = 0 THEN 1 ELSE 0 END)::decimal * 100 / COUNT(*), 2
    ) AS not_claimed_percentage
FROM nhic
GROUP BY region
ORDER BY region;

-- smoker and bmi
SELECT 
    CASE 
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
        WHEN bmi BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    smoker,
    COUNT(*) AS total_people,
    SUM(CASE WHEN insuranceclaim = 1 THEN 1 ELSE 0 END) AS claimed_count,
    SUM(CASE WHEN insuranceclaim = 0 THEN 1 ELSE 0 END) AS not_claimed_count,
    ROUND(SUM(CASE WHEN insuranceclaim = 1 THEN 1 ELSE 0 END)::decimal * 100 / COUNT(*), 2) AS claimed_percentage,
    ROUND(SUM(CASE WHEN insuranceclaim = 0 THEN 1 ELSE 0 END)::decimal * 100 / COUNT(*), 2) AS not_claimed_percentage
FROM nhic
GROUP BY bmi_category, smoker
ORDER BY bmi_category, smoker;






select region, sum(bill_amount) as Tota, claimed_amount from nhic group by 1
-- conversion of nhic table into seperate csv file
copy nhic TO '/Users/pasalapavankumar/Desktop/internship/GNCIPL/week 6/National Health Insurance Claims project/nhic.csv' DELIMITER ',' CSV HEADER;




