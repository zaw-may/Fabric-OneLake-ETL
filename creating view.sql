-- Creating View Table
CREATE OR ALTER VIEW [final].[vw_transactions_details]
AS 
SELECT 
    td.*,
    CASE WHEN td.xchange_id = 'thb_to_thb' THEN 
            td.sales_value * 1.0 
        ELSE td.sales_value * xc.xchange_rate 
    END AS cal_sales_value
FROM [final].[transactions_details] td 
LEFT JOIN [final].[xchange_rate] xc
ON xc.xchange_id = td.xchange_id
AND MONTH(td.date) = MONTH(xc.valid_from_date)
LEFT JOIN [final].[date] dt 
ON dt.date = xc.valid_from_date
AND MONTH(td.date) = dt.month_num
WHERE td.date != '9999-12-31'

GO