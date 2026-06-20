"""
reader.py
---------
SQL Server connectivity and batch-read logic for the Members table.

Environment variables
~~~~~~~~~~~~~~~~~~~~~
MSSQL_HOST          (required) SQL Server hostname or IP address.
MSSQL_DATABASE      (optional) Database name; defaults to ``TENMAID_UAT``.
MSSQL_USER          (required) SQL Server login username.
MSSQL_PASSWORD      (required) SQL Server login password.
MSSQL_TABLE         (optional) Source table name; defaults to ``Members``.

Design notes
~~~~~~~~~~~~
* Rows are fetched with ``OFFSET … FETCH NEXT`` pagination so the result set
  never has to be materialised in memory all at once.
* Each call to :func:`read_batches` yields one ``list[dict]`` per page, so
  the caller (``main.py``) controls the write cadence and can log progress
  between pages.
* ``TrustServerCertificate=yes`` is intentional for environments where the
  SQL Server uses a self-signed TLS certificate (common in UAT).
"""

import os
import pyodbc
from typing import Iterator

""" Constants """
# Number of rows fetched per round-trip to SQL Server.
# 500 is a reasonable balance between network overhead and memory usage.
_BATCH_SIZE = 500

# Parameterised SQL query that pages through the Members table.
# {table} is substituted at runtime with the MSSQL_TABLE env var.
# The two positional ``?`` placeholders are filled with (offset, batch_size).

_SQL = """
SELECT
    MemberID, Name, SchemeID, MemberGroupID, DateOfExpiry,
    MembershipStatusID, DateJoined, DateReceivedQuestionnaire, SatisfactionID,
    FirstName, MiddleName, Surname, Sex, JobTitle, CompanyName,
    DateCreated, CreatedBy, DateUpdated, UpdatedBy, PrimaryEmployeeID,
    AccountingCode, GoesBy, _ReturnID, Alert, MailName,
    IsNewsSend1, PrimaryLMID, IsInvestor, ClientRefNo, LastDateMet,
    Reference1, Reference2, Reference3, PrimaryID, RelationshipsToPM,
    DOB, AdditionalMemberID, LocationID, TitleID, ConsentID, CountryID,
    AlertGreen, AlertBlue, IsWithWexas, IsNewsSend, OtherLocation,
    AssignEmployeeID, UsageAlert, JobCount, VRegID, IsMain, AttriumID,
    CitiUniqueID, CitiCustomerID, IsImportant, OldMemberID, CitiCorporateID,
    RBSAPrimaryID, updatesusage, DolphinID, knownas, brief,
    TeamLeader, TempEmployeeID, OnlineMemberID, MemberNotes, PrimaryEmail,
    PrimaryMobile, salesForceID, LanguageID, Warning, TimeZoneID, DigitalId,
    AmadeusProfileID, AmadeusInstance, PreferredTravelLM, PreferredLifestyleLM,
    MemberSurveyID, MemberSurveyDate, TTSCustomerID, ForeignMemberID,
    GeoCity, GeoPostcode, FirstName_Computed, Reference5, Reference6
FROM {table}
ORDER BY MemberID
OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
"""


"""Public API"""

def connect() -> pyodbc.Connection:
    """Create and return a pyodbc connection to the SQL Server instance.

    Connection parameters are read from environment variables at call time so
    the function works correctly in containerised environments where secrets
    are injected via ECS task definitions or Kubernetes secrets.

    Returns
    -------
    pyodbc.Connection
        An open, ready-to-use database connection.

    Raises
    ------
    KeyError
        If any required environment variable (``MSSQL_HOST``, ``MSSQL_USER``,
        ``MSSQL_PASSWORD``) is not set.
    pyodbc.Error
        If the connection attempt fails (wrong credentials, unreachable host, …).
    """
    conn_str = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={os.environ['MSSQL_HOST']};"
        # Fall back to the UAT database if no override is provided
        f"DATABASE={os.environ.get('MSSQL_DATABASE', 'TENMAID_UAT')};"
        f"UID={os.environ['MSSQL_USER']};"
        f"PWD={os.environ['MSSQL_PASSWORD']};"
        # Accept self-signed certificates — required in non-production environments
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)


def read_batches(conn: pyodbc.Connection) -> Iterator[list[dict]]:
    """Lazily read the Members table in fixed-size pages.

    Uses SQL Server's ``OFFSET … FETCH NEXT`` clause to retrieve rows in
    chunks of :data:`_BATCH_SIZE`.  Each chunk is yielded as a list of
    dictionaries keyed by column name, which makes downstream code
    independent of column position.

    The generator terminates naturally when an empty result set is returned,
    i.e., when the offset has moved past the last row.

    Parameters
    ----------
    conn:
        An open pyodbc connection (typically obtained from :func:`connect`).

    Yields
    ------
    list[dict]
        A batch of rows, each row represented as ``{column_name: value}``.

    Notes
    -----
    * A single cursor is reused across all pages to avoid connection overhead.
    * The source table name can be overridden via the ``MSSQL_TABLE``
      environment variable (defaults to ``Members``).
    """
    # Resolve the table name from the environment (supports multi-table runs
    # if this function is ever called with different env contexts)
    table = os.environ.get("MSSQL_TABLE", "Members")

    # Substitute the table name into the SQL template (not a user-supplied
    # value at runtime, so format-string injection is not a concern here)
    sql = _SQL.format(table=table)

    cursor = conn.cursor()
    offset = 0  # tracks how many rows have already been read

    while True:
        # Execute the paginated query with the current offset
        cursor.execute(sql, offset, _BATCH_SIZE)

        # Build column name list from cursor metadata so rows can be
        # returned as dicts rather than positional tuples
        columns = [col[0] for col in cursor.description]

        rows = cursor.fetchall()

        # An empty result set means we have consumed all rows — stop iteration
        if not rows:
            break

        # Convert each pyodbc Row to a plain dict for easy downstream access
        yield [dict(zip(columns, row)) for row in rows]

        # Advance the offset for the next page
        offset += _BATCH_SIZE
