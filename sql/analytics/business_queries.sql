-- =============================================
-- BUSINESS QUERIES
-- Tema yang dipilih:
-- [Basic]          Q1, Q2
-- [Location]       Q6, Q7
-- [Data Quality]   Q10, Q11
-- [CTE & Advanced] Q13, Q14
-- [Windowing]      Q22, Q23
-- =============================================


-- =============================================
-- BASIC QUERY
-- =============================================

-- Q1. Berapa jumlah total trip valid pada Januari 2026?
-- Sumber : gold.daily_trip_summary
-- Index  : idx_trip_pickup_date (pickup_date dipakai di WHERE)
-- =============================================
SELECT
    SUM(total_trips)                        AS total_trip_januari,
    MIN(pickup_date)                        AS dari_tanggal,
    MAX(pickup_date)                        AS sampai_tanggal,
    COUNT(pickup_date)                      AS jumlah_hari
FROM gold.daily_trip_summary
WHERE pickup_date BETWEEN '2026-01-01' AND '2026-01-31';


-- Q2. Berapa total revenue, average revenue, average fare, dan average tip?
-- Sumber : gold.daily_trip_summary
-- Index  : idx_trip_pickup_date (pickup_date dipakai di WHERE)
-- =============================================
SELECT
    SUM(total_revenue)                      AS total_revenue,
    ROUND(AVG(total_revenue), 2)            AS avg_revenue_per_hari,
    ROUND(AVG(avg_fare), 2)                 AS avg_fare,
    ROUND(AVG(avg_tip), 2)                  AS avg_tip
FROM gold.daily_trip_summary
WHERE pickup_date BETWEEN '2026-01-01' AND '2026-01-31';


-- =============================================
-- JOIN & LOCATION ANALYSIS
-- =============================================

-- Q6. Borough atau zone pickup mana yang memiliki jumlah trip tertinggi?
-- Sumber : gold.zone_performance_summary
-- Index  : idx_trips_pickup_location (dipakai saat view di-query ke silver)
-- =============================================

-- Per Borough
SELECT
    borough,
    SUM(total_pickup_trips)                 AS total_trips
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
-- Sumber : gold.zone_performance_summary
-- Index  : idx_trips_pickup_location (dipakai saat view di-query ke silver)
-- =============================================
SELECT
    zone,
    borough,
    total_revenue,
    avg_fare,
    avg_tip
FROM gold.zone_performance_summary
ORDER BY total_revenue DESC
LIMIT 10;


-- =============================================
-- DATE, TIME & DATA QUALITY
-- =============================================

-- Q10. Tampilkan data quality issue terbanyak berdasarkan error_type
-- Sumber : silver.data_quality_issues
-- =============================================
SELECT
    error_type,
    column_name,
    issue_count,
    -- persentase tiap error dari total keseluruhan issue
    ROUND(
        CAST(issue_count AS NUMERIC)
        / SUM(issue_count) OVER () * 100
    , 2)                                    AS pct_of_total,
    -- ranking error terbanyak
    RANK() OVER (
        ORDER BY issue_count DESC
    )                                       AS rank_issue
FROM silver.data_quality_issues
ORDER BY issue_count DESC;


-- Q11. Cari tanggal atau jam dengan pola data tidak wajar
--      (trip count sangat rendah/tinggi dibanding rata-rata)
-- Sumber : gold.vw_daily_trip_summary
-- Index  : idx_trip_pickup_date (dipakai via vw_daily_trip_summary)
-- =============================================

-- Per Tanggal
SELECT
    pickup_date,
    total_trips,
    ROUND(CAST(AVG(total_trips) OVER () AS NUMERIC), 2)     AS avg_trips_keseluruhan,
    total_trips - AVG(total_trips) OVER ()           AS selisih_dari_rata_rata,
    ROUND(
        (total_trips - AVG(total_trips) OVER ())
        / NULLIF(AVG(total_trips) OVER (), 0) * 100
    , 2)                                             AS pct_deviasi,
    CASE
        WHEN total_trips > AVG(total_trips) OVER () * 1.5 THEN 'Sangat Tinggi'
        WHEN total_trips < AVG(total_trips) OVER () * 0.5 THEN 'Sangat Rendah'
        ELSE 'Normal'
    END                                              AS status_anomali
