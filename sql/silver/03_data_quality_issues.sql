TRUNCATE TABLE silver.data_quality_issues RESTART IDENTITY;

INSERT INTO silver.data_quality_issues (
    audit_id,
    error_type,
    column_name,
    issue_count
)
SELECT
    %s,
    error_type,
    column_name,
    issue_count
FROM (
    SELECT 
        'invalid_passenger_count' AS error_type, 
        'passenger_count' AS column_name, 
        COUNT(*) AS issue_count
    FROM bronze.raw_taxi_trips WHERE passenger_count <= 0

    UNION ALL

    SELECT 'invalid_trip_distance', 'trip_distance', COUNT(*)
    FROM bronze.raw_taxi_trips WHERE trip_distance <= 0

    UNION ALL

    SELECT 'invalid_fare_amount', 'fare_amount', COUNT(*)
    FROM bronze.raw_taxi_trips WHERE fare_amount <= 0

    UNION ALL

    SELECT 'invalid_total_amount', 'total_amount', COUNT(*)
    FROM bronze.raw_taxi_trips WHERE total_amount <= 0

    UNION ALL

    SELECT 'invalid_tip_amount', 'tip_amount', COUNT(*)
    FROM bronze.raw_taxi_trips WHERE tip_amount < 0

    UNION ALL

    SELECT 'invalid_datetime', 'tpep_pickup_datetime', COUNT(*)
    FROM bronze.raw_taxi_trips WHERE tpep_pickup_datetime >= tpep_dropoff_datetime

    UNION ALL

    SELECT 'out_of_range_date', 'tpep_pickup_datetime', COUNT(*)
    FROM bronze.raw_taxi_trips
    WHERE tpep_pickup_datetime < DATE '2026-01-01'
       OR tpep_pickup_datetime >= DATE '2026-02-01'
) AS issues;