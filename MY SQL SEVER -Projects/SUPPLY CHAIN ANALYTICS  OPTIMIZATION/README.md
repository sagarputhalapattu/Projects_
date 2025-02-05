# SUPPLY CHAIN ANALYTICS: SQL-DRIVEN INSIGHTS FOR OPERATIONAL OPTIMIZATION

## 📌 Project Overview
This project focuses on **supply chain analytics** using **SQL** to uncover operational inefficiencies, improve decision-making, and optimize supply chain performance. The dataset used contains shipment-related details, including freight costs, insurance, manufacturing sites, and delivery timelines.

## 🚀 Features & Fixes Implemented
### ✅ **Data Cleaning & Preprocessing**
- Removed **duplicate** records based on key attributes.
- Replaced invalid numerical values (e.g., `See Document`) with `NULL`.
- Standardized **date formats** by converting `datetime` columns to `DATE`.
- Converted **data types**:
  - `freight_cost_usd` from `NVARCHAR` → `DECIMAL(18,2)`
  - `line_item_quantity` from `VARCHAR` → `INT`
  - `line_item_value` from `INT` → `BIGINT`
- Standardized categorical variables (e.g., `Oral powder` → `Powder for oral solution`).

### 📊 **Data Analysis & Insights**
- **Profitability Analysis** by calculating `AVG(profit)`, `AVG(profit margin)`, and `median profit`.
- **Shipment Cost Optimization**:
  - Used `AVG()` and `PERCENTILE_CONT()` for freight cost & insurance analysis.
  - Resolved `NVARCHAR` issues in `AVG()` by ensuring type conversions.
- **Time Series & Trend Analysis**:
  - Monthly moving averages using `WINDOW FUNCTIONS`.
  - Cumulative yearly profits and ranking shipments within each month.
- **Segmenting Supply Chain Performance**:
  - `CASE` statements to classify shipments into `High Volume, High Profit`, `Low Volume, High Profit`, etc.
- **Geographical Insights**:
  - Shipment distribution by `manufacturing_site_country` and `destination country`.

### 🛠 **Bug Fixes & Performance Optimization**
- Fixed `Msg 8114: Error converting data type nvarchar to numeric` in `AVG()` calculations.
- Fixed `Msg 8117: Operand data type nvarchar is invalid for avg operator`.
- Fixed incorrect syntax in `PERCENTILE_CONT()` calculations.
- Used `NULLIF()` to avoid division errors (`AVG(x) / NULLIF(AVG(y), 0)`).
- Improved query performance using **indexes and partitions** where applicable.

## 🔍 Sample Queries
```sql
-- Compute Average Freight Cost
SELECT ROUND(AVG(CAST(freight_cost_usd AS DECIMAL(18,2))), 2) AS avg_freight_cost
FROM Supply_Chain_Shipment_Pricing_Dataset;

-- Rank Monthly Profits
SELECT
    shipment_mode, managed_by, year, month, avg_profit,
    RANK() OVER (PARTITION BY year, month ORDER BY avg_profit DESC) AS profit_rank
FROM shipments_data;
```

## 📊 Insights Derived
- **Freight Costs** have a significant impact on overall profitability.
- **Certain shipment modes** are more cost-effective than others.
- **Optimizing high-cost manufacturing sites** can improve overall margins.
- **Consistent trends in seasonal shipment volumes and profitability.**

## 🚀 How to Use This Project
1. Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/supply-chain-analytics.git
   ```
2. Import the dataset into your SQL environment.
3. Run the SQL scripts in sequence for cleaning, analysis, and visualization.

## 🤝 Contributing
Pull requests are welcome! For significant changes, please open an issue first to discuss the update.

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

