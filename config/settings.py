import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()


class Config:
    """
    Application configuration for the ETL pipeline.
    Stores database settings, filesystem paths,
    SQL file locations, and pipeline stages definition.
    """

    HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    PORT: int = int(os.getenv("POSTGRES_PORT", "5432"))
    USER: str = os.getenv("POSTGRES_USER", "postgres")
    PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "")
    DATABASE: str = os.getenv("POSTGRES_DB", "ny_taxi_db")

    TAXI_TRIPS_URL: str = os.getenv(
        "TAXI_TRIPS_URL",
        "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2026-01.parquet",
    )

    TAXI_ZONES_URL: str = os.getenv(
        "TAXI_ZONES_URL",
        "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv",
    )

    # Project Directories
    BASE_DIR = Path(__file__).resolve().parent.parent

    RAW_DIR = BASE_DIR / "data" / "raw"
    LOG_DIR = BASE_DIR / "logs"
    SQL_DIR = BASE_DIR / "sql"

    INIT_SQL_DIR = SQL_DIR / "init"
    BRONZE_SQL_DIR = SQL_DIR / "bronze"
    SILVER_SQL_DIR = SQL_DIR / "silver"
    GOLD_SQL_DIR = SQL_DIR / "gold"
    VIEWS_SQL_DIR = SQL_DIR / "views"
    ANALYTICS_SQL_DIR = SQL_DIR / "analytics"

    # Dataset Files
    TAXI_FILE = RAW_DIR / "taxi_trips_2026_01.parquet"
    ZONE_FILE = RAW_DIR / "taxi_zone_lookup.csv"

    # Database Init SQL
    SCHEMAS_SQL = INIT_SQL_DIR / "schemas.sql"
    TABLES_SQL = INIT_SQL_DIR / "tables.sql"
    INDEXES_SQL = INIT_SQL_DIR / "indexes.sql"
    FUNCTIONS_SQL = INIT_SQL_DIR / "functions.sql"

    DATABASE_INIT_SQL_FILES = [
        SCHEMAS_SQL,
        FUNCTIONS_SQL,
        TABLES_SQL,
        INDEXES_SQL,
    ]

    # Bronze Layer
    BRONZE_RESET_SQL = BRONZE_SQL_DIR / "reset.sql"

    # Silver Layer
    SILVER_TAXI_ZONES_SQL = SILVER_SQL_DIR / "01_taxi_zones.sql"
    SILVER_TAXI_TRIPS_SQL = SILVER_SQL_DIR / "02_taxi_trips_cleaned.sql"

    SILVER_LAYER = [
        (SILVER_TAXI_ZONES_SQL, "silver.taxi_zones"),
        (SILVER_TAXI_TRIPS_SQL, "silver.taxi_trips_cleaned"),
    ]

    # Data Quality
    DATA_QUALITY_SQL = SILVER_SQL_DIR / "03_data_quality_issues.sql"

    # Gold Layer

    GOLD_VIEWS_SQL = VIEWS_SQL_DIR / "gold_views.sql"

    GOLD_DAILY_TRIP_SQL = GOLD_SQL_DIR / "01_daily_trip_summary.sql"
    GOLD_HOURLY_DEMAND_SQL = GOLD_SQL_DIR / "02_hourly_demand_summary.sql"
    GOLD_ZONE_PERFORMANCE_SQL = GOLD_SQL_DIR / "03_zone_performance_summary.sql"
    GOLD_PAYMENT_BEHAVIOR_SQL = GOLD_SQL_DIR / "04_payment_behavior_summary.sql"
    GOLD_ROUTE_PERFORMANCE_SQL = GOLD_SQL_DIR / "05_route_performance_summary.sql"

    GOLD_LAYER = [
        (GOLD_DAILY_TRIP_SQL, "gold.daily_trip_summary"),
        (GOLD_HOURLY_DEMAND_SQL, "gold.hourly_demand_summary"),
        (GOLD_ZONE_PERFORMANCE_SQL, "gold.zone_performance_summary"),
        (GOLD_PAYMENT_BEHAVIOR_SQL, "gold.payment_behavior_summary"),
        (GOLD_ROUTE_PERFORMANCE_SQL, "gold.route_performance_summary"),
    ]

    # Analytics Layer
    ANALYTICS_SQL = ANALYTICS_SQL_DIR / "business_queries.sql"