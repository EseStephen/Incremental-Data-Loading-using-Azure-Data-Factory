CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    order_amount DECIMAL(10,2),
    order_date DATE,
    insert_time DATETIME DEFAULT GETDATE()
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    insert_time DATETIME DEFAULT GETDATE() -- Auto-generates insert_time
);

SELECT * FROM [dbo].[Orders]

SELECT * FROM [dbo].[Customer]