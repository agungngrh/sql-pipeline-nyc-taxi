TRUNCATE TABLE gold.hourly_demand_summary;

INSERT INTO gold.hourly_demand_summary (
    pickup_hour,
    time_period,
    total_trips,
    total_revenue,
    avg_fare,
    avg_tip,
    avg_duration
)
SELECT
    pickup_hour,
    time_period,
    COUNT(trip_id) AS total_trips,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(tip_amount), 2) AS avg_tip,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration
FROM gold.vw_trip_enriched
GROUP BY pickup_hour, time_period;