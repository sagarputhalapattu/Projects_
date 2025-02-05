SELECT
	COUNT(*) AS num_of_shipments,
	shipment_mode,
	managed_by,
	SUM(DATEDIFF(DAY, scheduled_delivery_date, delivered_to_client_date)) AS tot_delay_scheduled_to_delivery,
	ROUND(AVG(DATEDIFF(DAY, scheduled_delivery_date, delivered_to_client_date)),2) AS avg_delay_to_delivery,
	SUM(DATEDIFF(DAY, delivery_recorded_date, delivered_to_client_date)) AS tot_delay_delivered_to_recorded,
	ROUND(AVG(DATEDIFF(DAY, delivery_recorded_date, delivered_to_client_date)),2) AS avg_delay_to_record
FROM Supply_Chain_Shipment_Pricing_Dataset
GROUP BY shipment_mode, managed_by
ORDER BY num_of_shipments DESC;	