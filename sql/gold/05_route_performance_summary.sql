TRUNCATE TABLE gold.route_performance_summary;

INSERT INTO gold.route_performance_summary (
    pickup_location_id,
    dropoff_location_id,
    pickup_zone,
    dropoff_zone,
    total_trips,
    total_revenue,
    avg_fare,
    avg_distance,
    avg_duration
)
SELECT
    pickup_location_id,
    dropoff_location_id,
    pickup_zone,
    dropoff_zone,
    COUNT(trip_id) AS total_trips,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration
FROM gold.vw_trip_enriched
GROUP BY
    pickup_location_id,
    dropoff_location_id,
    pickup_zone,
    dropoff_zone;