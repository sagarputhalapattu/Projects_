WITH shipments_data AS (
	SELECT
		COUNT(*) AS shipment_count,
		YEAR(delivered_to_client_date) AS year,
		MONTH(delivered_to_client_date) AS month,
		shipment_mode,
		managed_by,
		AVG(TRY_CAST(line_item_value AS DECIMAL(18, 2))) - 
        (AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18, 2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18, 2)))) AS avg_profit,
		
		ROUND(
			((AVG(TRY_CAST(line_item_value AS DECIMAL(18, 2))) - 
			(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18, 2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18, 2))))) 
			/ NULLIF(AVG(TRY_CAST(line_item_value AS DECIMAL(18, 2))), 0)) * 100, 2
		) AS avg_profit_margin_percentage
	FROM Supply_Chain_Shipment_Pricing_Dataset
	GROUP BY YEAR(delivered_to_client_date), MONTH(delivered_to_client_date), shipment_mode, managed_by
	HAVING 
		AVG(TRY_CAST(line_item_value AS DECIMAL(18, 2))) - 
		(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18, 2))) + AVG(TRY_CAST(line_item_insurance_usd AS DECIMAL(18, 2)))) > 0
)
SELECT 
	*,
	AVG(avg_profit) OVER(
		PARTITION BY shipment_mode, managed_by
		ORDER BY year, month
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS three_month_moving_avg,
	
	RANK() OVER(
		PARTITION BY year, month
		ORDER BY avg_profit DESC
	) AS profit_rank_within_month,
	
	SUM(avg_profit) OVER(
		PARTITION BY year, shipment_mode, managed_by
		ORDER BY month
	) AS cumulative_yearly_profit,
	
	avg_profit - AVG(avg_profit) OVER (
		PARTITION BY shipment_mode, managed_by
	) AS diff_from_overall_avg
FROM shipments_data
ORDER BY year, month, shipment_mode, managed_by;
