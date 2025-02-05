--Query in the Copy Data Activity for Loading Data to Customers Table Pipeline
SELECT DISTINCT customer_id, first_name, last_name
FROM [dbo].[Orders];

--Query in the Lookup Activity for Incremental Data Loading Pipeline
SELECT CONVERT(VARCHAR, MAX(insert_time), 120) AS last_insert_time FROM [dbo].[Orders]

--Query in the Set Variable Activity for Incremental Data Loading Pipeline
LastInsertTime
@activity('LookupOrdersTable').output.firstRow.last_insert_time

--Query in the Copy Data Activity for Incremental Data Loading Pipeline
SELECT DISTINCT o.customer_id, o.first_name, o.last_name, o.insert_time
FROM [dbo].[Orders] o
WHERE o.insert_time > CONVERT(DATETIME, '@{variables('LastInsertTime')}', 120)
AND NOT EXISTS (
    SELECT 1 FROM [dbo].[Customer] c WHERE c.customer_id = o.customer_id
)