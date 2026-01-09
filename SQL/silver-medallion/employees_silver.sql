USE crmerpdb;
GO
-- Clean leading and trailing spaces from all string columns in the staging employees table
UPDATE stg.employees
SET sales_rep_id = LTRIM(RTRIM(sales_rep_id)),
    first_name = LTRIM(RTRIM(first_name)),
    last_name = LTRIM(RTRIM(last_name)),
    email = LTRIM(RTRIM(email)),
    department = LTRIM(RTRIM(department)),
    hire_date = LTRIM(RTRIM(hire_date)),
    termination_date = LTRIM(RTRIM(termination_date)),
    department_code = LTRIM(RTRIM(department_code)),
    full_name_raw = LTRIM(RTRIM(full_name_raw));
GO
DROP TABLE IF EXISTS dw.employees;
GO
-- Create the employees table in the data warehouse schema
CREATE TABLE dw.employees(
    sales_rep_id INT PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    email NVARCHAR(100),
    department NVARCHAR(100),
    hire_date DATE,
    termination_date DATE,
    department_code NVARCHAR(100),
    full_name_raw NVARCHAR(100)
);
SELECT TOP(5) * FROM dw.employees;
GO
INSERT INTO dw.employees (
    sales_rep_id,
    first_name,
    last_name,
    email,
    department,
    hire_date,
    termination_date,
    department_code,
    full_name_raw
)
SELECT
    TRY_CONVERT(INT, sales_rep_id),
    first_name,
    last_name,
    email,
    department,
    hire_date,
    termination_date,
    department_code,
    full_name_raw
    
FROM stg.employees;
GO

SELECT TOP(5) * FROM dw.employees;
GO
-- Alter columns to a datatype and set NOT NULL or NULL constraints as needed
ALTER TABLE dw.employees
ALTER COLUMN hire_date DATE NOT NULL;

ALTER TABLE dw.employees
ALTER COLUMN termination_date DATE NULL;
SELECT TOP(5) * FROM dw.employees;
GO

--Identify duplicates based on phone and email, keeping the most recent entry

With duplcates_employees AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY sales_rep_id, hire_date, email ORDER BY sales_rep_id) AS rn
    FROM dw.employees
        )
SELECT * FROM duplcates_employees
WHERE rn > 1;
GO
-- Identify nulls in critical columns
SELECT * FROM dw.employees
WHERE sales_rep_id IS NULL OR first_name IS NULL OR email IS NULL or hire_date IS NULL OR department IS NULL;
GO
-- DELETE null FROM dw.customer
DELETE FROM dw.employees
WHERE sales_rep_id IS NULL OR first_name IS NULL OR email IS NULL or hire_date IS NULL OR department IS NULL;
GO

SELECT Top(5) * FROM dw.employees;
GO

-- Drop unnecessary columns
-- ALTER TABLE dw.customer
-- DROP COLUMN signup_date_text;

---- Make is_active a BIT column
-- ALTER TABLE dw.customer
-- ADD is_active_bool BIT NOT NULL DEFAULT 0;
-- SELECT * FROM dw.customer
-- GO

-- UPDATE dw.customer
-- SET is_active_bool = CASE 
-- WHEN LOWER(TRIM(is_active)) IN ('t','true','1','yes') THEN 1
-- WHEN LOWER(TRIM(is_active)) IN ('f','false','0','no') THEN 0
-- ELSE NULL END;

-- ALTER TABLE dw.customer
-- DROP COLUMN is_active;

-- --Rename is_active_bool to is_active
-- EXEC sp_rename 'dw.customer.is_active_bool', 'is_active', 'COLUMN';
-- UPDATE dw.customer
-- SET phone = LTRIM(RTRIM(phone)),
--     first_name = LTRIM(RTRIM(first_name)),
--     email = LTRIM(RTRIM(email)),
--     region = LTRIM(RTRIM(region)),
--     last_name = LTRIM(RTRIM(last_name)),
--     loyalty_score = LTRIM(RTRIM(loyalty_score)),
--     notes = LTRIM(RTRIM(notes));

-- Identify invalid email formats
SELECT * FROM dw.employees
WHERE email NOT LIKE '%_@__%.__%';

-- ALTER TABLE dw.customer
-- ALTER COLUMN customer_id INT NOT NULL;
-- GO
-- ALTER TABLE dw.customer
-- ADD PRIMARY KEY (customer_id);
-- GO