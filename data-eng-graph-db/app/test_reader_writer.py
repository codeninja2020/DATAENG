"""
test_reader_writer.py
---------------------
Unit tests for ``reader.py`` and ``writer.py``.

Test strategy
~~~~~~~~~~~~~
* All external I/O (pyodbc, requests, boto3) is mocked so tests run fully
  offline and deterministically.
* Tests are organised into one class per logical unit:
    - ``TestConnect``       – pyodbc connection string construction
    - ``TestReadBatches``   – pagination and dict conversion logic
    - ``TestSerialise``     – the ``_s()`` type-serialisation helper
    - ``TestEnsureIndexes`` – the Neptune index no-op function
    - ``TestQuery``         – the low-level Gremlin HTTP helper
    - ``TestWriteMember``   – the orchestrating write function
"""

import os
from datetime import date, datetime
from unittest.mock import MagicMock, call, patch

import pytest

""" 
reader.py tests
"""

class TestConnect:
    """Tests for ``reader.connect()`` — connection string assembly."""

    def test_builds_connection_string_with_all_env_vars(self):
        """All required env vars must appear in the constructed connection string."""
        env = {
            "MSSQL_HOST": "sql-host",
            "MSSQL_DATABASE": "MyDB",
            "MSSQL_USER": "sa",
            "MSSQL_PASSWORD": "secret",
        }
        with patch.dict(os.environ, env, clear=False):
            with patch("pyodbc.connect") as mock_connect:
                import reader
                reader.connect()
                conn_str = mock_connect.call_args[0][0]

        assert "SERVER=sql-host" in conn_str
        assert "DATABASE=MyDB" in conn_str
        assert "UID=sa" in conn_str
        assert "PWD=secret" in conn_str
        assert "ODBC Driver 18 for SQL Server" in conn_str
        assert "TrustServerCertificate=yes" in conn_str

    def test_defaults_database_to_tenmaid_uat(self):
        """When ``MSSQL_DATABASE`` is unset, ``TENMAID_UAT`` should be used."""
        env = {
            "MSSQL_HOST": "sql-host",
            "MSSQL_USER": "sa",
            "MSSQL_PASSWORD": "secret",
        }
        # Remove MSSQL_DATABASE if present to test the default path
        with patch.dict(os.environ, env, clear=False):
            os.environ.pop("MSSQL_DATABASE", None)
            with patch("pyodbc.connect") as mock_connect:
                import reader
                reader.connect()
                conn_str = mock_connect.call_args[0][0]

        assert "DATABASE=TENMAID_UAT" in conn_str


