"""
main.py
-------
Entry point for the SQL Server → Amazon Neptune ETL pipeline.

Execution flow
~~~~~~~~~~~~~~
1. Ensure Neptune property indexes are in place (no-op in Gremlin mode,
   but kept as an explicit step for observability).
2. Open a pyodbc connection to the source SQL Server.
3. Stream rows from the Members table in fixed-size batches via
   ``read_batches()``, writing each row to Neptune with ``write_member()``.
4. Log a running progress counter after every batch, then a final summary.
5. Exit with code 1 if any rows failed to write so that orchestrators
   (e.g., ECS task, Kubernetes Job) can detect and surface partial failures.
"""

import logging
import sys

from reader import connect, read_batches
from writer import ensure_indexes, write_member

# ---------------------------------------------------------------------------
# Logging — structured timestamps to stdout so CloudWatch / Loki can ingest
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stdout,
)
log = logging.getLogger(__name__)


def main() -> None:
    """Run the full ETL pipeline from SQL Server to Neptune.

    Iterates over every member row returned by :func:`reader.read_batches`
    and calls :func:`writer.write_member` for each one.  Errors on individual
    rows are caught and counted so a single bad record does not abort the
    entire run; the final exit code reflects whether *any* errors occurred.
    """
    # Step 1: verify (or no-op) Neptune indexes before ingestion begins
    log.info("ensuring Neptune indexes")
    ensure_indexes()

    # Step 2: establish the SQL Server connection used for all batch reads
    log.info("connecting to SQL Server")
    conn = connect()

    total = 0   # cumulative count of rows successfully written to Neptune
    errors = 0  # cumulative count of rows that raised an exception

    try:
        # Step 3: stream rows in batches to bound memory usage
        for batch in read_batches(conn):
            for row in batch:
                try:
                    write_member(row)
                    total += 1
                except Exception as exc:
                    # Per-row errors are logged with the MemberID for easy
                    # investigation; the loop continues to the next row.
                    errors += 1
                    log.error("memberId=%s failed: %s", row.get("MemberID"), exc)

            # Emit progress after each batch so long runs remain observable
            log.info("progress: %d loaded, %d errors", total, errors)
    finally:
        # Always close the DB connection, even if an unexpected exception
        # propagates (e.g., a KeyboardInterrupt or SIGTERM handler)
        conn.close()

    # Step 4: emit final summary and propagate failure to the caller
    log.info("complete — %d members loaded, %d errors", total, errors)
    if errors:
        # Non-zero exit signals the container orchestrator that the run was
        # only partially successful, triggering alerting / retry logic.
        sys.exit(1)


if __name__ == "__main__":
    main()
