### Disclaimer
This repository represents a real-world project. The information contained within is solely for demonstration purposes, showcasing a successfully completed project. No sensitive data, including Personally Identifiable Information (PII), client information, or any other confidential materials, has been used or included in this repository. Any resemblance to real individuals, companies, or sensitive data is purely coincidental.

### Objective 
Transition from local Excel-based data reporting to automated, dynamic reporting using Power BI with Fabric Analytics Data Pipeline to reduce manual effort and improve accuracy.

### Technologies
Microsoft Fabric Analytics, Data Pipeline, Data Flow Gen2, Power BI, OneLake Hub, SQL, On-premises Data Gateway, Advanced Excel Macro VBA

### Process Flow
<img width="621" alt="fabric-analytics-pipeline" src="https://github.com/user-attachments/assets/9da35cb7-1950-403d-b5c2-c19ee05440b8" />

 ### Process Step-by-Step
 > To achieve the desired format for Excel data files in OneDrive, I utilize a Macro VBA script, generating the template to be completed with a single button click.
 
 > For the sake of data accessibility and security, I have enabled On-premises Data Gateway. This allows users to schedule automatic data refreshes seamlessly.
 
 > In Data Flow Gen2, data is ingested using the Get Data feature. During this process, some validation and transformation steps are performed, including:
 >  * Data type validation to ensure consistency.
 >  * Error detection and correction for invalid or malformed entries.
 >  * Typo error checks to address inconsistencies.
 >  * Null value handling to manage missing data effectively.
 >  * Filtering unnecessary columns and rows to optimize the dataset.

 > Once these checks are complete, the processed data is sent to the designated Lakehouse destination for storage and further processing.

 > The incoming data from the lake house is initially stored in staging tables within the data warehouse. During each auto-refresh, a stored procedure is applied to filter the data and prevent duplicates.

 > When transitioning data from staging tables to final tables, necessary calculations are performed, and additional data fields are added as required. Deduplication is also performed during this process.

 > I utilize copy activity, data flow activity, and stored procedure activity as key components in my data pipeline processes.

 > In the final step, I create data view tables from the finalized tables for the purpose of access control and optimization, generate a report using Power BI Desktop through the SQL Analytics endpoint, and publish it as a dashboard on the Power BI Service.

 > [!NOTE]
 > If your data growth rate is slow and the data volume is small, you have other options: either connect the data directly from OneDrive to Power BI or integrate it directly into the data warehouse.


 > [!TIP]
 > You can also change the below pipeline structure.

<img width="576" alt="data-pipeline-another-structure" src="https://github.com/user-attachments/assets/2793b9fb-923a-476c-814d-209798009b3a">


