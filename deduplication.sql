/*
EXEC [staging].[sp_final_deduplication]
GO
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [staging].[sp_final_deduplication]
AS
BEGIN 
        --- START Transactions Deduplication --- 
        --- Every time staging table (especially transaction details) structure is changed, check and valid the table structure for consistency.
        CREATE TABLE [staging].[temp_transactions_details]
        AS
        SELECT * 
        FROM (
                SELECT *,
                ROW_NUMBER() OVER (PARTITION BY 
                        date,
                        month_name,
                        calendar_week,
                        cust_name,
                        sap_code,
                        trans_category,
                        project_name,
                        country,
                        sales_owner,
                        quotation_ref,
                        cust_po_no,
                        order_no,
                        vendor_order_no,
                        supplier,
                        main_vendor,
                        industry_sector,
                        cooling,
                        service_no,
                        order_type,
                        eur,
                        eur_to_thb,
                        thb,
                        thb_to_thb,
                        usd,
                        usd_to_thb,
                        idr,
                        idr_to_thb,
                        sales_value,
                        sales_margin_cent,
                        sales_margin_calculated,
                        first_readiness_in_week,
                        actual_readiness_in_week,
                        delay,
                        incoterm,
                        shipping_cost,
                        budget_service_in_day,
                        installation_status,
                        installation_value,
                        budget_engineering_in_day,
                        payment_term,
                        remark,
                        creator,
                        updated_at,
                        hash_key
                 ORDER BY (SELECT NULL)) AS duplicates
                FROM [staging].[stg_transactions_details]
                ) AS temp 
        WHERE duplicates = 1

        TRUNCATE TABLE [staging].[stg_transactions_details]
        
        INSERT INTO [staging].[stg_transactions_details]
        SELECT  date,
                month_name,
                calendar_week,
                cust_name,
                sap_code,
                trans_category,
                project_name,
                country,
                sales_owner,
                quotation_ref,
                cust_po_no,
                order_no,
                vendor_order_no,
                supplier,
                main_vendor,
                industry_sector,
                cooling,
                service_no,
                order_type,
                eur,
                eur_to_thb,
                thb,
                thb_to_thb,
                usd,
                usd_to_thb,
                idr,
                idr_to_thb,
                sales_value,
                sales_margin_cent,
                sales_margin_calculated,
                first_readiness_in_week,
                actual_readiness_in_week,
                delay,
                incoterm,
                shipping_cost,
                budget_service_in_day,
                installation_status,
                installation_value,
                budget_engineering_in_day,
                payment_term,
                remark,
                creator,
                updated_at,
                hash_key           
        FROM [staging].[temp_transactions_details]

        DROP TABLE [staging].[temp_transactions_details]
        --- END Transactions Deduplication --- 

        --- START Salespersons Deduplication --- 
        CREATE TABLE [staging].[temp_salespersons]
        AS
        SELECT * 
        FROM (
                SELECT *,
                ROW_NUMBER() OVER (PARTITION BY code, sales_name
                 ORDER BY (SELECT NULL)) AS duplicates
                FROM [staging].[stg_salespersons]
                ) AS temp 
        WHERE duplicates = 1

        TRUNCATE TABLE [staging].[stg_salespersons]
        
        INSERT INTO [staging].[stg_salespersons]
        SELECT  
              code,
              sales_name
        FROM [staging].[temp_salespersons]

        DROP TABLE [staging].[temp_salespersons]
        --- END Salespersons Deduplication --- 
        
        --- START Xchange Rate Deduplication --- 
        CREATE TABLE [staging].[temp_xchange_rate]
        AS
        SELECT * 
        FROM (
                SELECT *,
                ROW_NUMBER() OVER (PARTITION BY 
                        xchange_id, 
                        currency_from, 
                        currency_to, 
                        xchange_rate, 
                        effective_date, 
                        valid_from_date, 
                        valid_to_date, 
                        month_name,
                        hash_key
                 ORDER BY (SELECT NULL)) AS duplicates
                FROM [staging].[stg_xchange_rate]
                ) AS temp 
        WHERE duplicates = 1

        TRUNCATE TABLE [staging].[stg_xchange_rate]
        
        INSERT INTO [staging].[stg_xchange_rate]
        SELECT  
              xchange_id,
              currency_from,
              currency_to,
              xchange_rate,
              effective_date,
              valid_from_date,
              valid_to_date,
              month_name,
              hash_key
        FROM [staging].[temp_xchange_rate]

        DROP TABLE [staging].[temp_xchange_rate]
        --- END Xchange Rate Deduplication ---

        --- START Customers Deduplication --- 
        CREATE TABLE [staging].[temp_customers]
        AS
        SELECT * 
        FROM (
                SELECT *,
                ROW_NUMBER() OVER (PARTITION BY 
                        cust_name, 
                        sap_code, 
                        country, 
                        is_current,
                        start_date,
                        end_date
                 ORDER BY (SELECT NULL)) AS duplicates
                FROM [staging].[stg_customers]
                ) AS temp 
        WHERE duplicates = 1

        TRUNCATE TABLE [staging].[stg_customers]
        
        INSERT INTO [staging].[stg_customers]
        SELECT  
              cust_name,
              sap_code,
              country,
              is_current,
              start_date,
              end_date
        FROM [staging].[temp_customers]

        DROP TABLE [staging].[temp_customers]
        --- END Customers Deduplication ---

END
GO