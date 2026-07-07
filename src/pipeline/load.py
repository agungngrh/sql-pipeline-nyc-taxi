import pandas as pd
from pathlib import Path
from config.logger import get_logger
from src.database.executor import QueryExecutor

logger = get_logger(__name__)

class BronzeLoader:
    """
    Load raw extracted files into bronze layer tables
    """
    def __init__(self, executor: QueryExecutor) -> None:
        self.executor = executor

    def load_taxi_trips(self, file_path: Path) -> int:
        """
        Load taxi trip data into the bronze layer
        """
        df = pd.read_parquet(file_path)
        return self._insert_dataframe(df, table="bronze.raw_taxi_trips")
    
    def load_taxi_zones(self, file_path: Path) -> int:
        """
        Load taxi zone data into the bronze layer
        """
        df = pd.read_csv(file_path)
        return self._insert_dataframe(df, table="bronze.raw_taxi_zones")
    
    def _insert_dataframe(self, df: pd.DataFrame, table: str) -> int:
        """
        IInsert a DataFrame into a database table using bulk execution
        """
        df = df.astype(object).where(pd.notnull(df), None)

        if df.empty:
            logger.warning("No data found to load into %s", table)
            return 0

        columns = [col.lower() for col in df.columns]
        records = list(df.itertuples(index=False, name=None))

        sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES %s"

        logger.info("Loading %d records into %s", len(records), table)
        row_count = self.executor.execute_values(sql, records)

        return row_count
