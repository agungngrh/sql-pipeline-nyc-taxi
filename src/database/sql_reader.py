from config.logger import get_logger
from pathlib import Path

logger = get_logger(__name__)

def read_sql_file(filepath: Path) -> str:
    """
    Reads and returns the content of an SQL file from the given path
    """
    try:
        with open(filepath, mode="r", encoding="utf-8") as file:
            sql = file.read()
        logger.debug("Successfully read SQL file: %s", filepath)
        return sql
    except FileNotFoundError:
        logger.error("SQL file not found: %s", filepath)
        raise