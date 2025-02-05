use sales 
select *  INTO supply_chain_backup
from Supply_Chain_Shipment_Pricing_Dataset
where 1 = 0; 

insert into supply_chain_backup
select * from Supply_Chain_Shipment_Pricing_Dataset;

select top(5) * 
from supply_chain_backup;

/* Data cleaning
1 . removing duplicate . using a window funcrion to looking for duplicates.
2 . strandardizing Data 
3 . spelling Mistakes 
4.	Null values 
*/ 

-- 1. Removing duplicates
WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id, country, managed_by, shipment_mode, scheduled_delivery_date, delivered_to_client_date, delivery_recorded_date, product_group, sub_classification, vendor, brand, unit_of_measure_per_pack, line_item_quantity, line_item_value, pack_price, unit_price, manifacturing_site_country, weight_kg, freight_cost_usd, line_item_insurance_usd
			ORDER BY id
        ) AS row_num
    FROM Supply_Chain_Shipment_Pricing_Dataset
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
/* 
In the freight_cost_usd column, I identified values that were not valid numerical entries but instead pointed to external documents that we do 
not possess. To clean the data and ensure the integrity of subsequent calculations, I updated these entries to NULL.

*/
SELECT freight_cost_usd
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE freight_cost_usd LIKE 'See%';


UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET freight_cost_usd = null
WHERE freight_cost_usd LIKE 'See%';

-- I did the same for the weight_kg

SELECT weight_kg
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE weight_kg LIKE 'See%';

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET weight_kg = null
WHERE weight_kg LIKE 'See%';

-- I noticed that scheduled_delivery_date had a datetime type, and I want to change it into date type
ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
ADD scheduled_delivery_date_new DATE;

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET scheduled_delivery_date_new = CAST(scheduled_delivery_date AS DATE);

ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
DROP COLUMN scheduled_delivery_date;

EXEC sp_rename 'Supply_Chain_Shipment_Pricing_Dataset.scheduled_delivery_date_new', 'scheduled_delivery_date', 'COLUMN';

-- I did the same for delivered_to_client_date 

ALTER TABLE supply_chain_n
ADD delivered_to_client_date_new DATE;

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET delivered_to_client_date_new = CAST( delivered_to_client_date AS DATE);

ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
DROP COLUMN delivered_to_client_date;

EXEC sp_rename 'Supply_Chain_Shipment_Pricing_Dataset.delivered_to_client_date_new', 'delivered_to_client_date', 'COLUMN';

-- I did the same with delivery_recorded_date
ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
ADD delivery_recorded_date_new DATE;

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET delivery_recorded_date_new = CAST(delivery_recorded_date AS DATE);

ALTER TABLE supply_chain_n
DROP COLUMN delivery_recorded_date;

EXEC sp_rename 'Supply_Chain_Shipment_Pricing_Dataset.delivery_recorded_date_new', 'delivery_recorded_date', 'COLUMN';

-- Found out the line_item_quantity has the wrong data type, varchar instead of int, so I'm changin it

ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
ADD line_item_quantity_int INT;

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET line_item_quantity_int = CAST(line_item_quantity AS INT);

ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
DROP COLUMN line_item_quantity;

EXEC sp_rename 'Supply_Chain_Shipment_Pricing_Dataset.line_item_quantity_int', 'line_item_quantity', 'COLUMN';

-- Same thing happened for freight_cost_ usd

-- Add a new column with DECIMAL type
ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
ADD freight_cost_usd_decimal DECIMAL(18, 2);

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET freight_cost_usd_decimal = TRY_CAST(freight_cost_usd AS DECIMAL(18, 2));

ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
DROP COLUMN freight_cost_usd;

EXEC sp_rename 'Supply_Chain_Shipment_Pricing_Dataset.freight_cost_usd_decimal', 'freight_cost_usd', 'COLUMN';

SELECT ROUND(AVG(TRY_CAST(freight_cost_usd AS DECIMAL(18, 2))), 2) AS avg_freight_cost
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE TRY_CAST(freight_cost_usd AS DECIMAL(18, 2)) IS NOT NULL;



-- Noticed that line_item_value's data type, int, had numbers larger that the maximum value that it can handle, so I've changed the data type

-- Alter the column type to BIGINT
ALTER TABLE Supply_Chain_Shipment_Pricing_Dataset
ALTER COLUMN line_item_value BIGINT;

--  Doing some cleaning I found a row in the dosage_form that said oral powder instead of powder for oral solution, so I put all of them in the same column

UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET dosage_form = 'Powder for oral solution'
WHERE dosage_form = 'Oral powder';

-- Found some rows where it wasn't indicating a country, so I changed them to null
UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET manifacturing_site_country = null
WHERE manifacturing_site_country IN ('L.C.', 'Inc', 'Ltd.', 'Plc');


-- Found rows where it was written 'Weight Captured Separately' so I changed that to null
UPDATE Supply_Chain_Shipment_Pricing_Dataset
SET weight_kg = null
WHERE weight_kg = 'Weight Captured Separately';

--With queries like this I checked if the data was Standardized and Spelling mistakes
SELECT DISTINCT(dosage_form)
FROM Supply_Chain_Shipment_Pricing_Dataset;



/*------NEW*/  -- EDA--
SELECT
	COUNT(*) AS total_shipments,
	SUM(line_item_quantity) AS total_quantity,
	ROUND(AVG(unit_price),2) AS avg_unit_price,
	ROUND(SUM(line_item_value),2) AS total_value,
	ROUND(AVG(TRY_CAST(freight_cost_usd AS decimal(18,2))),2) AS avg_freight_cost
FROM Supply_Chain_Shipment_Pricing_Dataset
WHERE TRY_CAST(freight_cost_usd AS DECIMAL(18, 2)) IS NOT NULL;


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

