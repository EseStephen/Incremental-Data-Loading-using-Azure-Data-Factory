# Azure-DataFactory-SCD-Type1
This project demonstrates how to implement Slowly Changing Dimension (SCD) Type 1 using Azure Data Factory (ADF) Data Flows.

🚀 Project Overview
This project demonstrates how to implement Slowly Changing Dimension (SCD) Type 1 using Azure Data Factory (ADF) Data Flows. The project involves:<br>
Setting up an Azure Blob Storage container to store employee datasets in CSV format.<br>
Creating an Azure SQL Database to store employee records.<br>
Building an ADF pipeline to initially load employee data into SQL.<br>
Implementing SCD Type 1 using ADF Data Flows, which:<br>
Overwrites the salary of employees with updated salaries.<br>
Inserts new employees into the table.


📌 1. Setting Up Azure Resources<br>
1️⃣ Creating Azure Blob Storage<br>
Created a Storage Account in Azure.<br>
Created a Blob Container named employee-data.<br>
Uploaded the following files:<br>
Employees_Initial.csv (Initial employee data)<br>
Employees_Updated.csv (Updated employee data)


2️⃣ Creating Azure SQL Database<br>
Created an Azure SQL Database named EmployeeDB.<br>
Created a table to store employee records using the following query:<br>
CREATE TABLE Employees (<br>
    EmployeeID INT PRIMARY KEY,<br>
    Name VARCHAR(100),<br>
    Salary DECIMAL(10,2),<br>
    Location VARCHAR(100)<br>
);


📌 2. Setting Up Azure Data Factory (ADF)<br>
1️⃣ Creating Linked Services<br>
In Azure Data Factory, I created two linked services:<br>
Azure Blob Storage Linked Service – Connects to my storage account.<br>
Azure SQL Database Linked Service – Connects to my SQL database.


2️⃣ Creating Datasets<br>
Datasets help ADF read/write data from different sources. I created:<br>

🔹 Datasets for Azure Blob Storage<br>
employeesource → Points to Employees_Initial.csv in Blob Storage.<br>
employee2source → Points to Employees_Updated.csv in Blob Storage.<br>
🔹 Dataset for Azure SQL Database<br>
AzureSqlTableEmployee → Points to the Employees table in SQL Database.


📌 3. Loading Initial Employee Data into SQL<br>
Pipeline: LoadInitialEmployees<br>
Source → employeesource (from Blob Storage).<br>
Sink → AzureSqlTableEmployee (to SQL Database).<br>
Mapping → Mapped columns:<br>
EmployeeID → EmployeeID<br>
Name → Name<br>
Salary → Salary<br>
Location → Location<br>
Executed Pipeline → Successfully inserted records into the SQL database with copy data activity.


📌 4. Implementing SCD Type 1 using ADF Data Flow<br>
🔹 Step-by-Step Breakdown of the Data Flow<br>
I created a Data Flow named SCDType1DataFlow and added the following transformations:<br>
1️⃣ Source: employee2source<br>
Reads the updated employee dataset (Employees_Updated.csv) from Blob Storage.<br>
2️⃣ Source: AzureSqlTableEmployee<br>
Reads the existing employee records from the SQL Database.<br>
3️⃣ Join Transformation (Left Outer Join)<br>
Primary Stream: Employees_Updated (Latest data).<br>
Lookup Stream: ExistingEmployees (Existing data).<br>
Join Condition: Employees_Updated.EmployeeID == ExistingEmployees.EmployeeID.<br>
This allows us to compare new data with existing records.<br>
4️⃣ Derived Column Transformation<br>
Created two new columns:<br>
IsUpdated → if(ExistingEmployees.Salary != Employees_Updated.Salary, 1, 0) (Checks if salary has changed).<br>
IsNew → if(isNull(ExistingEmployees.EmployeeID), 1, 0) (Checks if the employee is new).<br>
5️⃣ Filter Transformation<br>
Filter 1 (Updated Employees) → IsUpdated == 1 (Extracts employees with salary updates).<br>
Filter 2 (New Employees) → IsNew == 1 (Extracts new employees).<br>
6️⃣ Alter Row Transformation<br>
Condition: Update if IsUpdated == 1.<br>
Condition: Insert if IsNew == 1.<br>
7️⃣ Sink Transformation<br>
Sink 1 → Updates employees in SQL Database.<br>
Sink 2 → Inserts new employees into SQL Database.


📌 5. Running & Validating the Pipeline<br>
Ran the Pipeline → Successfully processed the updated employee data.<br>

