 --- Consider to divide Transactions Table & Logistics Table ---
 --- Transactions Details ---
 /*
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='transactions' AND SCHEMA_NAME(schema_id)='final')
 	CREATE TABLE [final].[transactions] (
 		     [trans_id]          INTEGER NOT NULL,
        [order_no]          VARCHAR(255),
        [project_name]      VARCHAR(255),
        [quotation_ref]     VARCHAR(255),
        [cust_po_no]        VARCHAR(100),
        [sap_code]          INT,
        [date]              DATE,
        [vendor_order_no]   VARCHAR(100),
        [supplier]          VARCHAR(255),
        [main_vendor]       VARCHAR(255),
        [industry_sector]   VARCHAR(255),
        [cooling]           VARCHAR(5),
        [sales_owner]       VARCHAR(255),
        [service_no]        VARCHAR(100),
        [order_type]        VARCHAR(255),
        [trans_category]    VARCHAR(255),
        [sales_value]       DECIMAL,
        [currency_code]     VARCHAR(20),
        [xchange_id]        VARCHAR(100),
        [sales_margin_cent] DECIMAL,
        [payment_term]      VARCHAR(255),
        [remark]            VARCHAR(255),
        [creator]           VARCHAR(255),
        [updated_at]        DATE,
        [hash_key]          VARCHAR(255) --VARCHAR(MAX)
 	);

 ALTER TABLE [final].[transactions] ADD CONSTRAINT pk_transactions PRIMARY KEY NONCLUSTERED (trans_id) NOT ENFORCED;
 */

 --- Customers ---
 --- To add other fields such as address, ph_no, email, in future
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='customers' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[customers] (
        [cust_key]      INTEGER NOT NULL,
        [cust_name]     VARCHAR(255),
        [sap_code]      INT,
        [country]       VARCHAR(20),
        [is_current]    VARCHAR(5),
        [start_date]    DATE,
        [end_date]      DATE
     );
 
 ALTER TABLE [final].[customers] ADD CONSTRAINT pk_customers PRIMARY KEY NONCLUSTERED (cust_key) NOT ENFORCED;

 --- Salespersons ---
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='salespersons' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[salespersons] (
        [code]       VARCHAR(100) NOT NULL,
        [sales_name] VARCHAR(255)
     );
 
 --- Logistics ---
 /*
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='logistics' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[logistics] (
        [log_id]                    INTEGER NOT NULL,
        [order_no]                  VARCHAR(255),
        [first_readiness_in_week]   INT,
        [actual_readiness_in_week]  INT,
        [delay]                     INT,
        [incoterm]                  VARCHAR(255),
        [shipping_cost]             DECIMAL,
        [budget_service_in_day]     INT,
        [budget_engineering_in_day] INT,
        [installation_status]       VARCHAR(5),
        [installation_value]        DECIMAL,
        [date]                      DATE,
        [updated_at]                DATE,
        [hash_key]                  VARCHAR(255) --VARCHAR(MAX)
     );         
 
 ALTER TABLE [final].[logistics] ADD CONSTRAINT pk_logistics PRIMARY KEY NONCLUSTERED (log_id) NOT ENFORCED;
 */

 --- Exchange Rate ---
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='xchange_rate' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[xchange_rate] (
        [xchange_key]       INTEGER NOT NULL,
        [xchange_id]        VARCHAR(100) NOT NULL,
        [currency_from]     VARCHAR(20),
        [currency_to]       VARCHAR(20),
        [xchange_rate]      FLOAT,
        [effective_date]    DATE,
        [valid_from_date]   DATE,
        [valid_to_date]     DATE,
        [month_name]        VARCHAR(20),
        [hash_key]          VARCHAR(255) --VARCHAR(MAX)
     );
 
 ALTER TABLE [final].[xchange_rate] ADD CONSTRAINT pk_xchange_rate PRIMARY KEY NONCLUSTERED (xchange_key) NOT ENFORCED;
 
 --- Date Dimension ---
 --- Creating Date Key (optional) ---
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='date' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[date] (
        [date]          DATE,
        [year]          INT,
        [month_num]     INT,
        [month_name]    VARCHAR(20),
        [quarter]       VARCHAR(20),
        [day_of_week]   INT,
        [calendar_week] INT
     );

 --- Combination of Transactions and Logistics ---
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='transactions_details' AND SCHEMA_NAME(schema_id)='final')
 	CREATE TABLE [final].[transactions_details] (
 		     [trans_id]                  INTEGER NOT NULL,
        [order_no]                  VARCHAR(255),
        [project_name]              VARCHAR(255),
        [quotation_ref]             VARCHAR(255),
        [cust_po_no]                VARCHAR(255),
        [sap_code]                  INT,
        [date]                      DATE,
        [vendor_order_no]           VARCHAR(255),
        [supplier]                  VARCHAR(255),
        [main_vendor]               VARCHAR(255),
        [industry_sector]           VARCHAR(255),
        [cooling]                   VARCHAR(255),
        [sales_owner]               VARCHAR(255),
        [service_no]                VARCHAR(255),
        [order_type]                VARCHAR(255),
        [trans_category]            VARCHAR(255),
        [sales_value]               FLOAT,
        [currency_code]             VARCHAR(255),
        [xchange_id]                VARCHAR(255),
        [sales_margin_cent]         FLOAT,
        [payment_term]              VARCHAR(255),
        [remark]                    VARCHAR(255),
        [creator]                   VARCHAR(255),
        [updated_at]                DATE,
        [hash_key]                  VARCHAR(255), --VARCHAR(MAX),
        [first_readiness_in_week]   INT,
        [actual_readiness_in_week]  INT,
        [delay]                     INT,
        [incoterm]                  VARCHAR(255),
        [shipping_cost]             FLOAT,
        [budget_service_in_day]     INT,
        [budget_engineering_in_day] INT,
        [installation_status]       VARCHAR(255),
        [installation_value]        FLOAT
 	);

 ALTER TABLE [final].[transactions_details] ADD CONSTRAINT pk_transactions_details PRIMARY KEY NONCLUSTERED (trans_id) NOT ENFORCED;
 
 /*
 --- Country Dimension (optional) ---
 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name='country' AND SCHEMA_NAME(schema_id)='final')
     CREATE TABLE [final].[country] (
        [alpha_2_code]      VARCHAR(5),
        [alpha_3_code]      VARCHAR(5),
        [country_numeric]   INT,
        [country]           VARCHAR(100),
        [focus_country]     VARCHAR(10)
     );
 */
 
GO
