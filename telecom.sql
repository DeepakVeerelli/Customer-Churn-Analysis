CREATE DATABASE IF NOT EXISTS telecom;
USE telecom;

CREATE TABLE customers (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen TINYINT,
    Partner VARCHAR(5)
);


CREATE TABLE services (
    customerID VARCHAR(20),
    PhoneService VARCHAR(10),
    InternetService VARCHAR(20),
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);

CREATE TABLE billing (
    customerID VARCHAR(20),
    Contract VARCHAR(20),
    MonthlyCharges DECIMAL(10, 2),
    tenure INT,
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);
CREATE TABLE churn_info (
    customerID VARCHAR(20),
    Churn VARCHAR(5),
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);


-- Sample Queries

select * from customers 
limit 10;

select * from billing
limit 10;

select * from churn_info
limit 10;

select * from services;

select count(*) from customers;

select gender, COUNT(*) AS Count 
from  customers
group by gender;

select PhoneService, COUNT(*) AS Count 
from services
group by PhoneService;

Select InternetService, COUNT(*) AS Count
from services
group by InternetService;

select ROUND(AVG(tenure), 2) AS AvgTenure
from billing;

select Contract, COUNT(*) AS Count
from billing
group by Contract;


select Churn,COUNT(*) AS customer_count
from churn_info
group by  Churn;

select
    c.gender,
    ci.Churn,
    COUNT(*) AS total
from customers c
join churn_info ci ON c.customerID = ci.customerID
group by c.gender, ci.Churn;

select COUNT(*) AS total_rows, COUNT(MonthlyCharges) AS non_null_rows
from billing;

select DISTINCT gender, COUNT(*) FROM customers GROUP BY gender;

select
    ci.Churn,
    ROUND(AVG(b.MonthlyCharges), 1) AS avg_monthly_charges
from billing b
join churn_info ci ON b.customerID = ci.customerID
group by ci.Churn;

select MIN(MonthlyCharges), MAX(MonthlyCharges), AVG(MonthlyCharges) from billing;

select 
    ci.Churn,
    ROUND(AVG(b.tenure), 1) AS avg_tenure
From billing b
join churn_info ci ON b.customerID = ci.customerID
group by ci.Churn;

select 
    c.gender,
    b.Contract,
    ci.Churn,
    COUNT(*) AS total
from customers c
join billing b ON c.customerID = b.customerID
join churn_info ci ON c.customerID = ci.customerID
group by c.gender, b.Contract, ci.Churn;



-- Consolidate Customer Data 

select
    c.customerID,
    c.gender,
    c.SeniorCitizen,
    c.Partner,
    s.PhoneService,
    s.InternetService
from customers c 
left join services s ON c.customerID = s.customerID;

-- Calculate Customer Tenure 

Select
    customerID,
    tenure
From billing ;

-- Acquire Usage Data

Select
    customerID,
    MAX(MonthlyCharges) AS LatestMonthlyCharge,
    COUNT(DISTINCT Contract) AS NumContractsUsed 
From
    billing
group by
    customerID;
    
-- TenureGroup

Select
    customerID,
    tenure,
    MonthlyCharges,
    
    CASE
        WHEN tenure <= 6 THEN '0-6 Months'
        WHEN tenure > 6 AND tenure <= 12 THEN '7-12 Months'
        WHEN tenure > 12 AND tenure <= 24 THEN '13-24 Months'
        WHEN tenure > 24 AND tenure <= 48 THEN '25-48 Months'
        WHEN tenure > 48 THEN '49+ Months'
        ELSE 'Unknown' 
    END AS TenureGroup
From billing;



-- ChargeTier based on MonthlyCharges

Select
    customerID,
    tenure,
    MonthlyCharges,
    
    CASE
        WHEN MonthlyCharges < 50 THEN 'Low Charge'
        WHEN MonthlyCharges >= 50 AND MonthlyCharges < 100 THEN 'Medium Charge'
        WHEN MonthlyCharges >= 100 THEN 'High Charge'
        ELSE 'Unknown' 
    END AS ChargeTier
from
    billing;
    
-- Service Bundle Type

Select customerID,PhoneService,InternetService,
    
CASE
        WHEN PhoneService = 'Yes' AND InternetService = 'No' THEN 'Phone Only'
        WHEN PhoneService = 'No' AND InternetService != 'No' THEN 'Internet Only'
        WHEN PhoneService = 'Yes' AND InternetService != 'No' THEN 'Phone & Internet'
        ELSE 'No Service'
    END AS ServiceBundle

from Services;

