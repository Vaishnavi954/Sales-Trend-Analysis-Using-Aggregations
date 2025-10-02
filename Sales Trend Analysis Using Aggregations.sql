USE sales_db;

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Truncate table to avoid duplicates (remove if you need existing data)
TRUNCATE TABLE sales;

-- Load CSV with date parsing and handle empty ShippingCost
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_sales_dataset.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(InvoiceNo, StockCode, Description, Quantity, @invoice_date, UnitPrice, CustomerID, Country, Discount, PaymentMethod, @shipping_cost, Category, SalesChannel, ReturnStatus, ShipmentProvider, WarehouseLocation, OrderPriority)
SET 
    InvoiceDate = STR_TO_DATE(@invoice_date, '%d-%m-%Y %H:%i'),
    ShippingCost = NULLIF(@shipping_cost, '');

-- Clean up data issues
UPDATE sales SET PaymentMethod = 'Paypal' WHERE PaymentMethod = 'paypall';
UPDATE sales SET Discount = 1.0 WHERE Discount > 1.0;
UPDATE sales SET CustomerID = NULL WHERE CustomerID = '';
UPDATE sales SET ShippingCost = NULL WHERE ShippingCost = 0;

-- Re-enable safe update mode (optional, for safety)
SET SQL_SAFE_UPDATES = 1;

-- Verify data
SELECT * FROM sales LIMIT 5;
SELECT COUNT(*) FROM sales;

-- Run sales trend analysis
SELECT 
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS order_volume
FROM sales
WHERE ReturnStatus = 'Not Returned' AND Quantity > 0
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY year, month;