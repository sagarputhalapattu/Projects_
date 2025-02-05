USE sales

SELECT
	COUNT(*) AS total_shipments,
	SUM(line_item_quantity) AS total_quantity,
	ROUND(AVG(unit_price),2) AS avg_unit_price,
	ROUND(SUM(line_item_value),2) AS total_value,
	ROUND(AVG(TRY_CAST(freight_cost_usd AS decimal(18,2))),2) AS avg_freight_cost
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE TRY_CAST(freight_cost_usd AS DECIMAL(18, 2)) IS NOT NULL;
