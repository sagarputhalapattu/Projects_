WITH Median AS (
    SELECT 
        shipment_mode,
        managed_by,
        TRY_CAST(freight_cost_usd AS DECIMAL(18, 2)) AS freight_cost_usd,
        TRY_CAST(line_item_insurance_usd AS DECIMAL(18, 2)) AS line_item_insurance_usd,
        TRY_CAST(line_item_value AS DECIMAL(18, 2)) AS line_item_value,
        TRY_CAST(line_item_quantity AS INT) AS line_item_quantity,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(freight_cost_usd AS DECIMAL(18, 2))) OVER (PARTITION BY shipment_mode, managed_by) AS median_freight_cost,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(line_item_insurance_usd AS DECIMAL(18, 2))) OVER (PARTITION BY shipment_mode, managed_by) AS median_insurance_cost,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(line_item_value AS DECIMAL(18, 2))) OVER (PARTITION BY shipment_mode, managed_by) AS median_line_item_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(line_item_quantity AS INT)) OVER (PARTITION BY shipment_mode, managed_by) AS median_line_item_quantity
    FROM Supply_Chain_Shipment_Pricing_Dataset
)
SELECT 
    COUNT(*) AS shipment_count, 
    shipment_mode,
    managed_by,
    AVG(freight_cost_usd) AS avg_freight_cost,
    AVG(line_item_insurance_usd) AS avg_insurance_cost,
    AVG(freight_cost_usd) + AVG(line_item_insurance_usd) AS avg_total_cost,
    AVG(line_item_value) AS avg_line_item_value,
    AVG(line_item_value * line_item_quantity) - (AVG(freight_cost_usd) + AVG(line_item_insurance_usd)) AS avg_profit,
    ROUND(
        (
            AVG(line_item_value * line_item_quantity) - (AVG(freight_cost_usd) + AVG(line_item_insurance_usd))
        ) / NULLIF(AVG(line_item_value), 0)
        * 100, 2
    ) AS avg_profit_margin_percentage,
    MAX(median_freight_cost) AS median_freight_cost,
    MAX(median_insurance_cost) AS median_insurance_cost,
    MAX(median_line_item_value) AS median_line_item_value,
    (MAX(median_line_item_value) * MAX(median_line_item_quantity)) - (MAX(median_freight_cost) + MAX(median_insurance_cost)) AS median_profit,
    ROUND(
        (
            (MAX(median_line_item_value) * MAX(median_line_item_quantity)) - (MAX(median_freight_cost) + MAX(median_insurance_cost))
        ) / NULLIF(MAX(median_line_item_value), 0)
        * 100, 2
    ) AS median_profit_margin_percentage
FROM Median
GROUP BY shipment_mode, managed_by
ORDER BY avg_profit DESC;
