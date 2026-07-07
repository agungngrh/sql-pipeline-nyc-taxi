from config.logger import get_logger
from src.pipeline.query_runner import QueryRunner

logger = get_logger(__name__)


class AuditContext:
    """
    Store audit information for a tracked operation
    """
    def __init__(self, audit_id: int) -> None:
        self.audit_id = audit_id
        self.record_count: int = 0

class AuditLogRepository:
    """
    Record pipeline run history in audit.load_audit
    """

    def __init__(self, runner: QueryRunner) -> None:
        self.runner = runner

    def track(self, schema_name: str, table_name: str) -> "_AuditTracker":
        """
        Track a pipeline operation using a context manager
        """
        return _AuditTracker(self, schema_name, table_name)

    def start_audit(self, schema_name: str, table_name: str) -> int:
        """
        Create a new audit record with RUNNING status
        """
        sql = """
            INSERT INTO audit.load_audit (schema_name, table_name, status)
            VALUES (%s, %s, 'RUNNING')
            RETURNING audit_id
        """
        result = self.runner.run_query(sql, (schema_name, table_name))
        audit_id = result[0][0]

        logger.info(
            "Started audit for %s.%s (audit_id=%d)",
            schema_name,
            table_name,
            audit_id,
        )

        return audit_id

    def complete_audit(
        self,
        audit_id: int,
        schema_name: str,
        table_name: str,
        status: str,
        record_count: int = 0,
        error_message=None,
    ) -> None:
        sql = """
            UPDATE audit.load_audit
            SET status = %s,
                record_count = %s,
                completed_at = clock_timestamp(),
                duration_sec = EXTRACT(EPOCH FROM (clock_timestamp() - started_at)),
                error_message = %s
            WHERE audit_id = %s
        """
        self.runner.execute(
            sql,
            (status, record_count, error_message, audit_id),
        )

        if status == "SUCCESS":
            if record_count > 0:
                logger.info(
                    "Completed audit for %s.%s (%d rows).",
                    schema_name, table_name, record_count
                )
            else:
                logger.info(
                    "Completed audit for %s.%s.",
                    schema_name, table_name
                )
        elif status == "FAILED":
            logger.error(
                "Audit failed for %s.%s: %s",
                schema_name, table_name, error_message
            )

class _AuditTracker:
    """
    Internal context manager for audit tracking
    """
    def __init__(
        self,
        repository: AuditLogRepository,
        schema_name: str,
        table_name: str,
    ) -> None:
        self._repository = repository
        self._schema_name = schema_name
        self._table_name = table_name
        self._context: AuditContext | None = None

    def __enter__(self) -> AuditContext:
        audit_id = self._repository.start_audit(
            self._schema_name,
            self._table_name,
        )
        self._context = AuditContext(audit_id)
        return self._context

    def __exit__(self, exc_type, exc, tb) -> None:
        if self._context is None:
            return

        if exc_type is None:
            self._repository.complete_audit(
                audit_id=self._context.audit_id,
                schema_name=self._schema_name,
                table_name=self._table_name,
                status="SUCCESS",
                record_count=self._context.record_count,
            )
        else:
            self._repository.complete_audit(
                audit_id=self._context.audit_id,
                schema_name=self._schema_name,
                table_name=self._table_name,
                status="FAILED",
                record_count=self._context.record_count,
                error_message=str(exc),
            )