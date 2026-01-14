DROP TABLE IF EXISTS gold.dim_employee;
GO
CREATE TABLE gold.dim_employee (
    sales_rep_key      INT IDENTITY(1,1) PRIMARY KEY,
    sales_rep_id       INT NOT NULL UNIQUE, 
    first_name         NVARCHAR(100) NOT NULL,
    last_name          NVARCHAR(100) NOT NULL,
    email              NVARCHAR(320) NULL,
    department         NVARCHAR(100) NOT NULL,
    hire_date          DATE NOT NULL,
    termination_date   DATE NULL,
    department_code    NVARCHAR(50) NOT NULL,
)
GO
INSERT INTO gold.dim_employee (
    sales_rep_id,
    first_name,
    last_name,
    email,
    department,
    hire_date,
    termination_date,
    department_code
)
SELECT
    sales_rep_id,
    LTRIM(RTRIM(first_name)),
    LTRIM(RTRIM(last_name)),
    LOWER(LTRIM(RTRIM(email))),
    UPPER(LTRIM(RTRIM(department))),
    hire_date,
    termination_date,
    UPPER(LTRIM(RTRIM(department_code)))
FROM dw.employees;
GO
-- Row count check
SELECT COUNT(*) AS gold_rows FROM gold.dim_employee;
SELECT COUNT(*) AS silver_rows FROM dw.employees;

-- Sample preview
SELECT TOP 20 *
FROM gold.dim_employee
ORDER BY sales_rep_key;

-- Duplicate check safety
SELECT sales_rep_id, COUNT(*)
FROM gold.dim_employee
GROUP BY sales_rep_id
HAVING COUNT(*) > 1;