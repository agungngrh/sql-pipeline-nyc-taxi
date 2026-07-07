TRUNCATE TABLE gold.payment_behavior_summary;

INSERT INTO gold.payment_behavior_summary (
    payment_type,
    payment_label,
    total_trips,
    total_revenue,
    avg_fare,
    avg_tip,
    tip_rate
)
SELECT
    payment_type,
    payment_label,
    COUNT(trip_id) AS total_trips,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(tip_amount), 2) AS avg_tip,
    ROUND(
        AVG(tip_amount) / NULLIF(AVG(fare_amount), 0) * 100
    , 2) AS tip_rate 
FROM gold.vw_trip_enriched
GROUP BY payment_type, payment_label;