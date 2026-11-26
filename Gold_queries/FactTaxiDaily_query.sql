DROP TABLE IF EXISTS FactTaxiDaily;
CREATE TABLE FactTaxiDaily AS SELECT 
trip_date AS date_key,
PULocationID AS location_id,
COUNT(*) AS total_trips,
AVG(total_amount) AS daily_average_usd,
SUM(total_amount) AS daily_total_usd
FROM Silver_Lakehouse.dbo.taxi_silver
GROUP BY trip_date, PULocationID;
SELECT * FROM FactTaxiDaily;