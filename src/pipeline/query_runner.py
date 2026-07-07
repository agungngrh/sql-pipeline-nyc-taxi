from pathlib import Path
from src.database.executor import QueryExecutor
from src.database.sql_reader import read_sql_file
from config.logger import get_logger

logger = get_logger(__name__)


class QueryRunner:
    """
    Single entry point for executing SQL files, queries, and common database operations
    """
    def __init__(self, executor: QueryExecutor) -> None:
        self.executor = executor

    def run_file(self, filepath: Path) -> None:
        """
        Execute a SQL file
        """
        logger.info("Executing SQL file: %s", filepath.name)
        sql = read_sql_file(filepath)
        self.executor.execute(sql)

    def run_files(self, filepaths: list) -> None:
        """
        Execute multiple SQL files in sequence
        """
        for filepath in filepaths:
            self.run_file(filepath)

    def run_query(self, sql: str, params=None) -> list:
        """
        Execute a query and return all rows
        """
        return self.executor.fetch_all(sql, params)

    def count_rows(self, table: str) -> int:
        """
        Return the number of rows in a table
        """
        count = self.executor.fetch_value(f"SELECT COUNT(*) FROM {table}")
        count = count if count is not None else 0
        return count
    
    def sum_column(self, table: str, column: str) -> int:
        """
        Return the sum of a numeric column in a table.
        """
        total = self.executor.fetch_value(
            f"SELECT COALESCE(SUM({column}), 0) FROM {table}"
        )
        return total if total is not None else 0
    
    def execute(self, sql: str, params=None) -> None:
        """
        Execute a SQL command
        """
        self.executor.execute(sql, params)
        