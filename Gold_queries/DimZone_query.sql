DROP TABLE IF EXISTS DimZone;
CREATE TABLE DimZone AS SELECT * FROM OPENROWSET(
BULK 'https://onelake.dfs.fabric.microsoft.com/e45d1098-f933-4cbe-b4fd-42338a0c446f/1389c2d4-b8a2-4625-86a3-5e4f8cbb13e6/Files/taxi_zone_lookup/',
FORMAT = 'CSV', HEADER_ROW = TRUE) AS zones;
UPDATE DimZone SET Zone = 'Unknown' WHERE Borough = 'Unknown';
UPDATE DimZone SET Borough = 'Outside of NYC' WHERE Zone = 'Outside of NYC';

-- SELECT d.Zone, SUM(f.total_trips) FROM DimZone d JOIN FactTaxiDaily f ON d.LocationID=f.location_id GROUP BY d.Zone ORDER BY SUM(f.total_trips) DESC;