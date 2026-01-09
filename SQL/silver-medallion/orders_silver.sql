USE crmerpdb;
GO

SELECT top(5) * FROM stg.orders;
GO

-- Clean leading and trailing spaces from all string columns in the staging orders table
UPDATE stg.orders
SET customer_id = LTRIM(RTRIM(customer_id)),
    order_id = LTRIM(RTRIM(order_id)),
    product_id = LTRIM(RTRIM(product_id)),
    quantity = LTRIM(RTRIM(quantity)),
    quantity_text = LTRIM(RTRIM(quantity_text)),
    order_date = LTRIM(RTRIM(order_date)),
    delivery_date = LTRIM(RTRIM(delivery_date)),
    status = LTRIM(RTRIM(status)),
    sales_rep_id = LTRIM(RTRIM(sales_rep_id));
GO
DROP TABLE IF EXISTS dw.orders;
GO
-- Create the employees table in the data quantity schema
CREATE TABLE dw.orders(
    customer_id INT,
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    quantity_text NVARCHAR(100),
    status NVARCHAR(100),
    order_date DATE,
    delivery_date DATE,
    sales_rep_id INT
);
INSERT INTO dw.orders(
    customer_id,
    order_id,
    product_id,
    quantity,
    quantity_text,
    status,
    order_date,
    delivery_date,
    sales_rep_id
)
SELECT
    TRY_CONVERT(INT, customer_id),
    TRY_CONVERT(INT, order_id),
    TRY_CONVERT(INT, product_id),
    TRY_CONVERT(INT, quantity),
    TRY_CONVERT(NVARCHAR(100), quantity_text),
    status,
    TRY_CONVERT(date, order_date),
    TRY_CONVERT(date, delivery_date),
    TRY_CONVERT(INT, sales_rep_id)
FROM stg.orders;
GO
-- Ensure referential integrity by removing orders records with non-existent products
DELETE o
FROM dw.orders o
LEFT JOIN dw.customer  c ON c.customer_id = o.customer_id
LEFT JOIN dw.products  p ON p.product_id  = o.product_id
LEFT JOIN dw.employees e ON e.sales_rep_id = o.sales_rep_id
WHERE c.customer_id IS NULL
   OR p.product_id  IS NULL
   OR e.sales_rep_id IS NULL;
GO
ALTER TABLE dw.orders
ADD FOREIGN KEY (customer_id) REFERENCES dw.customer(customer_id);
ALTER TABLE dw.orders
ADD FOREIGN KEY (sales_rep_id) REFERENCES dw.employees(sales_rep_id);
ALTER TABLE dw.orders
ADD FOREIGN KEY (product_id) REFERENCES dw.products(product_id);
GO

-- -- Alter columns to a datatype and set NOT NULL or NULL constraints as needed
-- ALTER TABLE dw.orders
-- ALTER COLUMN product_id DATE NOT NULL;

-- ALTER TABLE dw.orders
-- ALTER COLUMN quantity DATE NULL;
-- SELECT TOP(5) * FROM dw.orders;
-- GO

--Identify duplicates based on phone and email, keeping the most recent entry

With duplicates_orders AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id ORDER BY order_id) AS rn
    FROM dw.orders
        )
SELECT * FROM duplicates_orders
WHERE rn > 1;
GO
-- Identify nulls in critical columns
SELECT * FROM dw.orders
WHERE customer_id IS NULL OR order_id IS NULL OR quantity IS NULL OR product_id IS NULL OR sales_rep_id IS NULL OR order_date IS NULL;
GO
-- DELETE null FROM dw.orders
DELETE FROM dw.orders
WHERE customer_id IS NULL OR order_id IS NULL OR quantity IS NULL OR product_id IS NULL OR sales_rep_id IS NULL OR order_date IS NULL;
GO

SELECT Top(5) * FROM dw.orders;
GO

-- -- Drop unnecessary columns
-- ALTER TABLE dw.orders
-- DROP COLUMN status;

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
