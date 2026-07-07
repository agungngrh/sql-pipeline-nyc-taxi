import psycopg2
from psycopg2.extensions import connection as PgConnection
from config.settings import Config
from config.logger import get_logger

logger = get_logger(__name__)

class DatabaseConnection:
    """
    Manages the PostgreSQL connection lifecycle using a context manager
    """
    def __init__(self) -> None:
        self.conn: PgConnection

    def __enter__(self) -> "DatabaseConnection":
        try:
            self.conn = psycopg2.connect(
                host=Config.HOST,
                port=Config.PORT,
                user=Config.USER,
                password=Config.PASSWORD,
                dbname=Config.DATABASE
            )
            self.conn.autocommit = False
            logger.info("Successfully connected to the PostgreSQL database")
            return self
        
        except psycopg2.Error as e:
                logger.error("Failed to connect to the database: %s", e)
                raise
    
    def __exit__(self, exc_type, exc, tb):
        """
        Automatically commits on success or rolls back the transaction if an error occurs
        """
        if self.conn is None:
            return
        
        try:
            if exc_type is None:
                self.conn.commit()
                logger.info("Transaction successfully committed")
            else:
                self.conn.rollback()
                logger.error("Transaction failed, changes rolled back: %s", exc)
        finally:
            self.conn.close()
            logger.info("Database connection closed")
        
