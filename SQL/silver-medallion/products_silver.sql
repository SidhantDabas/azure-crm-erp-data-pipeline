USE crmerpdb;
GO

SELECT top(5) * FROM stg.products;
GO

-- Clean leading and trailing spaces from all string columns in the staging products table
UPDATE stg.products
SET product_id = LTRIM(RTRIM(product_id)),
    product_name = LTRIM(RTRIM(product_name)),
    category = LTRIM(RTRIM(category)),
    cost_price = LTRIM(RTRIM(cost_price)),
    selling_price = LTRIM(RTRIM(selling_price)),
    sku = LTRIM(RTRIM(sku)),
    discontinued = LTRIM(RTRIM(discontinued)),
    added_date = LTRIM(RTRIM(added_date)),
    weight = LTRIM(RTRIM(weight)),
    cost_price_text = LTRIM(RTRIM(cost_price_text));
GO

-- Create the products table in the data warehouse schema
CREATE TABLE dw.products(
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(100),
    category NVARCHAR(100),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    sku NVARCHAR(100),
    discontinued BIT,
    added_date DATE,
    weight DECIMAL(10,2)
);
INSERT INTO dw.products(
    product_id,
    product_name,
    category,
    cost_price,
    selling_price,
    sku,
    discontinued,
    added_date,
    weight
)
SELECT
    TRY_CONVERT(INT, product_id),
    product_name,
    category,
    TRY_CONVERT(DECIMAL(10,2), cost_price),
    TRY_CONVERT(DECIMAL(10,2), selling_price),
    sku,
    TRY_CONVERT(BIT, discontinued),
    TRY_CONVERT(DATE, added_date),
    TRY_CONVERT(DECIMAL(10,2), weight)
FROM stg.products;
GO

SELECT TOP(5) * FROM dw.products;
GO
-- -- Alter columns to a datatype and set NOT NULL or NULL constraints as needed
-- ALTER TABLE dw.inventory
-- ALTER COLUMN hire_date DATE NOT NULL;

-- ALTER TABLE dw.inventory
-- ALTER COLUMN termination_date DATE NULL;
-- SELECT TOP(5) * FROM dw.inventory;
-- GO

--Identify duplicates based on phone and email, keeping the most recent entry
With duplicates_products AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY product_id, product_name ORDER BY product_id) AS rn
    FROM dw.products
        )
SELECT * FROM duplicates_products
WHERE rn > 1;
GO
-- Identify nulls in critical columns
SELECT * FROM dw.products
WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL or cost_price IS NULL OR selling_price IS NULL OR added_date IS NULL;
GO
-- DELETE null FROM dw.products
DELETE FROM dw.products
WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL or cost_price IS NULL OR selling_price IS NULL or added_date IS NULL;
GO

SELECT Top(5) * FROM dw.products;
GO

-- -- Drop unnecessary columns
-- ALTER TABLE dw.products
-- DROP COLUMN cost_price_text;

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
