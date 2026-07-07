# Pipeline Execution Report

This document summarizes the output generated after running the ETL pipeline.

---

## Pipeline Summary

| Item | Value |
|------|-------|
| Pipeline Type | Batch ETL |
| Processing Engine | PostgreSQL |
| Orchestration | Python |
| Architecture | Medallion (Bronze, Silver, Gold) |
| Source Datasets | NYC Yellow Taxi Trips, Taxi Zone Lookup |

---

## Execution Result

The pipeline completed successfully and generated all target datasets across the Medallion Architecture layers.

| Layer | Object Name | Records Processed | Status |
| :--- | :--- | ---: | :---: |
| **Bronze** | `bronze.raw_taxi_trips` | 3,724,889 | `SUCCESS` |
| **Bronze** | `bronze.raw_taxi_zones` | 265 | `SUCCESS` |
| **Silver** | `silver.taxi_zones` | 265 | `SUCCESS` |
| **Silver** | `silver.taxi_trips_cleaned` | 2,507,953 | `SUCCESS` |
| **Silver** | `silver.data_quality_issues` | 267,631 | `SUCCESS` |
| **Gold** | `gold.daily_trip_summary` | 31 | `SUCCESS` |
| **Gold** | `gold.hourly_demand_summary` | 24 | `SUCCESS` |
| **Gold** | `gold.zone_performance_summary` | 265 | `SUCCESS` |
| **Gold** | `gold.payment_behavior_summary` | 4 | `SUCCESS` |
| **Gold** | `gold.route_performance_summary` | 32,148 | `SUCCESS` |

## Pipeline Execution Audit

Each pipeline step automatically registers operational metadata and execution metrics inside the `audit.load_audit` tracking table.

| Audit ID | Target Schema | Target Table | Execution Status | Records Processed | Duration (Sec) | Error Message |
| :---: | :--- | :--- | :---: | ---: | ---: | :--- |
| **1** | `bronze` | `raw_taxi_trips` | `SUCCESS` | 3,724,889 | 184.81 | *None* |
| **2** | `bronze` | `raw_taxi_zones` | `SUCCESS` | 265 | 0.10 | *None* |
| **3** | `silver` | `taxi_zones` | `SUCCESS` | 265 | 0.02 | *None* |
| **4** | `silver` | `taxi_trips_cleaned` | `SUCCESS` | 2,507,953 | 69.26 | *None* |
| **5** | `silver` | `data_quality_issues` | `SUCCESS` | 267,631 | 2.12 | *None* |
| **6** | `gold` | `daily_trip_summary` | `SUCCESS` | 31 | 1.29 | *None* |
| **7** | `gold` | `hourly_demand_summary` | `SUCCESS` | 24 | 1.38 | *None* |
| **8** | `gold` | `zone_performance_summary` | `SUCCESS` | 265 | 1.97 | *None* |
| **9** | `gold` | `payment_behavior_summary` | `SUCCESS` | 4 | 1.21 | *None* |
| **10** | `gold` | `route_performance_summary` | `SUCCESS` | 32,148 | 4.35 | *None* |

## Data Quality Issues

The Silver layer automatically monitors and logs records that violate defined business rules into the `silver.data_quality_issues` table, allowing for precise tracking of data anomaly patterns per batch execution.

| Issue ID | Audit ID | Error Type | Affected Column | Issue Count | Detected At |
| :---: | :---: | :--- | :--- | ---: | :---: |
| **1** | 5 | `invalid_passenger_count` | `passenger_count` | 14,787 | 2026-07-07 06:41:34 |
| **2** | 5 | `invalid_trip_distance` | `trip_distance` | 125,738 | 2026-07-07 06:41:34 |
| **3** | 5 | `invalid_fare_amount` | `fare_amount` | 41,545 | 2026-07-07 06:41:34 |
| **4** | 5 | `invalid_total_amount` | `total_amount` | 40,417 | 2026-07-07 06:41:34 |
| **5** | 5 | `invalid_tip_amount` | `tip_amount` | 67 | 2026-07-07 06:41:34 |
| **6** | 5 | `invalid_datetime` | `tpep_pickup_datetime` | 45,070 | 2026-07-07 06:41:34 |
| **7** | 5 | `out_of_range_date` | `tpep_pickup_datetime` | 7 | 2026-07-07 06:41:34 |

Total detected issues: **267,631**

## Gold Mart & Views

After a successful pipeline execution, the following analytical datasets and reporting views are available in the **Gold** layer for business intelligence and reporting.

| Gold Object | Type |
| :--- | :---: |
| `gold.daily_trip_summary` | Table |
| `gold.hourly_demand_summary` | Table |
| `gold.zone_performance_summary` | Table |
| `gold.payment_behavior_summary` | Table |
| `gold.route_performance_summary` | Table |
| `gold.vw_trip_enriched` | View |
| `gold.vw_daily_trip_summary` | View |
