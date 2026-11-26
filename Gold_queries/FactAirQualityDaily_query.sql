DROP TABLE IF EXISTS FactAirQualityDaily;
CREATE TABLE FactAirQualityDaily AS SELECT 
date_key,
pollutant_type,
zone,
locationid AS location_id,
AVG(pollutant_value) AS avg_value,
MAX(pollutant_value) AS max_value
FROM Silver_Lakehouse.dbo.openaq_silver
GROUP BY date_key, pollutant_type, locationid, zone;

UPDATE FactAirQualityDaily SET zone = 'Unknown', location_id = 264 WHERE location_id IS NULL;
SELECT * FROM FactAirQualityDaily;