# Customer Churn Analysis

Welcome to the **Customer Churn Analysis** repository! This project focuses on the analysis of customer churn data to generate actionable business insights. The repository leverages Python for data processing, DAX (Data Analysis Expressions) for interactive metrics, and various visualization methods to explore and interpret churn patterns—without the use of machine learning models.

## Table of Contents

- [Project Overview](#project-overview)
- [Folder Structure](#folder-structure)
- [Data Sources](#data-sources)
- [Analysis Workflow](#analysis-workflow)
- [DAX Expressions](#dax-expressions)
- [Visualization](#visualization)
- [How to Run](#how-to-run)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

The goal of this project is to highlight the factors that influence customer churn through descriptive analytics. Key activities include data cleaning, exploratory analysis, and building rich dashboards using Python and DAX.

## Folder Structure

```
data/       # Raw and processed datasets
notebooks/  # Jupyter notebooks for analysis
dax/        # DAX scripts for use in Power BI
reports/    # Power BI dashboards and reports
```

## Data Sources

- **customer_churn.csv**: Main dataset containing customer demographics, service usage, billing information, and churn status.

## Analysis Workflow

1. **Data Cleaning**: Address missing values, fix data types, and remove duplicates.
2. **Exploratory Data Analysis (EDA)**: Use descriptive statistics and visualizations to understand churn rates and segment breakdowns.
3. **DAX-Based Analysis**: Utilize DAX within Power BI to create responsive metrics and visualizations.

## DAX Expressions

Some essential DAX measures used in this repository:

```dax
-- Total Customers
Total Customers = COUNTROWS(Customer)

-- Churned Customers
Churned Customers = CALCULATE([Total Customers], Customer[Churn] = "Yes")

-- Churn Rate
Churn Rate = DIVIDE([Churned Customers], [Total Customers]) * 100

-- Average Monthly Charges
Average MonthlyCharges = AVERAGE(telecom_cleaned[MonthlyCharges])
```

These DAX formulas are used in Power BI dashboards to monitor churn rates and analyze customer segments.

## Visualization

The project includes a variety of charts and dashboards, such as:

- Bar charts comparing churned and retained customers
- Pie charts showing churn distribution across segments
- Distribution plots for Monthly Charges and Tenure
- Churn rate breakdowns by gender, contract type, and more

Power BI dashboards in the `reports/` folder use these DAX measures for interactive exploration.

## How to Run

**SQL Queries:**  
Open the relevant SQL files in MySQL and execute the queries for database analysis.

**Python Analysis:**  
- Open `notebooks/churn_analysis.ipynb` in Jupyter Notebook.
- Run all cells to perform data cleaning and exploratory analysis.

**Power BI Dashboard:**  
- Open `reports/churn_dashboard.pbix` in Power BI Desktop.
- Explore the interactive dashboards powered by DAX measures.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for improvements or enhancements.

## License

This repository is licensed under the MIT License.
