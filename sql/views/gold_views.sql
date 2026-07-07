CREATE OR REPLACE VIEW gold.vw_trip_enriched AS
SELECT
    t.trip_id,
    t.vendor_id,
    t.pickup_datetime,
    t.dropoff_datetime,
    t.pickup_date,
    t.pickup_hour,
    t.pickup_day_name,
    t.is_weekend,
    t.time_period,
    t.trip_duration_minutes,
    t.pickup_location_id,
    pu.zone AS pickup_zone,
    pu.borough AS pickup_borough,
    t.dropoff_location_id,
    do_.zone AS dropoff_zone,
    do_.borough AS dropoff_borough,
    t.passenger_count,
    t.trip_distance,
    t.payment_type,
    t.payment_label,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.congestion_surcharge,
    t.airport_fee,
    t.cbd_congestion_fee,
    t.total_amount,
    t.store_and_fwd_flag,
    t.store_and_fwd_flag_label,
    t.rate_code_id
FROM silver.taxi_trips_cleaned AS t
INNER JOIN silver.taxi_zones AS pu  ON t.pickup_location_id  = pu.location_id
INNER JOIN silver.taxi_zones AS do_ ON t.dropoff_location_id = do_.location_id;


CREATE OR REPLACE VIEW gold.vw_daily_trip_summary AS
SELECT
    pickup_date,
    is_weekend,
    total_trips,
    total_revenue,
    avg_fare,
    avg_distance,
    avg_duration,
    avg_tip,
    avg_passenger,
    SUM(total_trips)
        OVER (ORDER BY pickup_date) AS running_total_trips,
    SUM(total_revenue)
        OVER (ORDER BY pickup_date) AS running_total_revenue,

    ROUND(AVG(total_trips)
        OVER (
            ORDER BY pickup_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 2) AS ma7_trips,

    ROUND(AVG(total_revenue)
        OVER (
            ORDER BY pickup_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 2) AS ma7_revenue,

    ROUND(AVG(avg_fare)
        OVER (
            ORDER BY pickup_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 2) AS ma7_avg_fare,

    LAG(total_trips, 1)
        OVER (ORDER BY pickup_date) AS prev_day_trips,

    LAG(total_revenue, 1)
        OVER (ORDER BY pickup_date) AS prev_day_revenue,

    LAG(avg_fare, 1)
        OVER (ORDER BY pickup_date) AS prev_day_avg_fare,

    total_trips - LAG(total_trips, 1)
        OVER (ORDER BY pickup_date) AS diff_trips,

    ROUND(
        (total_revenue - LAG(total_revenue, 1)
            OVER (ORDER BY pickup_date))::NUMERIC, 2) AS diff_revenue,

    ROUND(
        (total_trips - LAG(total_trips, 1) OVER (ORDER BY pickup_date))
        / NULLIF(LAG(total_trips, 1) OVER (ORDER BY pickup_date), 0)
        * 100, 2)  AS pct_change_trips,

    ROUND(
        (total_revenue - LAG(total_revenue, 1) OVER (ORDER BY pickup_date))
        / NULLIF(LAG(total_revenue, 1) OVER (ORDER BY pickup_date), 0)
        * 100, 2) AS pct_change_revenue

FROM gold.daily_trip_summary
ORDER BY pickup_date;