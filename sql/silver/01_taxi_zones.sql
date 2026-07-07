TRUNCATE TABLE silver.taxi_trips_cleaned, silver.taxi_zones RESTART IDENTITY;

INSERT INTO silver.taxi_zones (
    location_id,
    borough,
    zone,
    service_zone
)
SELECT DISTINCT ON (LocationID)
    LocationID,
    Borough,
    Zone,
    service_zone
FROM bronze.raw_taxi_zones;