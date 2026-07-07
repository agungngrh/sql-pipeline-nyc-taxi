from pathlib import Path
from config.logger import get_logger
from src.pipeline.query_runner import QueryRunner
from src.database.sql_reader import read_sql_file

logger = get_logger(__name__)

DATA_QUALITY_REPORT_SQL = """
    SELECT
        error_type,
        column_name,
        issue_count
    FROM silver.data_quality_issues
    ORDER BY issue_count DESC
"""


class SilverTransformer:
    """Transform bronze data into silver layer tables using SQL files."""

    def __init__(self, runner: QueryRunner) -> None:
        self.runner = runner

    def run(self, sql_file: Path) -> None:
        self.runner.run_file(sql_file)
        

class DataQualityChecker:
    """Report data quality issues generated during silver transformation."""

    def __init__(self, runner: QueryRunner) -> None:
        self.runner = runner

    def run(self, sql_file: Path, audit_id: int) -> None:
        """
        Execute data quality SQL file dengan audit_id sebagai parameter.
        audit_id dikirim dari Python supaya bisa disimpan di setiap baris issue.
        """
        sql = read_sql_file(sql_file)
        self.runner.execute(sql, (audit_id,))
        logger.info("Data quality issues loaded for audit_id=%d", audit_id)

    def report(self) -> list:
        """Fetch and log data quality issues."""
        issues = self.runner.run_query(DATA_QUALITY_REPORT_SQL)

        if not issues:
            logger.info("No data quality issues found")
            return issues

        logger.info("Found %d data quality issue types:", len(issues))
        for error_type, column_name, issue_count in issues:
            logger.info(
                "- [%s] on column [%s]: %d rows",
                error_type, column_name, issue_count
            )

        return issues


class GoldMartBuilder:
    """Build gold layer data marts and views using SQL files."""

    def __init__(self, runner: QueryRunner) -> None:
        self.runner = runner

    def run(self, sql_file: Path) -> None:
        self.runner.run_file(sql_file)