FROM gold.vw_daily_trip_summary
ORDER BY pct_deviasi DESC;

-- Per Jam
SELECT
    pickup_hour,
    time_period,
    total_trips,
    ROUND(CAST(AVG(total_trips) OVER () AS NUMERIC), 2)      AS avg_trips_keseluruhan,
    CASE
        WHEN total_trips > AVG(total_trips) OVER () * 1.5 THEN 'Sangat Tinggi'
        WHEN total_trips < AVG(total_trips) OVER () * 0.5 THEN 'Sangat Rendah'
        ELSE 'Normal'
    END                                              AS status_anomali
FROM gold.hourly_demand_summary
ORDER BY total_trips DESC;


-- =============================================
-- CTE, SUBQUERY & ADVANCED JOIN
-- =============================================

-- Q13. Top 10 pickup zone berdasarkan revenue
-- Sumber : gold.zone_performance_summary
-- Index  : idx_trips_pickup_location (dipakai saat view di-query ke silver)
-- =============================================
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
        )                                   AS revenue_rank
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
-- Definisi:
--   pickup tinggi  = total_pickup_trips > rata-rata semua zone
--   avg tip rendah = avg_tip < rata-rata semua zone
-- Sumber : gold.zone_performance_summary
-- Index  : idx_trips_pickup_location, idx_trips_dropoff_location
-- =============================================
WITH zone_stats AS (
    SELECT
        zone,
        borough,
        total_pickup_trips,
        avg_tip,
        -- rata-rata keseluruhan sebagai threshold
        AVG(total_pickup_trips) OVER ()     AS avg_pickup_all_zones,
        AVG(avg_tip) OVER ()                AS avg_tip_all_zones
    FROM gold.zone_performance_summary
)
SELECT
    zone,
    borough,
    total_pickup_trips,
    ROUND(CAST(avg_pickup_all_zones AS NUMERIC), 0) AS avg_pickup_threshold,
    avg_tip,
    ROUND(CAST(avg_tip_all_zones AS NUMERIC), 2)    AS avg_tip_threshold
FROM zone_stats
WHERE total_pickup_trips > avg_pickup_all_zones  -- pickup tinggi
  AND avg_tip < avg_tip_all_zones                -- tip rendah
ORDER BY total_pickup_trips DESC;


-- =============================================
-- RANKING & WINDOWING
-- =============================================

-- Q22. Perbandingan revenue hari ini dengan hari sebelumnya menggunakan LAG
-- Sumber : gold.vw_daily_trip_summary
-- Index  : idx_trip_pickup_date (dipakai via vw_daily_trip_summary)
-- =============================================
SELECT
    pickup_date,
    is_weekend,
    total_revenue                               AS revenue_hari_ini,
    prev_day_revenue                            AS revenue_hari_kemarin,
    diff_revenue                                AS selisih_revenue,
    pct_change_revenue                          AS persen_perubahan,
    CASE
        WHEN pct_change_revenue > 0  THEN 'Naik'
        WHEN pct_change_revenue < 0  THEN 'Turun'
        WHEN pct_change_revenue = 0  THEN 'Sama'
        ELSE 'Tidak Ada Data Kemarin'
    END                                         AS tren
FROM gold.vw_daily_trip_summary
ORDER BY pickup_date;


-- Q23. Ambil top 3 pickup zone untuk setiap borough
--      menggunakan ROW_NUMBER, RANK, dan DENSE_RANK
-- Sumber : gold.zone_performance_summary
-- Index  : idx_trips_pickup_location
-- =============================================
WITH zone_borough_ranked AS (
    SELECT
        borough,
        zone,
        total_pickup_trips,
        total_revenue,
        avg_tip,
        -- ROW_NUMBER: tidak ada tie, selalu unik
        ROW_NUMBER() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        )                                       AS row_num,
        -- RANK: ada tie, nomor berikutnya di-skip
        RANK() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        )                                       AS rank_num,
        -- DENSE_RANK: ada tie, nomor berikutnya tidak di-skip
        DENSE_RANK() OVER (
            PARTITION BY borough
            ORDER BY total_revenue DESC
        )                                       AS dense_rank_num
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
WHERE dense_rank_num <= 3           -- ambil top 3 per borough
ORDER BY borough, dense_rank_num;