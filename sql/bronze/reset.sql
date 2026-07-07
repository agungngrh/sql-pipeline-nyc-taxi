TRUNCATE TABLE bronze.raw_taxi_trips, bronze.raw_taxi_zones;

TRUNCATE TABLE silver.taxi_trips_cleaned, silver.taxi_zones RESTART IDENTITY CASCADE;