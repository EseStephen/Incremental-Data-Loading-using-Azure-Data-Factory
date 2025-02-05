# Incremental-Data-Loading-using-Azure-Data-Factory
📝 Overview<br>
This project demonstrates a four-stage incremental data loading process using Azure Data Factory (ADF) and Azure SQL Database. The goal is to efficiently load and update data while preventing duplication and optimizing performance.

🎯 Project Goals<br>
✔ Load new data from CSV files into the Orders table.<br>
✔ Transfer unique customer records to the Customer table.<br>
✔ Implement incremental data loading to avoid reprocessing old records.<br>
✔ Ensure data integrity by handling duplicates and updates correctly.

⚙️ Architecture & Components<br>
📂 Azure SQL Database Tables<br>
Orders Table: Stores raw orders from CSV files.<br>
Customer Table: Stores unique customer records.

📑 Four ADF Pipelines<br>
Pipeline Name |	Purpose<br>
1️⃣ Data Loading into Orders Table |	Loads full dataset from CSV into the Orders table.<br>
2️⃣ Data Loading into Customers Table | Transfers unique customers from Orders to Customer.<br>
3️⃣ New Orders Data |	Loads new order records from another CSV file.<br>
4️⃣ Incremental Data Loading	| Retrieves the latest timestamp and loads only new records.

🔄 Pipeline 1: Data Loading into Orders Table<br>
Purpose: Loads all order records from a CSV file into the Orders table.

📌 Activities:<br>
1️⃣ Source Dataset: Connects to a CSV file.<br>
2️⃣ Copy Data Activity: Inserts records into Orders.<br>

📜 SQL Table Definition:<br>
CREATE TABLE Orders (<br>
    order_id INT PRIMARY KEY,<br>
    customer_id INT,<br>
    first_name NVARCHAR(50),<br>
    last_name NVARCHAR(50),<br>
    order_amount DECIMAL(10,2),<br>
    order_date DATE,<br>
    insert_time DATETIME DEFAULT GETDATE()<br>
);

🔄 Pipeline 2: Data Loading into Customers Table<br>
Purpose: Extracts unique customer records from Orders and inserts them into Customer.<br>

📌 Activities:<br>
1️⃣ Source Dataset: Reads from Orders.<br>
2️⃣ Copy Data Activity: Inserts distinct customers into Customer, avoiding duplicates.<br>

📜 SQL Query:<br>
SELECT DISTINCT customer_id, first_name, last_name<br>
FROM [dbo].[Orders];

📜 SQL Table Definition:<br>
CREATE TABLE Customer (<br>
    customer_id INT PRIMARY KEY,<br>
    first_name NVARCHAR(50),<br>
    last_name NVARCHAR(50),<br>
    insert_time DATETIME DEFAULT GETDATE()<br>
);

🔄 Pipeline 3: New Orders Data<br>
Purpose: Loads new orders from another CSV file into the Orders table.<br>

📌 Activities:<br>
1️⃣ Source Dataset: Points to orders_dataset_incremental.csv.<br>
2️⃣ Copy Data Activity: Inserts new records into Orders.

🔄 Pipeline 4: Incremental Data Loading<br>
Purpose: Ensures that only new data is copied to the Customer table based on insert_time.<br>

📌 Activities:<br>
1️⃣ Lookup Activity: Fetches the most recent insert_time from Orders.<br>
2️⃣ Set Variable Activity: Stores the latest timestamp.<br>
3️⃣ Copy Data Activity: Transfers only new customers from Orders to Customer.

🛠️ How Incremental Loading Works<br>
📜 Step 1: Lookup Last Insert Time<br>
SELECT CONVERT(VARCHAR, MAX(insert_time), 120) AS last_insert_time FROM [dbo].[Orders]<br>
Retrieves the most recent insert_time from Orders.<br>
The result is stored in the Set Variable Activity.<br>

📜 Step 2: Set Variable<br>
Create Pipeline variable (LastInsertTime)<br>
@activity('LookupOrdersTable').output.firstRow.last_insert_time<br>

📜 Step 3: Filter Only New Data in Copy Data Activity<br>
Query<br>
SELECT DISTINCT o.customer_id, o.first_name, o.last_name, o.insert_time<br>
FROM [dbo].[Orders] o<br>
WHERE o.insert_time > CONVERT(DATETIME, '@{variables('LastInsertTime')}', 120)<br>
AND NOT EXISTS (<br>
    SELECT 1 FROM [dbo].[Customer] c WHERE c.customer_id = o.customer_id<br>
)

✔ Loads only new records based on insert_time.<br>
✔ Prevents duplicate customers using NOT EXISTS.<br>



