USE crmerpdb;
GO

SELECT top(5) * FROM stg.invoices;
GO

-- Clean leading and trailing spaces from all string columns in the staging invoices table
UPDATE stg.invoices
SET invoice_id = LTRIM(RTRIM(invoice_id)),
    order_id = LTRIM(RTRIM(order_id)),
    invoice_date = LTRIM(RTRIM(invoice_date)),
    payment_date = LTRIM(RTRIM(payment_date)),
    tax_amount = LTRIM(RTRIM(tax_amount)),
    discount_amount = LTRIM(RTRIM(discount_amount)),
    payment_status = LTRIM(RTRIM(payment_status));
GO
-- Create the employees table in the data payment_date schema
CREATE TABLE dw.invoices(
    invoice_id INT PRIMARY KEY,
    order_id INT,
    invoice_date DATE,
    payment_date DATE,
    tax_amount DECIMAL(10,2),
    payment_status NVARCHAR(100),
    discount_amount DECIMAL(10,2)
);
INSERT INTO dw.invoices(
    invoice_id,
    order_id,
    invoice_date,
    payment_date,
    tax_amount,
    payment_status,
    discount_amount
)
SELECT
    TRY_CONVERT(INT, invoice_id),
    TRY_CONVERT(INT, order_id),
    TRY_CONVERT(DATE, invoice_date),
    TRY_CONVERT(DATE, payment_date),
    TRY_CONVERT(decimal(10,2), tax_amount),
    payment_status,
    TRY_CONVERT(decimal(10,2), discount_amount)
    
FROM stg.invoices;
GO
Ensure referential integrity by removing invoices records with non-existent products
DELETE i
FROM dw.invoices i
LEFT JOIN dw.orders o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;
GO
ALTER TABLE dw.invoices
ADD FOREIGN KEY (order_id) REFERENCES dw.orders(order_id);
-- Alter columns to a datatype and set NOT NULL or NULL constraints as needed
ALTER TABLE dw.invoices
ALTER COLUMN invoice_date DATE NOT NULL;

ALTER TABLE dw.invoices
ALTER COLUMN payment_date DATE NULL;
SELECT TOP(5) * FROM dw.invoices;
GO

--Identify duplicates based on phone and email, keeping the most recent entry

With duplicates_invoices AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY invoice_id, order_id ORDER BY invoice_id) AS rn
    FROM dw.invoices
        )
SELECT * FROM duplicates_invoices
WHERE rn > 1;
GO
-- Identify nulls in critical columns
SELECT * FROM dw.invoices
WHERE invoice_id IS NULL OR order_id IS NULL OR tax_amount IS NULL OR invoice_date IS NULL;
GO
-- DELETE null FROM dw.invoices
DELETE FROM dw.invoices
WHERE invoice_id IS NULL OR order_id IS NULL OR tax_amount IS NULL OR invoice_date IS NULL;
GO

SELECT Top(5) * FROM dw.invoices;
GO

-- -- Drop unnecessary columns
-- ALTER TABLE dw.invoices
-- DROP COLUMN payment_status;

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
