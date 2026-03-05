"""AWS Lambda loader for CMS files from S3 into SQL Server.

This script mirrors the CMS SQL Agent job behavior:
1. Download CSV files from s3://bi-staging.tenproduct.com/CMS/
2. Ensure destination tables exist in TEN_DATAWAREHOUSE.dbo
3. Truncate destination tables
4. Insert parsed CSV data with audit columns

Environment variables:
- DB_HOST (required)
- DB_PORT (optional, default: 1433)
- DB_NAME (optional, default: TEN_DATAWAREHOUSE)
- DB_USER (required)
- DB_PASSWORD (required)
- DB_DRIVER (optional, default: ODBC Driver 18 for SQL Server)
- S3_BUCKET (optional, default: bi-staging.tenproduct.com)
- S3_PREFIX (optional, default: CMS/)
- PROCESS_ID (optional; defaults to generated UUID)
"""

from __future__ import annotations

import csv
import io
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from typing import Dict, List

import boto3
import pyodbc


FILE_CONFIG: List[Dict[str, str]] = [
    {
        "key": "Dining.csv",
        "table": "dbo.Dining",
        "columns": [
            "dining_id",
            "ivector_id",
            "ten_maid_vendor_id",
            "dining_name",
            "location_id",
            "latitude",
            "longitude",
            "held_table",
            "Inserted_On",
            "ProcessId",
            "FileName",
        ],
    },
    {
        "key": "Hotels.csv",
        "table": "dbo.Hotels",
        "columns": [
            "accommodation_id",
            "ivector_id",
            "accommodation_name",
            "rating",
            "latitude",
            "longitude",
            "location_id",
            "is_benefits_hotel",
            "Inserted_On",
            "ProcessId",
            "FileName",
        ],
    },
    {
        "key": "Travel_Location.csv",
        "table": "dbo.Locations",
        "columns": [
            "location_id",
            "geo_level",
            "langcode",
            "location_name",
            "latitude",
            "longitude",
            "Inserted_On",
            "ProcessId",
            "FileName",
        ],
    },
]


def _env(name: str, default: str | None = None, required: bool = False) -> str:
    value = os.getenv(name, default)
    if required and not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value or ""


def _to_int(value: str | None) -> int | None:
    if value is None or value == "":
        return None
    return int(value)


def _to_float(value: str | None) -> float | None:
    if value is None or value == "":
        return None
    return float(value)


def _to_bool(value: str | None) -> bool:
    if value is None:
        return False
    return str(value).strip().lower() in {"1", "true", "t", "yes", "y"}


def _to_rating(value: str | None) -> Decimal | None:
    if value is None or value == "":
        return None
    try:
        return Decimal(value).quantize(Decimal("0.1"))
    except InvalidOperation:
        return None


