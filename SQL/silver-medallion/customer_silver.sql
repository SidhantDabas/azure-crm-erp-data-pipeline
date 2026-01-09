-- USE crmerpdb;
-- GO
-- --Identify duplicates based on phone and email, keeping the most recent entry
-- With duplcates_customer AS (
--     SELECT *,
--     ROW_NUMBER() OVER (
--         PARTITION BY customer_id, phone, email ORDER BY customer_id) AS rn
--     FROM dw.customer
--         )
-- SELECT * FROM duplcates_customer
-- WHERE rn > 1;

-- SELECT * FROM dw.customer
-- WHERE customer_id IS NULL OR first_name IS NULL OR email IS NULL or region IS NULL;
-- -- DELETE null FROM dw.customer
-- DELETE FROM dw.customer
-- WHERE customer_id IS NULL OR first_name IS NULL OR email IS NULL or region IS NULL;

-- ALTER TABLE dw.customer
-- DROP COLUMN signup_date_text;

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

-- EXEC sp_rename 'dw.customer.is_active_bool', 'is_active', 'COLUMN';
-- UPDATE dw.customer
-- SET phone = LTRIM(RTRIM(phone)),
--     first_name = LTRIM(RTRIM(first_name)),
--     email = LTRIM(RTRIM(email)),
--     region = LTRIM(RTRIM(region)),
--     last_name = LTRIM(RTRIM(last_name)),
--     loyalty_score = LTRIM(RTRIM(loyalty_score)),
--     notes = LTRIM(RTRIM(notes));

-- SELECT * FROM dw.customer
-- WHERE email NOT LIKE '%_@__%.__%';
select TOP(5)* FROM dw.customer;
select TOP(5)* FROM dw.orders;
select TOP(5)* FROM dw.inventory;
select TOP(5)* FROM dw.products;
select TOP(5)* FROM dw.employees;
select TOP(5)* FROM dw.invoices;