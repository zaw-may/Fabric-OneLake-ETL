/*
Creating Staging Tables
*/

CREATE TABLE [staging].[stg_transactions_details] (
    [date]                      DATE,
    [month_name]                VARCHAR(255), 
    [calendar_week]             INT,
    [cust_name]                 VARCHAR(255),
    [sap_code]                  INT,
    [trans_category]            VARCHAR(255),
    [project_name]              VARCHAR(255),
    [country]                   VARCHAR(255),
    [sales_owner]               VARCHAR(255),
    [quotation_ref]             VARCHAR(255),
    [cust_po_no]                VARCHAR(255),
    [order_no]                  VARCHAR(255),
    [vendor_order_no]           VARCHAR(255),
    [supplier]                  VARCHAR(255),
    [main_vendor]               VARCHAR(255),
    [industry_sector]           VARCHAR(255),
    [cooling]                   VARCHAR(255),
    [service_no]                VARCHAR(255),
    [order_type]                VARCHAR(255),
    [eur]                       FLOAT,
    [eur_to_thb]                FLOAT,
    [thb]                       FLOAT,
    [thb_to_thb]                FLOAT,
    [usd]                       FLOAT,
    [usd_to_thb]                FLOAT,
    [idr]                       FLOAT,
    [idr_to_thb]                FLOAT,
    [sales_value]               FLOAT,
    [sales_margin_cent]         FLOAT,
    [sales_margin_calculated]   FLOAT,
    [first_readiness_in_week]   INT,
    [actual_readiness_in_week]  INT,
    [delay]                     INT,
    [incoterm]                  VARCHAR(255),
    [shipping_cost]             FLOAT,
    [budget_service_in_day]     INT,
    [installation_status]       VARCHAR(255),
    [installation_value]        FLOAT,
    [budget_engineering_in_day] INT,
    [payment_term]              VARCHAR(255),
    [remark]                    VARCHAR(255),
    [creator]                   VARCHAR(255),
    [updated_at]                DATE,
    [hash_key]                  VARCHAR(255)
);
    
CREATE TABLE [pvgrp].[stg_salespersons] (
    code        VARCHAR(100),
    sales_name  VARCHAR(255)
);

CREATE TABLE [pvgrp].[stg_xchange_rate] (
    xchange_id      VARCHAR(100),
    currency_from   VARCHAR(20),
    currency_to     VARCHAR(20),
    xchange_rate    FLOAT, 
    effective_date  DATE,
    valid_from_date DATE,
    valid_to_date   DATE,
    month_name      VARCHAR(20)
);
GO
