CREATE TABLE IF NOT EXISTS audit.load_audit (
    audit_id SERIAL PRIMARY KEY,
    schema_name VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED')),
    record_count BIGINT DEFAULT 0,
    started_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    completed_at TIMESTAMP,
    duration_sec NUMERIC(10, 2),
    error_message TEXT
);


CREATE TABLE IF NOT EXISTS bronze.raw_taxi_trips (
    VendorID INTEGER,
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    passenger_count FLOAT,
    trip_distance FLOAT,
    RatecodeID FLOAT,
    store_and_fwd_flag TEXT,
    PULocationID INTEGER,
    DOLocationID INTEGER,
    payment_type INTEGER,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT,
    Airport_fee FLOAT,
    cbd_congestion_fee FLOAT
);

CREATE TABLE IF NOT EXISTS bronze.raw_taxi_zones (
    LocationID INTEGER,
    Borough TEXT,
    Zone TEXT,
    service_zone TEXT
);


CREATE TABLE IF NOT EXISTS silver.taxi_zones (
    location_id INTEGER PRIMARY KEY,
    borough VARCHAR(50),
    zone VARCHAR(100),
    service_zone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS silver.taxi_trips_cleaned (
    trip_id SERIAL PRIMARY KEY,
    vendor_id INTEGER,
    pickup_datetime TIMESTAMP NOT NULL,
    dropoff_datetime TIMESTAMP NOT NULL,
    passenger_count INTEGER CHECK (passenger_count > 0),
    trip_distance NUMERIC(8,2) CHECK (trip_distance > 0),
    rate_code_id INTEGER,
    store_and_fwd_flag CHAR(1),
    pickup_location_id INTEGER REFERENCES silver.taxi_zones(location_id),
    dropoff_location_id INTEGER REFERENCES silver.taxi_zones(location_id),
    payment_type INTEGER CHECK (payment_type BETWEEN 0 AND 4),
    fare_amount NUMERIC(10,2) CHECK (fare_amount > 0),
    extra NUMERIC(10,2),
    mta_tax NUMERIC(10,2),
    tip_amount NUMERIC(10,2) CHECK (tip_amount >= 0),
    tolls_amount NUMERIC(10,2),
    improvement_surcharge NUMERIC(10,2),
    total_amount NUMERIC(10,2) CHECK (total_amount > 0),
    congestion_surcharge NUMERIC(10,2),
    airport_fee NUMERIC(10,2),
    cbd_congestion_fee NUMERIC(10,2),

    -- feature engineering
    pickup_date DATE NOT NULL,
    pickup_hour INTEGER CHECK (pickup_hour BETWEEN 0 AND 23),
    pickup_day_name VARCHAR(20),
    is_weekend BOOLEAN,
    time_period VARCHAR(20),
    trip_duration_minutes NUMERIC(8,2),
    payment_label VARCHAR(20),
    store_and_fwd_flag_label VARCHAR(30),

    CONSTRAINT check_pickup_before_dropoff CHECK (dropoff_datetime > pickup_datetime)
);


CREATE TABLE IF NOT EXISTS silver.data_quality_issues (
    issue_id SERIAL PRIMARY KEY,
    audit_id INT NOT NULL REFERENCES audit.load_audit(audit_id) ON DELETE RESTRICT,
    error_type VARCHAR(50) NOT NULL,
    column_name VARCHAR(50),
    issue_count BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS gold.daily_trip_summary (
    pickup_date DATE PRIMARY KEY,
    total_trips INT,
    total_revenue NUMERIC(12,2),
    avg_fare NUMERIC(8,2),
    avg_distance NUMERIC(8,2),
    avg_duration NUMERIC(8,2),
    avg_tip NUMERIC(8,2),
    avg_passenger NUMERIC(4,2),
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS gold.hourly_demand_summary (
    pickup_hour INTEGER PRIMARY KEY,
    time_period VARCHAR(20),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_duration NUMERIC(8,2),
    avg_tip NUMERIC(8,2),
    avg_fare NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS gold.zone_performance_summary (
    location_id INTEGER PRIMARY KEY,
    zone VARCHAR(100),
    borough VARCHAR(50),
    total_pickup_trips INTEGER,
    total_dropoff_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_fare NUMERIC(8,2),
    avg_tip NUMERIC(8,2),
    avg_distance NUMERIC(8,2),
    avg_duration NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS gold.payment_behavior_summary (
    payment_type INTEGER PRIMARY KEY,
    payment_label VARCHAR(30),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_tip NUMERIC(8,2),
    avg_fare NUMERIC(8,2),
    tip_rate NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS gold.route_performance_summary (
    pickup_location_id INTEGER,
    dropoff_location_id INTEGER,
    pickup_zone VARCHAR(100),
    dropoff_zone VARCHAR(100),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_duration NUMERIC(8,2),
    avg_fare NUMERIC(8,2),
    avg_distance NUMERIC(8,2),
    PRIMARY KEY (pickup_location_id, dropoff_location_id)
);