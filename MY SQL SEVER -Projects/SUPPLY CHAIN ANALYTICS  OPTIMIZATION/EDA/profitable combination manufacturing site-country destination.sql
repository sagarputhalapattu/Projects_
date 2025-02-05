SELECT 
	COUNT(*) AS num_shipment,
	manufacturing_site_country,
	country,
	ROUND(
		AVG(TRY_CAST(line_item_value AS DECIMAL(18,2)) * TRY_CAST(line_item_quantity AS INT)) - 
		(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18,2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)))),
		2
	) AS avg_profit
FROM Supply_Chain_Shipment_Pricing_Dataset  
WHERE 
	manufacturing_site_country IS NOT NULL
	AND TRY_CAST(line_item_value AS DECIMAL(18,2)) IS NOT NULL
	AND TRY_CAST(line_item_quantity AS INT) IS NOT NULL
	AND TRY_CAST(freight_cost_usd AS DECIMAL(18,2)) IS NOT NULL
	AND TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)) IS NOT NULL
GROUP BY manufacturing_site_country, country
HAVING COUNT(*) >= 100
ORDER BY avg_profit;