-- Metrics for Cohort Retention

With CustomerTenureAndStartDate AS (
    Select
        b.customerID,
        b.tenure,
        
        DATE_SUB(CURRENT_DATE(), INTERVAL b.tenure MONTH) AS ContractStartDateApprox
    From
        billing b
),
CustomerAcquisitionMonth AS (
    Select
        cta.customerID,
        DATE_FORMAT(cta.ContractStartDateApprox, '%Y-%m') AS AcquisitionMonth
    from
        CustomerTenureAndStartDate cta
)
Select
    AcquisitionMonth,
    COUNT(customerID) AS NumberOfCustomersAcquired
from
    CustomerAcquisitionMonth
group by
    AcquisitionMonth
order by
    AcquisitionMonth;    

-- Internet and Phone Service Combos

select
    CASE
        WHEN s.PhoneService = 'Yes' AND s.InternetService <> 'No' THEN 'Phone + Internet'
        WHEN s.PhoneService = 'Yes' AND s.InternetService = 'No' THEN 'Phone Only'
        WHEN s.PhoneService = 'No' AND s.InternetService <> 'No' THEN 'Internet Only'
        WHEN s.PhoneService = 'No' AND s.InternetService = 'No' THEN 'Neither'
        ELSE 'Unknown'
    END AS ServiceCombination,
    COUNT(*) as CustomersCount
from services s
join churn_info ci ON s.customerID = ci.customerID 
group by ServiceCombination
order by CustomersCount desc;



    
-- Churn Distribution by Tenure Buckets

select
    CASE
        WHEN b.tenure <= 12 THEN '0-1 Year'
        WHEN b.tenure <= 24 THEN '1-2 Years'
        WHEN b.tenure <= 48 THEN '2-4 Years'
        ELSE '4+ Years'
    END AS TenureGroup,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
from
    billing b
join churn_info ci on b.customerID = ci.customerID
group by TenureGroup
order by TenureGroup;

    
-- Churn Rate by InternetService

Select
    s.InternetService,
    COUNT(c.customerID) AS TotalCustomers,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    (SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(c.customerID)) AS ChurnRatePct
from
    customers c
join
    services s ON c.customerID = s.customerID
left join
    churn_info ci ON c.customerID = ci.customerID
group by
    s.InternetService
order by
    ChurnRatePct desc;
    
-- Churn Trend Over Tenure   

Select
    tenure,
    COUNT(*) AS Total,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned
from billing b
join churn_info ci on b.customerID = ci.customerID
group by tenure
order by tenure;


-- Churn Rate by Gender

Select
    c.gender,
    COUNT(c.customerID) AS TotalCustomers,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    (SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(c.customerID)) AS ChurnRatePct
from
    customers c
join
    services s ON c.customerID = s.customerID
left join
    churn_info ci ON c.customerID = ci.customerID
group by
    c.gender
order by
    ChurnRatePct desc;    
    
select
    c.gender,
    ci.Churn,
    COUNT(*) AS total
from customers c
join churn_info ci ON c.customerID = ci.customerID
group by c.gender, ci.Churn;
    
-- Churn Rate by Contract Type
    
Select
    b.contract,
    COUNT(c.customerID) AS TotalCustomers,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    (SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(c.customerID)) AS ChurnRatePct
from
    customers c
join
    billing b ON b.customerID = c.customerID
left join
    churn_info ci ON c.customerID = ci.customerID
group by
    b.contract
order by
    ChurnRatePct desc;    
    
-- Churn Rate by Senior Citizen Status

select 
    c.SeniorCitizen,
    ci.Churn,
    COUNT(*) AS total
FROM customers c
JOIN churn_info ci ON c.customerID = ci.customerID
GROUP BY c.SeniorCitizen, ci.Churn;

-- Churn Rate: Senior Citizens vs Non-Senior

SELECT
    c.SeniorCitizen,
    COUNT(*) AS Total,
    SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN ci.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
FROM
    customers c
JOIN churn_info ci ON c.customerID = ci.customerID
GROUP BY c.SeniorCitizen;


-- Customers Likely to Churn (tenure < 6 months)

select
    c.customerID,
    b.tenure,
    b.Contract,
    ci.Churn
from customers c
join billing b ON c.customerID = b.customerID
join churn_info ci ON c.customerID = ci.customerID
where b.tenure < 6;

-- Customers Who Remained Loyal

select 
    c.customerID
from customers c
join billing b ON c.customerID = b.customerID
join churn_info ci ON c.customerID = ci.customerID
where b.tenure > 24 AND ci.Churn = 'No';









    