def _connect() -> pyodbc.Connection:
    driver = _env("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    host = _env("DB_HOST", required=True)
    port = _env("DB_PORT", "1433")
    db_name = _env("DB_NAME", "TEN_DATAWAREHOUSE")
    user = _env("DB_USER", required=True)
    password = _env("DB_PASSWORD", required=True)

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={host},{port};"
        f"DATABASE={db_name};"
        f"UID={user};"
        f"PWD={password};"
        "Encrypt=yes;TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str, autocommit=False)


def _ensure_tables(cursor: pyodbc.Cursor) -> None:
    cursor.execute(
        """
IF OBJECT_ID(N'dbo.Dining', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dining (
        dining_id INT,
        ivector_id INT,
        ten_maid_vendor_id INT,
        dining_name NVARCHAR(255),
        location_id INT,
        latitude FLOAT,
        longitude FLOAT,
        held_table BIT,
        Inserted_On DATETIME,
        ProcessId VARCHAR(36),
        FileName VARCHAR(255)
    );
END

IF OBJECT_ID(N'dbo.Hotels', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Hotels (
        accommodation_id INT,
        ivector_id INT,
        accommodation_name NVARCHAR(255),
        rating NUMERIC(3,1),
        latitude FLOAT,
        longitude FLOAT,
        location_id INT,
        is_benefits_hotel BIT,
        Inserted_On DATETIME,
        ProcessId VARCHAR(36),
        FileName VARCHAR(255)
    );
END

IF OBJECT_ID(N'dbo.Locations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Locations (
        location_id INT,
        geo_level NVARCHAR(50),
        langcode NVARCHAR(5),
        location_name NVARCHAR(500),
        latitude FLOAT,
        longitude FLOAT,
        Inserted_On DATETIME,
        ProcessId VARCHAR(36),
        FileName VARCHAR(255)
    );
END
        """
    )


def _truncate_tables(cursor: pyodbc.Cursor) -> None:
    cursor.execute("TRUNCATE TABLE dbo.Dining;")
    cursor.execute("TRUNCATE TABLE dbo.Hotels;")
    cursor.execute("TRUNCATE TABLE dbo.Locations;")


def _read_s3_csv(s3_client, bucket: str, key: str) -> List[Dict[str, str]]:
    obj = s3_client.get_object(Bucket=bucket, Key=key)
    data = obj["Body"].read().decode("utf-8-sig")
    return list(csv.DictReader(io.StringIO(data), delimiter="|"))


def _insert_dining(cursor: pyodbc.Cursor, rows: List[Dict[str, str]], process_id: str, now: datetime) -> int:
    sql = """
INSERT INTO dbo.Dining (
    dining_id, ivector_id, ten_maid_vendor_id, dining_name, location_id,
    latitude, longitude, held_table, Inserted_On, ProcessId, FileName
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    payload = [
        (
            _to_int(r.get("dining_id")),
            _to_int(r.get("ivector_id")),
            _to_int(r.get("ten_maid_vendor_id")),
            r.get("dining_name"),
            _to_int(r.get("location_id")),
            _to_float(r.get("latitude")),
            _to_float(r.get("longitude")),
            _to_bool(r.get("held_table")),
            now,
            process_id,
            "Dining.csv",
        )
        for r in rows
    ]
    if payload:
        cursor.fast_executemany = True
        cursor.executemany(sql, payload)
    return len(payload)


def _insert_hotels(cursor: pyodbc.Cursor, rows: List[Dict[str, str]], process_id: str, now: datetime) -> int:
    sql = """
INSERT INTO dbo.Hotels (
    accommodation_id, ivector_id, accommodation_name, rating, latitude,
    longitude, location_id, is_benefits_hotel, Inserted_On, ProcessId, FileName
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    payload = [
        (
            _to_int(r.get("accommodation_id")),
            _to_int(r.get("ivector_id")),
            r.get("accommodation_name"),
            _to_rating(r.get("rating")),
            _to_float(r.get("latitude")),
            _to_float(r.get("longitude")),
            _to_int(r.get("location_id")),
            _to_bool(r.get("is_benefits_hotel")),
            now,
            process_id,
            "Hotels.csv",
        )
        for r in rows
    ]
    if payload:
        cursor.fast_executemany = True
        cursor.executemany(sql, payload)
    return len(payload)


def _insert_locations(cursor: pyodbc.Cursor, rows: List[Dict[str, str]], process_id: str, now: datetime) -> int:
    sql = """
INSERT INTO dbo.Locations (
    location_id, geo_level, langcode, location_name,
    latitude, longitude, Inserted_On, ProcessId, FileName
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    payload = [
        (
            _to_int(r.get("location_id")),
            r.get("geo_level"),
            r.get("langcode"),
            r.get("location_name"),
            _to_float(r.get("latitude")),
            _to_float(r.get("longitude")),
            now,
            process_id,
            "Travel_Location.csv",
        )
        for r in rows
    ]
    if payload:
        cursor.fast_executemany = True
        cursor.executemany(sql, payload)
    return len(payload)


def lambda_handler(event, context):
    s3_bucket = _env("S3_BUCKET", "bi-staging.tenproduct.com")
    s3_prefix = _env("S3_PREFIX", "CMS/")
    process_id = _env("PROCESS_ID", str(uuid.uuid4()))
    inserted_on = datetime.now(timezone.utc).replace(tzinfo=None)

    s3_client = boto3.client("s3")
    conn = _connect()
    summary = {"process_id": process_id, "inserted": {}}

    try:
        cursor = conn.cursor()
        _ensure_tables(cursor)
        _truncate_tables(cursor)

        dining_rows = _read_s3_csv(s3_client, s3_bucket, f"{s3_prefix}Dining.csv")
        hotel_rows = _read_s3_csv(s3_client, s3_bucket, f"{s3_prefix}Hotels.csv")
        location_rows = _read_s3_csv(s3_client, s3_bucket, f"{s3_prefix}Travel_Location.csv")

        summary["inserted"]["dbo.Dining"] = _insert_dining(cursor, dining_rows, process_id, inserted_on)
        summary["inserted"]["dbo.Hotels"] = _insert_hotels(cursor, hotel_rows, process_id, inserted_on)
        summary["inserted"]["dbo.Locations"] = _insert_locations(cursor, location_rows, process_id, inserted_on)

        conn.commit()
        summary["status"] = "SUCCESS"
        return summary
    except Exception as exc:
        conn.rollback()
        return {
            "status": "FAILED",
            "process_id": process_id,
            "error": str(exc),
        }
    finally:
        conn.close()
