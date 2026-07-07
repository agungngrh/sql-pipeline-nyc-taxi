from src.database.connection import DatabaseConnection
from src.database.executor import QueryExecutor
from src.pipeline.query_runner import QueryRunner
from src.pipeline.extract import DataExtractor
from src.pipeline.load import BronzeLoader
from src.pipeline.transform import SilverTransformer, GoldMartBuilder, DataQualityChecker
from src.audit.audit_repository import AuditLogRepository
from config.settings import Config
from config.logger import get_logger

logger = get_logger(__name__)


def main() -> None:
    """
    Run the complete NYC Taxi ETL pipeline
    (clean stage-based orchestration)
    """

    logger.info("Step 1/7: Extract source data")
    extractor = DataExtractor(
        taxi_trips_url=Config.TAXI_TRIPS_URL,
        taxi_file=Config.TAXI_FILE,
        taxi_zones_url=Config.TAXI_ZONES_URL,
        zones_file=Config.ZONE_FILE,
    )
    extractor.run()

    with DatabaseConnection() as db:
        executor = QueryExecutor(db.conn)
        runner = QueryRunner(executor)
        audit = AuditLogRepository(runner)

        logger.info("Step 2/7: Initialize database")
        runner.run_files(Config.DATABASE_INIT_SQL_FILES)

        logger.info("Step 3/7: Prepare bronze layer")
        runner.run_file(Config.BRONZE_RESET_SQL)

        logger.info("Step 4/7: Load bronze layer")
        loader = BronzeLoader(executor)

        with audit.track("bronze", "raw_taxi_trips") as ctx:
            ctx.record_count = loader.load_taxi_trips(Config.TAXI_FILE)

        with audit.track("bronze", "raw_taxi_zones") as ctx:
            ctx.record_count = loader.load_taxi_zones(Config.ZONE_FILE)

        logger.info("Step 5/7: Transform silver layer")

        runner.run_file(Config.FUNCTIONS_SQL)
        silver = SilverTransformer(runner)

        for sql_file, table_name in Config.SILVER_LAYER:
            schema, table = table_name.split(".")

            with audit.track(schema, table) as ctx:
                silver.run(sql_file)
                ctx.record_count = runner.count_rows(table_name)

        logger.info("Step 6/7: Data quality check")

        checker = DataQualityChecker(runner)

        with audit.track("silver", "data_quality_issues") as ctx:
            checker.run(Config.DATA_QUALITY_SQL, ctx.audit_id)
            ctx.record_count = runner.sum_column(
                "silver.data_quality_issues",
                "issue_count",
            )

        checker.report()

        logger.info("Step 7/7: Build gold layer")

        runner.run_file(Config.GOLD_VIEWS_SQL)
        gold = GoldMartBuilder(runner)

        for sql_file, table_name in Config.GOLD_LAYER:
            schema, table = table_name.split(".")

            with audit.track(schema, table) as ctx:
                gold.run(sql_file)
                ctx.record_count = runner.count_rows(table_name)

        logger.info("ETL pipeline completed successfully")


if __name__ == "__main__":
    main()