class TestReadBatches:
    """Tests for ``reader.read_batches()`` — pagination and row conversion."""

    def _make_cursor(self, rows_per_call):
        """Return a mock cursor whose fetchall() cycles through rows_per_call
        then returns [] to signal end of data.

        Parameters
        ----------
        rows_per_call:
            A list of return values for successive ``fetchall()`` calls.
            The last element should be ``[]`` to terminate the generator.
        """
        cursor = MagicMock()
        # Minimal three-column schema that matches test row tuples
        cursor.description = [
            ("MemberID",), ("Name",), ("FirstName",)
        ]
        cursor.fetchall.side_effect = rows_per_call
        return cursor

    def test_yields_single_batch(self):
        """Two rows returned on the first page → one batch of two dicts."""
        rows = [(1, "Alice Smith", "Alice"), (2, "Bob Jones", "Bob")]
        cursor = self._make_cursor([rows, []])  # second call returns [] → stop

        conn = MagicMock()
        conn.cursor.return_value = cursor

        with patch.dict(os.environ, {"MSSQL_TABLE": "Members"}):
            import reader
            batches = list(reader.read_batches(conn))

        assert len(batches) == 1
        assert batches[0][0] == {"MemberID": 1, "Name": "Alice Smith", "FirstName": "Alice"}
        assert batches[0][1] == {"MemberID": 2, "Name": "Bob Jones", "FirstName": "Bob"}

    def test_yields_multiple_batches(self):
        """500 rows then 250 rows → two batches with correct sizes."""
        batch1 = [(i, f"Name {i}", f"First {i}") for i in range(500)]
        batch2 = [(i, f"Name {i}", f"First {i}") for i in range(500, 750)]

        cursor = self._make_cursor([batch1, batch2, []])
        conn = MagicMock()
        conn.cursor.return_value = cursor

        with patch.dict(os.environ, {"MSSQL_TABLE": "Members"}):
            import reader
            batches = list(reader.read_batches(conn))

        assert len(batches) == 2
        assert len(batches[0]) == 500
        assert len(batches[1]) == 250

    def test_stops_on_empty_first_result(self):
        """Empty first result set → generator yields nothing."""
        cursor = self._make_cursor([[]])
        conn = MagicMock()
        conn.cursor.return_value = cursor

        import reader
        batches = list(reader.read_batches(conn))

        assert batches == []

    def test_uses_mssql_table_env_var(self):
        """The SQL executed should contain the custom table name from env."""
        cursor = self._make_cursor([[]])
        conn = MagicMock()
        conn.cursor.return_value = cursor

        with patch.dict(os.environ, {"MSSQL_TABLE": "CustomTable"}):
            import reader
            list(reader.read_batches(conn))

        sql_executed = cursor.execute.call_args[0][0]
        assert "CustomTable" in sql_executed

    def test_defaults_table_to_members(self):
        """Without ``MSSQL_TABLE``, the SQL should reference the ``Members`` table."""
        cursor = self._make_cursor([[]])
        conn = MagicMock()
        conn.cursor.return_value = cursor

        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("MSSQL_TABLE", None)
            import reader
            list(reader.read_batches(conn))

        sql_executed = cursor.execute.call_args[0][0]
        assert "Members" in sql_executed

    def test_passes_correct_offset_and_batch_size(self):
        """Verifies that the cursor is called with incrementing offsets."""
        batch1 = [(i, f"Name {i}", f"First {i}") for i in range(500)]
        cursor = self._make_cursor([batch1, []])
        conn = MagicMock()
        conn.cursor.return_value = cursor

        import reader
        list(reader.read_batches(conn))

        calls = cursor.execute.call_args_list
        # First call: offset=0, batch_size=500
        assert calls[0][0][1] == 0
        assert calls[0][0][2] == 500
        # Second call: offset=500 (first batch was consumed)
        assert calls[1][0][1] == 500


""" # writer.py tests """


class TestSerialise:
    """Tests for ``writer._s()`` — type serialisation helper."""

    def test_date_to_isoformat(self):
        """``date`` objects should become ISO-8601 date strings."""
        import writer
        assert writer._s(date(2024, 1, 15)) == "2024-01-15"

    def test_datetime_to_isoformat(self):
        """``datetime`` objects should become ISO-8601 datetime strings."""
        import writer
        assert writer._s(datetime(2024, 1, 15, 10, 30, 0)) == "2024-01-15T10:30:00"

    def test_string_passthrough(self):
        """Strings should be returned unchanged."""
        import writer
        assert writer._s("hello") == "hello"

    def test_none_passthrough(self):
        """``None`` should be returned unchanged (not converted to a string)."""
        import writer
        assert writer._s(None) is None

    def test_int_passthrough(self):
        """Integers should pass through unchanged."""
        import writer
        assert writer._s(42) == 42

    def test_float_passthrough(self):
        """Floats should pass through unchanged."""
        import writer
        assert writer._s(3.14) == 3.14


class TestEnsureIndexes:
    """Tests for ``writer.ensure_indexes()``."""

    def test_does_not_raise(self):
        """Function must complete without raising any exception."""
        import writer
        writer.ensure_indexes()  # should complete without error


