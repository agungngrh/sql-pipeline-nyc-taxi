TRUNCATE TABLE silver.taxi_trips_cleaned RESTART IDENTITY;

INSERT INTO silver.taxi_trips_cleaned (
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    rate_code_id,
    store_and_fwd_flag,
    pickup_location_id,
    dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    cbd_congestion_fee,
    pickup_date,
    pickup_hour,
    pickup_day_name,
    is_weekend,
    trip_duration_minutes,
    time_period,
    payment_label,
    store_and_fwd_flag_label
)
SELECT
    t.VendorID,
    t.tpep_pickup_datetime,
    t.tpep_dropoff_datetime,
    t.passenger_count,
    t.trip_distance,
    t.RatecodeID,
    t.store_and_fwd_flag,
    t.PULocationID,
    t.DOLocationID,
    t.payment_type,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.total_amount,
    t.congestion_surcharge,
    t.Airport_fee,
    t.cbd_congestion_fee,

    CAST(t.tpep_pickup_datetime AS DATE) AS pickup_date,
    CAST(EXTRACT(HOUR FROM t.tpep_pickup_datetime) AS INT) AS pickup_hour,
    TRIM(TO_CHAR(t.tpep_pickup_datetime, 'Day')) AS pickup_day_name,
    EXTRACT(DOW FROM t.tpep_pickup_datetime) IN (0, 6) AS is_weekend,
    EXTRACT(EPOCH FROM (t.tpep_dropoff_datetime - t.tpep_pickup_datetime)) / 60 AS trip_duration_minutes,

    silver.get_time_period(t.tpep_pickup_datetime) AS time_period,
    silver.get_payment_label(t.payment_type) AS payment_label,
    silver.get_store_and_fwd_label(t.store_and_fwd_flag) AS store_and_fwd_flag_label

FROM bronze.raw_taxi_trips t
LEFT JOIN silver.taxi_zones AS pu ON t.PULocationID = pu.location_id
LEFT JOIN silver.taxi_zones AS do_ ON t.DOLocationID = do_.location_id
WHERE
    t.passenger_count IS NOT NULL
    AND t.passenger_count > 0
    AND t.trip_distance > 0
    AND t.fare_amount > 0
    AND t.total_amount > 0
    AND t.tip_amount >= 0
    AND t.tpep_pickup_datetime >= DATE '2026-01-01'
    AND t.tpep_pickup_datetime < DATE '2026-02-01'
    AND t.tpep_pickup_datetime < t.tpep_dropoff_datetime;