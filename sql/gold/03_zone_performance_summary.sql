TRUNCATE TABLE gold.zone_performance_summary;

INSERT INTO gold.zone_performance_summary (
    location_id,
    zone,
    borough,
    total_pickup_trips,
    total_dropoff_trips,
    total_revenue,
    avg_fare,
    avg_tip,
    avg_distance,
    avg_duration
)
WITH pickup_stats AS (
    SELECT
        pickup_location_id AS location_id,
        COUNT(trip_id) AS total_pickup_trips,
        SUM(total_amount) total_revenue,
        AVG(fare_amount) AS avg_fare,
        AVG(tip_amount) AS avg_tip,
        AVG(trip_distance) AS avg_distance, 
        AVG(trip_duration_minutes) AS avg_duration
    FROM gold.vw_trip_enriched
    GROUP BY pickup_location_id
),
dropoff_stats AS (
    SELECT
        dropoff_location_id AS location_id,
        COUNT(trip_id) AS total_dropoff_trips
    FROM gold.vw_trip_enriched
    GROUP BY dropoff_location_id
)
SELECT
    z.location_id,
    z.zone,
    z.borough,
    COALESCE(p.total_pickup_trips, 0) AS total_pickup_trips,
    COALESCE(d.total_dropoff_trips, 0) AS total_dropoff_trips,
    COALESCE(ROUND(p.total_revenue::NUMERIC, 2), 0) AS total_revenue,
    COALESCE(ROUND(p.avg_fare::NUMERIC, 2), 0) AS avg_fare,
    COALESCE(ROUND(p.avg_tip::NUMERIC, 2), 0) AS avg_tip,
    COALESCE(ROUND(p.avg_distance::NUMERIC, 2), 0) AS avg_distance,
    COALESCE(ROUND(p.avg_duration::NUMERIC, 2), 0) AS avg_duration 
FROM silver.taxi_zones z
LEFT JOIN pickup_stats  p ON z.location_id = p.location_id
LEFT JOIN dropoff_stats d ON z.location_id = d.location_id;