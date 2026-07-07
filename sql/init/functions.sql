-- Fungsi untuk menentukan Time Period berdasarkan jam pickup
CREATE OR REPLACE FUNCTION silver.get_time_period(pickup_time TIMESTAMP)
RETURNS VARCHAR AS $$
    SELECT CASE
        WHEN EXTRACT(HOUR FROM pickup_time) BETWEEN 0  AND 5  THEN 'Late Night'
        WHEN EXTRACT(HOUR FROM pickup_time) BETWEEN 6  AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM pickup_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM pickup_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END;
$$ LANGUAGE sql IMMUTABLE;


-- Fungsi untuk mapping Payment Type
CREATE OR REPLACE FUNCTION silver.get_payment_label(payment_code INT)
RETURNS VARCHAR AS $$
    SELECT CASE payment_code
        WHEN 0 THEN 'Unknown'
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        ELSE 'Unknown'
    END;
$$ LANGUAGE sql IMMUTABLE;

-- Fungsi untuk mapping Store and Fwd Flag
CREATE OR REPLACE FUNCTION silver.get_store_and_fwd_label(flag_code VARCHAR)
RETURNS VARCHAR AS $$
    SELECT CASE UPPER(flag_code) 
        WHEN 'Y' THEN 'Store and Forward'
        WHEN 'N' THEN 'Normal'
        ELSE 'Unknown'
    END;
$$ LANGUAGE sql IMMUTABLE;