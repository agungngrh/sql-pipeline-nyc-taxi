import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

class Config:
    """
    Konfigurasi env, path dan URL untuk pipeline
    """
    # Konfigurasi db Postgresql
    HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    PORT: int = int(os.getenv("POSTGRES_PORT", "5432"))
    USER: str = os.getenv("POSTGRES_USER", "postgres")
    PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "")
    DATABASE: str = os.getenv("POSTGRES_DB", "ny_taxi_db")

    # Konfigurasi source URL
    TAXI_TRIPS_URL: str = os.getenv(
        "TAXI_TRIPS_URL",
        "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2026-01.parquet"
    )
    TAXI_ZONES_URL: str = os.getenv(
        "TAXI_ZONES_URL",
        "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"
    )

    # Konfigurasi path folder direktori
    BASE_DIR = Path(__file__).resolve().parent.parent
    RAW_DIR = BASE_DIR / "data" / "raw"
    SQL_DIR = BASE_DIR / "sql"
    LOG_DIR = BASE_DIR / "logs"