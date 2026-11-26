# Data Dictionary

This document describes the schema of the Gold Warehouse and the Semantic Model used for the Power BI dashboards.

## Dimension Tables (Physical Warehouse Tables)

| Table Name | Column Name | Data Type | Description |
| :--- | :--- | :--- | :--- |
| **DimDate** | `date_key` | Date | Primary Key. Calendar date (2025-01-01 to 2025-12-31) |
| | `day` | Integer | Day of the month (1-31) |
| | `day_name` | String | Name of the day (Monday to Sunday) |
| | `month` | Integer | Month number (1-12) |
| | `year` | Integer | Calendar year |
| **DimFX** | `date_key` | Date | Foreign Key to DimDate |
| | `eur_to_usd` | Decimal | The daily exchange rate |
| **DimGDP** | `country_name` | String | Name of the country (United States) |
| | `gdp_usd` | Decimal | Gross Domestic Product in USD |
| | `year` | Integer | Year of the GDP record |
| **DimZone** | `LocationID` | Integer | Taxi zone's unique ID |
| | `Borough` | String | The borough that the taxi zone is located in |
| | `Zone` | String | Taxi zone's name |
| | `service_zone` | String | TLC service zone classification (e.g., Yellow Zone) |

## Fact Tables (Physical Warehouse Tables)

| Table Name | Column Name | Data Type | Description |
| :--- | :--- | :--- | :--- |
| **FactAirQualityDaily** | `date_key` | Date | Foreign Key to DimDate |
| | `location_id` | Integer | Foreign Key to DimZone |
| | `zone` | String | Taxi zone's name |
| | `pollutant_type` | String | Type of pollutant (pm2.5 or no2) |
| | `avg_value` | Decimal | Daily average concentration |
| | `max_value` | Decimal | Daily maximum concentration |
| **FactTaxiDaily** | `date_key` | Date | Foreign Key to DimDate |
| | `location_id` | Integer | Foreign Key to DimZone (Pickup location) |
| | `total_trips` | Integer | Total count of taxi trips for that day and zone |
| | `daily_total_usd` | Decimal | Total daily revenue in USD |
| | `daily_average_usd` | Decimal | Average daily revenue in USD |
| | `daily_total_euro` | Decimal | Total revenue in EUR (Calculated in Semantic Model) |

---

## DAX Measures (Calculated in Semantic Model)

*These are not stored in the Warehouse, but are calculated dynamically in Power BI for analytics.*

| Measure Name | Table | Description |
| :--- | :--- | :--- |
| **Average fare** | FactTaxiDaily | Total revenue divided by total trips |
| **Total fare in usd** | FactTaxiDaily | Sum of all daily revenue in USD |
| **Total fare in euro** | FactTaxiDaily | Sum of all daily revenue in EUR |
| **Revenue % of GDP** | FactTaxiDaily | Total fare divided by Annual GDP |
| **Annual GDP** | DimGDP | Pulls the full-year GDP (2025) |
| **Busiest Zone** | DimZone | Zone with the highest trip count |