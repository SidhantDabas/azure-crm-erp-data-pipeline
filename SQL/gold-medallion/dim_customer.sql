Drop Table IF EXISTS gold.dim_customer;
GO

CREATE TABLE gold.dim_customer (
    customer_key      INT IDENTITY(1,1) PRIMARY KEY,
    customer_id       INT NOT NULL UNIQUE,

    first_name         NVARCHAR(100) NOT NULL,
    last_name          NVARCHAR(100) NOT NULL,
    email              NVARCHAR(320) NULL,
    phone              NVARCHAR(50) NULL,
    region             NVARCHAR(50) NOT NULL,

    signup_date        DATE NULL,
    loyalty_score      DECIMAL(5,2) NULL,
    is_active           BIT NOT NULL,

    notes              NVARCHAR(500) NULL,

    -- Metadata
    created_at          DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO gold.dim_customer (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    region,
    signup_date,
    loyalty_score,
    is_active,
    notes
)
SELECT
    customer_id,
    LTRIM(RTRIM(first_name)),
    LTRIM(RTRIM(last_name)),
    LOWER(LTRIM(RTRIM(email))),
    LTRIM(RTRIM(phone)),
    UPPER(LTRIM(RTRIM(region))),
    signup_date,
    loyalty_score,
    is_active,
    notes
FROM dw.customer;
GO

-- Duplicate check safety
SELECT customer_id, COUNT(*)
FROM gold.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;