class TestQuery:
    """Tests for ``writer._query()`` — low-level Neptune HTTP helper."""

    def _make_auth(self):
        """Return a mock boto3 Session that supplies fake AWS credentials."""
        mock_creds = MagicMock()
        mock_creds.access_key = "AKID"
        mock_creds.secret_key = "secret"
        mock_creds.token = "token"

        mock_session = MagicMock()
        mock_session.get_credentials.return_value.get_frozen_credentials.return_value = mock_creds
        return mock_session

    def test_posts_to_neptune_endpoint(self):
        """The URL used by requests.post must include the configured endpoint and port."""
        env = {
            "NEPTUNE_ENDPOINT": "neptune.example.com",
            "NEPTUNE_PORT": "8182",
            "AWS_REGION": "eu-west-1",
        }
        mock_resp = MagicMock()
        mock_resp.raise_for_status.return_value = None

        with patch.dict(os.environ, env):
            with patch("boto3.Session", return_value=self._make_auth()):
                with patch("requests.post", return_value=mock_resp) as mock_post:
                    import writer
                    writer._query("g.V().count()")

        url = mock_post.call_args[0][0]
        assert "neptune.example.com:8182/gremlin" in url

    def test_includes_gremlin_in_payload(self):
        """The JSON body must carry the traversal string and any bindings."""
        env = {
            "NEPTUNE_ENDPOINT": "neptune.example.com",
            "NEPTUNE_PORT": "8182",
        }
        mock_resp = MagicMock()
        mock_resp.raise_for_status.return_value = None

        with patch.dict(os.environ, env):
            with patch("boto3.Session", return_value=self._make_auth()):
                with patch("requests.post", return_value=mock_resp) as mock_post:
                    import writer
                    writer._query("g.V().count()", {"x": 1})

        payload = mock_post.call_args[1]["json"]
        assert payload["gremlin"] == "g.V().count()"
        assert payload["bindings"] == {"x": 1}

    def test_raises_on_http_error(self):
        """An HTTP error from Neptune must propagate as an exception."""
        env = {
            "NEPTUNE_ENDPOINT": "neptune.example.com",
            "NEPTUNE_PORT": "8182",
        }
        mock_resp = MagicMock()
        mock_resp.raise_for_status.side_effect = Exception("HTTP 500")

        with patch.dict(os.environ, env):
            with patch("boto3.Session", return_value=self._make_auth()):
                with patch("requests.post", return_value=mock_resp):
                    import writer
                    with pytest.raises(Exception, match="HTTP 500"):
                        writer._query("g.V().count()")

    def test_omits_bindings_when_none(self):
        """When no bindings are passed, the payload must not contain a 'bindings' key."""
        env = {
            "NEPTUNE_ENDPOINT": "neptune.example.com",
            "NEPTUNE_PORT": "8182",
        }
        mock_resp = MagicMock()
        mock_resp.raise_for_status.return_value = None

        with patch.dict(os.environ, env):
            with patch("boto3.Session", return_value=self._make_auth()):
                with patch("requests.post", return_value=mock_resp) as mock_post:
                    import writer
                    writer._query("g.V().count()")

        payload = mock_post.call_args[1]["json"]
        assert "bindings" not in payload


