-- Q1. Berapa jumlah total trip valid pada Januari 2026?

SELECT
    SUM(total_trips) AS total_trip_januari,
    MIN(pickup_date) AS dari_tanggal,
    MAX(pickup_date) AS sampai_tanggal,
    COUNT(pickup_date) AS jumlah_hari
FROM gold.daily_trip_summary
WHERE pickup_date BETWEEN '2026-01-01' AND '2026-01-31';


-- Q2. Berapa total revenue, average revenue, average fare, dan average tip?
SELECT
    SUM(total_revenue) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_hari,
    ROUND(AVG(avg_fare), 2) AS avg_fare,
    ROUND(AVG(avg_tip), 2) AS avg_tip
FROM gold.daily_trip_summary
WHERE pickup_date BETWEEN '2026-01-01' AND '2026-01-31';



-- Q6. Borough atau zone pickup mana yang memiliki jumlah trip tertinggi?

-- Per Borough
SELECT
    borough,
    SUM(total_pickup_trips) AS total_trips
FROM gold.zone_performance_summary
GROUP BY borough
ORDER BY total_trips DESC;

-- Per Zone (Top 10)
SELECT
    zone,
    borough,
    total_pickup_trips
FROM gold.zone_performance_summary
ORDER BY total_pickup_trips DESC
LIMIT 10;


-- Q7. Zone pickup mana yang menghasilkan total revenue tertinggi?

SELECT
    zone,
    borough,
    total_revenue,
    avg_fare,
    avg_tip
FROM gold.zone_performance_summary
ORDER BY total_revenue DESC
LIMIT 10;


-- Q10. Tampilkan data quality issue terbanyak berdasarkan error_type
SELECT
    error_type,
    column_name,
    issue_count,
    ROUND(
        CAST(issue_count AS NUMERIC)
        / SUM(issue_count) OVER () * 100
    , 2) AS pct_of_total,
    RANK() OVER (
        ORDER BY issue_count DESC
    ) AS rank_issue
FROM silver.data_quality_issues
ORDER BY issue_count DESC;


-- Q11. Cari tanggal atau jam dengan pola data tidak wajar

-- Per Tanggal
SELECT
    pickup_date,
    total_trips,
    ROUND(CAST(AVG(total_trips) OVER () AS NUMERIC), 2) AS avg_trips_keseluruhan,
    total_trips - AVG(total_trips) OVER () AS selisih_dari_rata_rata,
    ROUND(
        (total_trips - AVG(total_trips) OVER ())
        / NULLIF(AVG(total_trips) OVER (), 0) * 100
    , 2) AS pct_deviasi,
    CASE
        WHEN total_trips > AVG(total_trips) OVER () * 1.5 THEN 'Sangat Tinggi'
        WHEN total_trips < AVG(total_trips) OVER () * 0.5 THEN 'Sangat Rendah'
        ELSE 'Normal'
    END AS status_anomali
FROM gold.vw_daily_trip_summary
ORDER BY pct_deviasi DESC;

-- Per Jam
SELECT
    pickup_hour,
    time_period,
    total_trips,
    ROUND(CAST(AVG(total_trips) OVER () AS NUMERIC), 2) AS avg_trips_keseluruhan,
    CASE
        WHEN total_trips > AVG(total_trips) OVER () * 1.5 THEN 'Sangat Tinggi'
        WHEN total_trips < AVG(total_trips) OVER () * 0.5 THEN 'Sangat Rendah'
        ELSE 'Normal'
    END AS status_anomali
FROM gold.hourly_demand_summary
ORDER BY total_trips DESC;


-- Q13. Top 10 pickup zone berdasarkan revenue
WITH zone_ranked AS (
    SELECT
        zone,
        borough,
        total_pickup_trips,
        total_revenue,
        avg_fare,
        avg_tip,
        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM gold.zone_performance_summary
)
SELECT
    revenue_rank,
    zone,
    borough,
    total_pickup_trips,
    total_revenue,
    avg_fare,
    avg_tip
FROM zone_ranked
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- Q14. Zone yang memiliki pickup tinggi tetapi average tip rendah

SELECT
    borough,
    zone,
    total_pickup_trips,
    total_revenue
FROM gold.zone_performance_summary
WHERE total_pickup_trips > 0
ORDER BY total_revenue DESC, borough, zone
LIMIT 10;


-- Q22. Perbandingan revenue hari ini dengan hari sebelumnya menggunakan LAG

SELECT
    pickup_date,
    is_weekend,
    total_revenue AS revenue_hari_ini,
    prev_day_revenue AS revenue_hari_kemarin,
    diff_revenue AS selisih_revenue,
    pct_change_revenue AS persen_perubahan,
    CASE
        WHEN pct_change_revenue > 0  THEN 'Naik'
        WHEN pct_change_revenue < 0  THEN 'Turun'
        WHEN pct_change_revenue = 0  THEN 'Sama'
        ELSE 'Tidak Ada Data Kemarin'
    END AS tren
FROM gold.vw_daily_trip_summary
ORDER BY pickup_date;


-- Q23. Ambil top 3 pickup zone untuk setiap borough

WITH zone_borough_ranked AS (
    SELECT
        borough,
        zone,
        total_pickup_trips,
        total_revenue,
        avg_tip,
        ROW_NUMBER() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        ) AS row_num,
        RANK() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        ) AS rank_num,
        DENSE_RANK() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        ) AS dense_rank_num
    FROM gold.zone_performance_summary
)
SELECT
    borough,
    zone,
    total_pickup_trips,
    total_revenue,
    avg_tip,
    row_num,
    rank_num,
    dense_rank_num
FROM zone_borough_ranked
WHERE dense_rank_num <= 3 
ORDER BY borough, dense_rank_num;