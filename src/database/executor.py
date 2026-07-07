from config.logger import get_logger
from psycopg2.extensions import connection as PgConnection
from psycopg2.extras import execute_values as pg_execute_values

logger = get_logger(__name__)


class QueryExecutor:
    """
    Execute SQL commands and queries using an existing PostgreSQL connection
    """
    def __init__(self, conn: PgConnection) -> None:
        self.conn = conn

    def execute(self, sql: str, params=None) -> None:
        """
        Execute a SQL command
        """
        try:
            with self.conn.cursor() as cursor:
                cursor.execute(sql, params)
        except Exception:
            logger.exception("Failed to execute SQL command.")
            raise

    def execute_values(self, sql: str, records) -> int:
        """
        Execute a bulk insert using execute_values()
        """
        try:
            with self.conn.cursor() as cursor:
                pg_execute_values(cursor, sql, records)
                affected_rows = len(records)
                return affected_rows
        except Exception:
            logger.exception("Failed to execute bulk SQL command.")
            raise

    def fetch_all(self, sql: str, params=None) -> list:
        """
        Return all rows from a query
        """
        try:
            with self.conn.cursor() as cursor:
                cursor.execute(sql, params)
                return cursor.fetchall()
        except Exception:
            logger.exception("Failed to fetch query results.")
            raise

    def fetch_one(self, sql: str, params=None):
        """
        Return the first row from a query
        """
        try:
            with self.conn.cursor() as cursor:
                cursor.execute(sql, params)
                return cursor.fetchone()
        except Exception:
            logger.exception("Failed to fetch a single row.")
            raise

    def fetch_value(self, sql: str, params=None):
        """
        Return the first column of the first query result
        """
        row = self.fetch_one(sql, params)
        if row is None:
            return None
        return row[0]