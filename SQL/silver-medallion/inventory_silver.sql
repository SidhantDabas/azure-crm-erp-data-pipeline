USE crmerpdb;
GO

SELECT top(5) * FROM stg.inventory;
GO

-- Clean leading and trailing spaces from all string columns in the staging inventory table
UPDATE stg.inventory
SET inventory_id = LTRIM(RTRIM(inventory_id)),
    product_id = LTRIM(RTRIM(product_id)),
    warehouse = LTRIM(RTRIM(warehouse)),
    stock_count = LTRIM(RTRIM(stock_count)),
    reorder_threshold = LTRIM(RTRIM(reorder_threshold)),
    stock_text = LTRIM(RTRIM(stock_text));
GO
DROP TABLE IF EXISTS dw.inventory;
GO
SELECT TOP(5) * FROM dw.products;
GO
-- Create the employees table in the data warehouse schema
CREATE TABLE dw.inventory(
    inventory_id INT PRIMARY KEY,
    product_id INT,
    warehouse NVARCHAR(100),
    stock_count INT,
    stock_text NVARCHAR(100),
    reorder_threshold INT
);
INSERT INTO dw.inventory(
    inventory_id,
    product_id,
    warehouse,
    stock_count,
    stock_text,
    reorder_threshold
)
SELECT
    TRY_CONVERT(INT, inventory_id),
    TRY_CONVERT(INT, product_id),
    warehouse,
    TRY_CONVERT(INT, stock_count),
    stock_text,
    TRY_CONVERT(INT, reorder_threshold)
    
FROM stg.inventory;
GO
-- Ensure referential integrity by removing inventory records with non-existent products
DELETE FROM dw.inventory
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.products
    WHERE dw.products.product_id = dw.inventory.product_id
);
ALTER TABLE dw.inventory
ADD FOREIGN KEY (product_id) REFERENCES dw.products(product_id);
GO

-- -- Alter columns to a datatype and set NOT NULL or NULL constraints as needed
-- ALTER TABLE dw.inventory
-- ALTER COLUMN hire_date DATE NOT NULL;

-- ALTER TABLE dw.inventory
-- ALTER COLUMN termination_date DATE NULL;
-- SELECT TOP(5) * FROM dw.inventory;
-- GO

--Identify duplicates based on phone and email, keeping the most recent entry

With duplicates_inventory AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY inventory_id ORDER BY inventory_id) AS rn
    FROM dw.inventory
        )
SELECT * FROM duplicates_inventory
WHERE rn > 1;
GO
-- Identify nulls in critical columns
SELECT * FROM dw.inventory
WHERE inventory_id IS NULL OR product_id IS NULL OR warehouse IS NULL or stock_count IS NULL;
GO
-- DELETE null FROM dw.inventory
DELETE FROM dw.inventory
WHERE inventory_id IS NULL OR product_id IS NULL OR warehouse IS NULL or stock_count IS NULL OR reorder_threshold IS NULL;
GO

SELECT Top(5) * FROM dw.inventory;
GO

-- Drop unnecessary columns
ALTER TABLE dw.inventory
DROP COLUMN stock_text;

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
