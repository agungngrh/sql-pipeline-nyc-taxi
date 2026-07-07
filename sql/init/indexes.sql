-- INDEXES 
CREATE INDEX IF NOT EXISTS idx_trips_pickup_location
    ON silver.taxi_trips_cleaned (pickup_location_id);

CREATE INDEX IF NOT EXISTS idx_trips_dropoff_location
    ON silver.taxi_trips_cleaned (dropoff_location_id);

CREATE INDEX IF NOT EXISTS idx_trip_pickup_date
    ON silver.taxi_trips_cleaned(pickup_date);