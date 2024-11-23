-- Loading Final Tables
/*
EXEC [final].[sp_final_loading]
GO
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [final].[sp_final_loading]
AS
BEGIN

    -- Loading DATE SERIES --
    -- Later Generating Date Series into the data flow Gen2 mapping with transactions --
    INSERT INTO [final].[date] 
    SELECT DISTINCT * FROM [PVGLHS].[dbo].[date] AS raw
    WHERE NOT EXISTS ( -- Check for inserting no duplicates -- 
        SELECT 1
        FROM [final].[date] AS final 
        WHERE final.date = raw.date
        AND final.year = raw.year
        AND final.month_num = raw.month_num
        AND final.month_name = raw.month_name
        AND final.quarter = raw.quarter
        AND final.day_of_week = raw.day_of_week
        AND final.calendar_week = raw.calendar_week
    )
    
    -- Loading EXCHANGE RATE With Auto Increment --
    DECLARE @max_xchange_key BIGINT

    IF EXISTS(SELECT * FROM [final].[xchange_rate])
        SET @max_xchange_key = (SELECT MAX([xchange_key]) FROM [final].[xchange_rate])
    ELSE
        SET @max_xchange_key = 0
   
    INSERT INTO [final].[xchange_rate]
    SELECT 
        @max_xchange_key + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS xchange_key,
        xchange_id,
        currency_from,
        currency_to,
        xchange_rate,
        effective_date,
        valid_from_date,
        valid_to_date,
        month_name,
        hash_key 
    FROM (SELECT -- DISTINCT 
                xchange_id,
                currency_from,
                currency_to,
                xchange_rate,
                effective_date,
                valid_from_date,
                valid_to_date,
                month_name,
                /* If needed, use later
                HASHBYTES('SHA2_256', CONCAT(
                    xchange_id,
                    currency_from,
                    currency_to,
                    xchange_rate,
                    effective_date,
                    valid_from_date,
                    valid_to_date,
                    month_name
                )) AS hash_key
                */
                hash_key -- current NULL --
          FROM [staging].[stg_xchange_rate]) AS raw
    WHERE NOT EXISTS ( -- Check for inserting no duplicates -- 
        SELECT 1
        FROM [final].[xchange_rate] AS final
        WHERE ISNULL(final.xchange_id, 'NA') = ISNULL(raw.xchange_id, 'NA')
        AND ISNULL(final.currency_from, 'NA') = ISNULL(raw.currency_from, 'NA')
        AND ISNULL(final.currency_to, 'NA') = ISNULL(raw.currency_to, 'NA')
        AND ISNULL(final.xchange_rate, 0.0) = ISNULL(raw.xchange_rate, 0.0)
        AND ISNULL(final.effective_date, '9999-12-31') = ISNULL(raw.effective_date, '9999-12-31')
        AND ISNULL(final.valid_from_date, '9999-12-31') = ISNULL(raw.valid_from_date, '9999-12-31')
        AND ISNULL(final.valid_to_date, '9999-12-31') = ISNULL(raw.valid_to_date, '9999-12-31')
        AND ISNULL(final.month_name, 'NA') = ISNULL(raw.month_name, 'NA')
        AND ISNULL(final.hash_key, 'NA') = ISNULL(raw.hash_key, 'NA')
    )

    -- Loading SALESPERSONS Data --
    INSERT INTO [final].[salespersons]
    SELECT DISTINCT * FROM [staging].[stg_salespersons] AS raw
    WHERE NOT EXISTS ( -- Check for inserting no duplicates -- 
        SELECT 1
        FROM [final].[salespersons] AS final
        WHERE ISNULL(final.code, 'NA') = ISNULL(raw.code, 'NA')
        AND ISNULL(final.sales_name, 'NA') = ISNULL(raw.sales_name, 'NA')
    )

    -- Loading CUSTOMERS Data With Auto Increment -- 
    -- Need to create staging tables in data pipeline --
    DECLARE @max_cust_key BIGINT

    IF EXISTS(SELECT * FROM [final].[customers])
        SET @max_cust_key = (SELECT MAX([cust_key]) FROM [final].[customers])
    ELSE
        SET @max_cust_key = 0

    INSERT INTO [final].[customers]    
    SELECT 
        @max_cust_key + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS cust_key, 
        cust_name,
        sap_code,
        country,
        is_current,
        start_date,
        end_date
    FROM
        (
        SELECT DISTINCT 
            cust_name,
            sap_code,
            country,
            is_current, -- To identify for unique customer (SCD Flag)
            start_date, -- To identify for valid start date
            end_date -- To idendify for valid end date
        FROM [staging].[stg_customers]
        ) raw
    WHERE NOT EXISTS ( -- Check for inserting no duplicates -- 
        SELECT 1
        FROM [final].[customers] final
        WHERE ISNULL(final.cust_name, 'NA') = ISNULL(raw.cust_name, 'NA')
        AND ISNULL(final.sap_code, 0) = ISNULL(raw.sap_code, 0)
        AND ISNULL(final.country, 'NA') = ISNULL(raw.country, 'NA')
        AND ISNULL(final.is_current, 'NA') = ISNULL(raw.is_current, 'NA')
        AND ISNULL(final.start_date, '9999-12-31') = ISNULL(raw.start_date, '9999-12-31')
        AND ISNULL(final.end_date, '9999-12-31') = ISNULL(raw.end_date, '9999-12-31')
    )

    --*** Loading COMBINATION of Transactions and Logistics Data With Auto Increment ***--
    DECLARE @max_details_id BIGINT

    IF EXISTS(SELECT * FROM [final].[transactions_details])
        SET @max_details_id = (SELECT MAX([trans_id]) FROM [final].[transactions_details])
    ELSE
        SET @max_details_id = 0

    INSERT INTO [final].[transactions_details]
    SELECT 
        @max_details_id + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS trans_id,
        order_no, 
        project_name,
        quotation_ref,
        cust_po_no,
        sap_code,
        date,
        vendor_order_no,
        supplier,
        main_vendor,
        industry_sector,
        cooling,
        sales_owner,
        service_no,
        order_type,
        trans_category,
        sales_value,
        currency_code, 
        xchange_id, 
        sales_margin_cent,
        payment_term,
        remark,
        creator, 
        updated_at,
        hash_key,
        -- Start combination --
        first_readiness_in_week,
        actual_readiness_in_week,
        delay,
        incoterm,
        shipping_cost,
        budget_service_in_day,
        budget_engineering_in_day,
        installation_status,
        installation_value
    FROM 
        (
        SELECT  -- DISTINCT
                order_no, 
                project_name,
                quotation_ref,
                cust_po_no,
                sap_code, --(FK)
                date,
                vendor_order_no,
                supplier,
                main_vendor,
                industry_sector,
                cooling,
                sales_owner, --(FK)
                service_no,
                order_type,
                trans_category,
                --sales_value,
                ISNULL(eur, 0.0)  + ISNULL(thb, 0.0) + ISNULL(usd, 0.0) + ISNULL(idr, 0.0) AS sales_value,
                CASE WHEN eur <> 0 THEN 'EUR' 
                     WHEN thb <> 0 THEN 'THB'
                     WHEN usd <> 0 THEN 'USD'
                     WHEN idr <> 0 THEN 'IDR'
                    ELSE 'NA'
                END AS currency_code,
                CASE WHEN eur <> 0 THEN 'eur_to_thb'
                     WHEN usd <> 0 THEN 'usd_to_thb'
                     WHEN idr <> 0 THEN 'idr_to_thb'
                     WHEN thb <> 0 THEN 'thb_to_thb'
                    ELSE 'other'
                END AS xchange_id, -- To map to xchange_rate table (FK)
                ISNULL(sales_margin_cent, 0.0) AS sales_margin_cent, -- To convert decimal value from percentage
                -- final_sales_values = sales_value * sales_margin_cent
                payment_term,
                remark,
                creator,
                updated_at,
                /* If needed, use later
                HASHBYTES('SHA2_256', CONCAT(
                    actual_readiness_in_week,
                    budget_engineering_in_day,
                    cust_name,
                    budget_service_in_day,
                    calendar_week,
                    cooling,
                    country,
                    creator,
                    cust_po_no,
                    delay,
                    eur,
                    eur_to_thb,
                    first_readiness_in_week,
                    idr,
                    idr_to_thb,
                    date,
                    incoterm,
                    industry_sector,
                    installation_status,
                    installation_value,
                    main_vendor,
                    month_name,
                    order_no,
                    order_type,
                    payment_term,
                    project_name,
                    quotation_ref,
                    remark,
                    sales_margin_calculated,
                    sales_margin_cent,
                    sales_owner,
                    sales_value,
                    sap_code,
                    service_no,
                    shipping_cost,
                    supplier,
                    thb,
                    thb_to_thb,
                    trans_category,
                    usd,
                    usd_to_thb,
                    vendor_order_no,
                    updated_at,
                    -- Start combination --
                    first_readiness_in_week,
                    actual_readiness_in_week,
                    delay,
                    incoterm,
                    shipping_cost,
                    budget_service_in_day,
                    budget_engineering_in_day,
                    installation_status,
                    installation_value
                    )) AS hash_key
                */
                hash_key, -- current NULL -- 
                -- Start combination --
                first_readiness_in_week,
                actual_readiness_in_week,
                delay,
                incoterm,
                shipping_cost,
                budget_service_in_day,
                budget_engineering_in_day,
                installation_status,
                installation_value
        FROM [staging].[stg_transactions_details]
        ) raw
    WHERE NOT EXISTS ( -- Check for inserting no duplicates -- 
        SELECT 1
        FROM [final].[transactions_details] AS final
        WHERE ISNULL(final.order_no, 'NA') = ISNULL(raw.order_no, 'NA')
        AND ISNULL(final.project_name, 'NA') = ISNULL(raw.project_name, 'NA')
        AND ISNULL(final.quotation_ref, 'NA') = ISNULL(raw.quotation_ref, 'NA')
        AND ISNULL(final.cust_po_no, 'NA') = ISNULL(raw.cust_po_no, 'NA')
        AND ISNULL(final.sap_code, 0) = ISNULL(raw.sap_code, 0)
        AND ISNULL(final.date, '9999-12-31') = ISNULL(raw.date, '9999-12-31')
        AND ISNULL(final.vendor_order_no, 'NA') = ISNULL(raw.vendor_order_no, 'NA')
        AND ISNULL(final.supplier, 'NA') = ISNULL(raw.supplier, 'NA')
        AND ISNULL(final.main_vendor, 'NA') = ISNULL(raw.main_vendor, 'NA')
        AND ISNULL(final.industry_sector, 'NA') = ISNULL(raw.industry_sector, 'NA')
        AND ISNULL(final.cooling, 'NA') = ISNULL(raw.cooling, 'NA')
        AND ISNULL(final.sales_owner, 'NA') = ISNULL(raw.sales_owner, 'NA')
        AND ISNULL(final.service_no, 'NA') = ISNULL(raw.service_no, 'NA')
        AND ISNULL(final.order_type, 'NA') = ISNULL(raw.order_type, 'NA')
        AND ISNULL(final.trans_category, 'NA') = ISNULL(raw.trans_category, 'NA')
        AND ISNULL(final.sales_value, 0.0) = ISNULL(raw.sales_value, 0.0)
        AND ISNULL(final.currency_code, 'NA') = ISNULL(raw.currency_code, 'NA')
        AND ISNULL(final.xchange_id, 'NA') = ISNULL(raw.xchange_id, 'NA')
        AND ISNULL(final.sales_margin_cent, 0.0) = ISNULL(raw.sales_margin_cent, 0.0)
        AND ISNULL(final.payment_term, 'NA') = ISNULL(raw.payment_term, 'NA')
        AND ISNULL(final.remark, 'NA') = ISNULL(raw.remark, 'NA')
        AND ISNULL(final.creator, 'NA') = ISNULL(raw.creator, 'NA')
        AND ISNULL(final.updated_at, '9999-12-31') = ISNULL(raw.updated_at, '9999-12-31')
        AND ISNULL(final.hash_key, 'NA') = ISNULL(raw.hash_key, 'NA')
        -- Start combination --
        AND ISNULL(final.first_readiness_in_week, 0) = ISNULL(raw.first_readiness_in_week, 0)
        AND ISNULL(final.actual_readiness_in_week, 0) = ISNULL(raw.actual_readiness_in_week, 0)
        AND ISNULL(final.delay, 0) = ISNULL(raw.delay, 0)
        AND ISNULL(final.incoterm, 'NA') = ISNULL(raw.incoterm, 'NA')
        AND ISNULL(final.shipping_cost, 0.0) = ISNULL(raw.shipping_cost, 0.0)
        AND ISNULL(final.budget_service_in_day, 0) = ISNULL(raw.budget_service_in_day, 0)
        AND ISNULL(final.budget_engineering_in_day, 0) = ISNULL(raw.budget_engineering_in_day, 0)
        AND ISNULL(final.installation_status, 'NA') = ISNULL(raw.installation_status, 'NA')
        AND ISNULL(final.installation_value, 0.0) = ISNULL(raw.installation_value, 0.0)
    )

END