class TestWriteMember:
    """Tests for ``write_member()`` — verifies correct _query calls."""

    def _full_row(self) -> dict:
        """Return a row dict with every optional field populated.

        This is the "happy path" fixture: SchemeID, GeoCity, CompanyName, and
        Reference1 are all set, so all five Gremlin traversals should fire.
        """
        return {
            "MemberID": 42,
            "Name": "Alice Smith",
            "FirstName": "Alice",
            "MiddleName": "M",
            "Surname": "Smith",
            "DOB": date(1990, 5, 20),
            "Sex": "F",
            "JobTitle": "Engineer",
            "CompanyName": "Acme Ltd",
            "GoesBy": "Ali",
            "MemberGroupID": 1,
            "MembershipStatusID": 2,
            "DateJoined": date(2010, 1, 1),
            "DateOfExpiry": date(2030, 1, 1),
            "PrimaryEmail": "alice@example.com",
            "PrimaryMobile": "+447700900000",
            "ClientRefNo": "CR-001",
            "Reference1": "REF1",
            "Reference2": "REF2",
            "Reference3": "REF3",
            "Reference5": "REF5",
            "Reference6": "REF6",
            "DigitalId": "DIG-001",
            "salesForceID": "SF-001",
            "IsInvestor": True,
            "IsMain": True,
            "GeoPostcode": "SW1A 1AA",
            "AmadeusProfileID": "AMD-001",
            "TTSCustomerID": 99,
            "ForeignMemberID": "FM-001",
            "SchemeID": 5,
            "GeoCity": "London",
            "CountryID": 44,
        }

    def test_write_member_full_row_calls_all_five_queries(self):
        """Full row with SchemeID, GeoCity, CompanyName, Reference1 → 5 _query calls."""
        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(self._full_row())

        assert mock_q.call_count == 5

    def test_write_member_no_optional_fields_calls_one_query(self):
        """Only MemberID set, all optional graph traversals skipped → 1 _query call."""
        minimal_row = {k: None for k in self._full_row()}
        minimal_row["MemberID"] = 1

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(minimal_row)

        assert mock_q.call_count == 1

    def test_write_member_always_upserts_member_vertex(self):
        """The first Gremlin traversal must always target the Member vertex."""
        minimal_row = {k: None for k in self._full_row()}
        minimal_row["MemberID"] = 7

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(minimal_row)

        first_gremlin = mock_q.call_args_list[0][0][0]
        assert "Member" in first_gremlin
        assert "memberId" in first_gremlin

    def test_write_member_upserts_programme_when_scheme_id_set(self):
        """A non-None SchemeID must trigger a Programme vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["SchemeID"] = 10

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert any("Programme" in g for g in gremlins)

    def test_write_member_skips_programme_when_scheme_id_none(self):
        """A None SchemeID must not trigger a Programme vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["SchemeID"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert not any("Programme" in g for g in gremlins)

    def test_write_member_upserts_location_when_city_set(self):
        """A non-empty GeoCity must trigger a Location vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["GeoCity"] = "Paris"
        row["SchemeID"] = None
        row["CompanyName"] = None
        row["Reference1"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert any("Location" in g for g in gremlins)

    def test_write_member_skips_location_when_city_empty(self):
        """A None/empty GeoCity must not trigger a Location vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["GeoCity"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert not any("Location" in g for g in gremlins)

    def test_write_member_upserts_company_when_company_set(self):
        """A non-empty CompanyName must trigger a Company vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["CompanyName"] = "Acme"
        row["SchemeID"] = None
        row["GeoCity"] = None
        row["Reference1"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert any("Company" in g for g in gremlins)

    def test_write_member_upserts_reference1_when_ref1_set(self):
        """A non-empty Reference1 must trigger a Reference1 vertex upsert."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["Reference1"] = "REF-XYZ"
        row["SchemeID"] = None
        row["GeoCity"] = None
        row["CompanyName"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        gremlins = [c[0][0] for c in mock_q.call_args_list]
        assert any("Reference1" in g for g in gremlins)

    def test_write_member_serialises_date_fields(self):
        """Date fields in the Member bindings must be ISO-8601 strings."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 1
        row["DOB"] = date(1985, 6, 15)
        row["DateJoined"] = date(2005, 3, 10)
        row["SchemeID"] = None
        row["GeoCity"] = None
        row["CompanyName"] = None
        row["Reference1"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        # The first _query call is always the Member upsert
        bindings = mock_q.call_args_list[0][0][1]
        assert bindings["dob"] == "1985-06-15"
        assert bindings["dateJoined"] == "2005-03-10"

    def test_write_member_passes_member_id_in_bindings(self):
        """The Member upsert bindings must include the correct ``mid`` value."""
        row = {k: None for k in self._full_row()}
        row["MemberID"] = 999
        row["SchemeID"] = None
        row["GeoCity"] = None
        row["CompanyName"] = None
        row["Reference1"] = None

        with patch("writer._query") as mock_q:
            import writer
            writer.write_member(row)

        bindings = mock_q.call_args_list[0][0][1]
        assert bindings["mid"] == 999
