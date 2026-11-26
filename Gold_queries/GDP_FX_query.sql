DROP TABLE IF EXISTS DimGDP;
CREATE TABLE DimGDP AS SELECT * FROM Silver_Lakehouse.dbo.gdp_silver;
DROP TABLE IF EXISTS DimFX;
CREATE TABLE DimFX AS SELECT date_key, eur_to_usd FROM Silver_Lakehouse.dbo.fx_silver WHERE date_key >= '2025-01-01' AND date_key<'2026-01-01';
SELECT * FROM DimFX;