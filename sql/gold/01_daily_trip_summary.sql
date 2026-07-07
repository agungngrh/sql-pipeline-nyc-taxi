TRUNCATE TABLE gold.daily_trip_summary;

INSERT INTO gold.daily_trip_summary (
    pickup_date,
    total_trips,
    total_revenue,
    avg_fare,
    avg_distance,
    avg_duration,
    avg_tip,           
    avg_passenger,     
    is_weekend
)
SELECT
    pickup_date,
    COUNT(trip_id) AS total_trips,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(AVG(tip_amount), 2) AS avg_tip,       
    ROUND(AVG(passenger_count), 2) AS avg_passenger, 
    is_weekend

FROM gold.vw_trip_enriched
GROUP BY pickup_date, is_weekend;