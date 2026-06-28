-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS audit;


-- DDL BRONZE TABLES
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

-- DDL SILVER TABLES
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

    CONSTRAINT check_pickup_before_dropoff CHECK (dropoff_datetime > pickup_datetime)
);

-- DDL ISSUES TABLE
CREATE TABLE IF NOT EXISTS silver.data_quality_issues (
    issue_id SERIAL PRIMARY KEY,
    error_type VARCHAR(50) NOT NULL,
    column_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DDL GOLD TABLES
CREATE TABLE IF NOT EXISTS gold.daily_trip_summary (
    pickup_date DATE PRIMARY KEY,
    total_trips INT,
    total_revenue NUMERIC(12,2),
    avg_fare NUMERIC(8,2),
    avg_distance NUMERIC(8,2),
    avg_duration NUMERIC(8,2),
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS gold.hourly_demand_summary (
    pickup_hour INTEGER,
    time_period VARCHAR(20),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_duration NUMERIC(8,2),
    PRIMARY KEY (pickup_hour, time_period)
);

CREATE TABLE IF NOT EXISTS gold.zone_performance_summary (
    location_id INTEGER PRIMARY KEY,
    zone VARCHAR(100),
    borough VARCHAR(50),
    total_pickup_trips  INTEGER,
    total_dropoff_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_fare NUMERIC(8,2),
    avg_tip NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS gold.payment_behavior_summary (
    payment_type INTEGER PRIMARY KEY,
    payment_label VARCHAR(30),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_tip NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS gold.route_performance_summary (
    pickup_location_id INTEGER,
    dropoff_location_id INTEGER,
    pickup_zone VARCHAR(100),
    dropoff_zone VARCHAR(100),
    total_trips INTEGER,
    total_revenue NUMERIC(12,2),
    avg_duration NUMERIC(8,2),
    PRIMARY KEY (pickup_location_id, dropoff_location_id)
);

-- DDL AUDIT TABLES
CREATE TABLE IF NOT EXISTS audit.load_audit (
    audit_id SERIAL PRIMARY KEY,
    schema_name VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED')),
    rows_affected INT DEFAULT 0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

-- INDEXES 
CREATE INDEX IF NOT EXISTS idx_trips_pickup_location
    ON silver.taxi_trips_cleaned (pickup_location_id);

CREATE INDEX IF NOT EXISTS idx_trips_dropoff_location
    ON silver.taxi_trips_cleaned (dropoff_location_id);

CREATE INDEX IF NOT EXISTS idx_trips_pickup_datetime
    ON silver.taxi_trips_cleaned (pickup_datetime);

CREATE INDEX idx_trip_pickup_date
    ON silver.taxi_trips_cleaned(pickup_date);