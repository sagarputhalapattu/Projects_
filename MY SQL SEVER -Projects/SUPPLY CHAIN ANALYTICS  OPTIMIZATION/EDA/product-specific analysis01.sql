WITH product_metrics AS
(
	SELECT
		product_group,
		sub_classification,
		COUNT(*) AS num_shipment,
		ROUND(
			AVG(TRY_CAST(line_item_value AS DECIMAL(18,2)) * TRY_CAST(line_item_quantity AS INT)) - 
			(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18,2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)))),
			2
		) AS avg_profit,
		ROUND(
			(
				AVG(TRY_CAST(line_item_value AS DECIMAL(18,2)) * TRY_CAST(line_item_quantity AS INT)) - 
				(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18,2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2))))
			) / COUNT(*),
			2
		) AS avg_profit_per_shipment
	FROM Supply_Chain_Shipment_Pricing_Dataset
	WHERE 
		TRY_CAST(line_item_value AS DECIMAL(18,2)) IS NOT NULL
		AND TRY_CAST(line_item_quantity AS INT) IS NOT NULL
		AND TRY_CAST(freight_cost_usd AS DECIMAL(18,2)) IS NOT NULL
		AND TRY_CAST(line_item_insurance_usd AS DECIMAL(18,2)) IS NOT NULL
	GROUP BY product_group, sub_classification
)
SELECT
	*,
	CASE
		WHEN num_shipment >= 1000 AND avg_profit >= 20000 THEN 'High Volume, High Profit'
		WHEN num_shipment >= 1000 AND avg_profit BETWEEN 4000 AND 20000 THEN 'High Volume, Low Profit'
		WHEN num_shipment < 1000 AND avg_profit >= 20000 THEN 'Low Volume, High Profit'
		ELSE 'Low Volume, Low Profit'
	END AS volume_profit_category
FROM product_metrics
ORDER BY num_shipment DESC, avg_profit DESC;
