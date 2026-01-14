Drop Table IF EXISTS gold.dim_products;
GO

CREATE TABLE gold.dim_products (
    product_key      INT IDENTITY(1,1) PRIMARY KEY,
    product_id       INT NOT NULL UNIQUE,

    product_name     NVARCHAR(200) NOT NULL,
    category         NVARCHAR(100) NOT NULL,
    cost_price       DECIMAL(10,2),
    selling_price    DECIMAL(10,2),
    sku              NVARCHAR(100),
    discontinued     BIT,
    added_date       DATE,
    weight           DECIMAL(10,2),
);
GO

INSERT INTO gold.dim_products(
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
    product_id,
    UPPER(LTRIM(RTRIM(product_name))),
    category,
    cost_price,
    selling_price,
    sku,
    discontinued,
    added_date,
    weight
FROM dw.products;
GO

-- Row count check
SELECT
    (SELECT COUNT(*) FROM gold.dim_products) AS gold_rows,
    (SELECT COUNT(*) FROM dw.products)       AS silver_rows;

-- Sample preview
SELECT TOP 20 *
FROM gold.dim_products
ORDER BY product_key;

-- Duplicate check safety
SELECT product_id, COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;