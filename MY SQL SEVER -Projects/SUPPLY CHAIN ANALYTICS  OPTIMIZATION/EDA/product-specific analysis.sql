SELECT
	COUNT(*) AS num_shipment,
	country, 
	ROUND(
		AVG(TRY_CAST(line_item_value AS DECIMAL(18,2)) * TRY_CAST(line_item_quantity AS INT)) - 
		(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18,2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)))),
		2
	) AS avg_profit
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE 
	TRY_CAST(line_item_value AS DECIMAL(18,2)) IS NOT NULL AND
	TRY_CAST(line_item_quantity AS INT) IS NOT NULL AND
	TRY_CAST(freight_cost_usd AS DECIMAL(18,2)) IS NOT NULL AND
	TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)) IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 100
ORDER BY avg_profit DESC;


-- Check for invalid values in line_item_value
SELECT DISTINCT line_item_value 
FROM Supply_Chain_Shipment_Pricing_Dataset 
WHERE TRY_CAST(line_item_value AS DECIMAL(18,2)) IS NULL;

-- Check for invalid values in freight_cost_usd
SELECT DISTINCT freight_cost_usd 
FROM Supply_Chain_Shipment_Pricing_Dataset 
WHERE TRY_CAST(freight_cost_usd AS DECIMAL(18,2)) IS NULL;

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET freight_cost_usd = NULL
WHERE freight_cost_usd LIKE 'See%';
