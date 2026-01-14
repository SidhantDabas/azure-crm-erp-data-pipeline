DROP TABLE IF EXISTS gold.fact_orders;
GO

CREATE TABLE gold.fact_orders (
    order_id        INT NOT NULL PRIMARY KEY,

    customer_key    INT NOT NULL,
    product_key     INT NOT NULL,
    sales_rep_key    INT NOT NULL,

    order_date      DATE NOT NULL,
    delivery_date   DATE NULL,
    status          NVARCHAR(50) NULL,

    quantity        INT NOT NULL,

    unit_price      DECIMAL(10,2) NULL,
    revenue         DECIMAL(12,2) NULL,
    delivery_days   INT NULL,

    created_at      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
INSERT INTO gold.fact_orders (
    order_id,
    customer_key,
    product_key,
    sales_rep_key,
    order_date,
    delivery_date,
    status,
    quantity,
    unit_price,
    revenue,
    delivery_days
)
SELECT
    o.order_id,
    dc.customer_key,
    dp.product_key,
    de.sales_rep_key,
    o.order_date,
    o.delivery_date,
    o.status,
    o.quantity,
    dp.selling_price AS unit_price,
    CAST(o.quantity * dp.selling_price AS DECIMAL(12,2)) AS revenue,
    CASE
        WHEN o.delivery_date IS NULL THEN NULL
        ELSE DATEDIFF(DAY, o.order_date, o.delivery_date)
    END AS delivery_days
FROM dw.orders o
JOIN gold.dim_customer dc ON dc.customer_id = o.customer_id
JOIN gold.dim_products  dp ON dp.product_id  = o.product_id
JOIN gold.dim_employee de ON de.sales_rep_id = o.sales_rep_id;
GO
ALTER TABLE gold.fact_orders
ADD CONSTRAINT FK_fact_orders_customer
FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key);

ALTER TABLE gold.fact_orders
ADD CONSTRAINT FK_fact_orders_product
FOREIGN KEY (product_key) REFERENCES gold.dim_products(product_key);

ALTER TABLE gold.fact_orders
ADD CONSTRAINT FK_fact_orders_employee
FOREIGN KEY (sales_rep_key) REFERENCES gold.dim_employee(sales_rep_key);
GO
SELECT TOP 10 * FROM gold.fact_orders ORDER BY order_id;
SELECT COUNT(*) AS orders_in_gold FROM gold.fact_orders;

-- sanity check revenue by region
SELECT TOP 10
    c.region,
    SUM(f.revenue) AS total_revenue
FROM gold.fact_orders f
JOIN gold.dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.region
ORDER BY total_revenue DESC;
GO
