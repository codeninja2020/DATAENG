import csv
import json
import logging
import os
import re
from datetime import datetime, timezone
from io import StringIO

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

AWS_REGION = os.environ.get("AWS_REGION", "eu-west-1")
SECRET_ARN = os.environ["DB_SECRET_ARN"]
DB_CONNECTION_URL = os.environ["DB_CONNECTION_URL"]
METRIC_NAMESPACE = os.environ.get("METRIC_NAMESPACE", "DataEngineering/DataQuality")
METRIC_NAME = os.environ.get("METRIC_NAME", "RpinCheckFindings")
ERROR_BUCKET = os.environ.get("ERROR_BUCKET")
ERROR_PREFIX = os.environ.get("ERROR_PREFIX", "rpin-data-quality/errors/")
RULES_BUCKET = os.environ["RULES_BUCKET"]
RULES_KEY = os.environ["RULES_KEY"]

secretsmanager = boto3.client("secretsmanager", region_name=AWS_REGION)
cloudwatch = boto3.client("cloudwatch", region_name=AWS_REGION)
s3 = boto3.client("s3", region_name=AWS_REGION)


def lambda_handler(event, context):
    logger.info("Step 1/7: starting RPIN data quality checks; request_id=%s", context.aws_request_id)

    rules = read_rules()
    logger.info("Step 2/7: loaded %s RPIN rule(s) from s3://%s/%s", len(rules), RULES_BUCKET, RULES_KEY)

    credentials = get_db_credentials(SECRET_ARN)
    logger.info("Step 3/7: loaded database credentials from Secrets Manager")

    connection_params = parse_db_connection_url(DB_CONNECTION_URL)
    logger.info(
        "Step 4/7: parsed database connection target server=%s port=%s database=%s",
        connection_params["server"],
        connection_params["port"],
        connection_params["database"],
    )

    results = []
    failed_results = []

    for index, rule in enumerate(rules, start=1):
        logger.info(
            "Step 5/7: running rule %s/%s check_name=%s table=%s operator=%s expected_value=%s",
            index,
            len(rules),
            rule["check_name"],
            rule["table"],
            rule["operator"],
            rule["expected_value"],
        )
        sql = rule["sql_check"]
        findings = execute_check(sql, credentials, connection_params)
        actual_value = len(findings)
        passed = compare(actual_value, rule["operator"], rule["expected_value"])
        result = {
            "table": rule["table"],
            "check_name": rule["check_name"],
            "expected_value": rule["expected_value"],
            "Actual_Value": actual_value,
            "operator": rule["operator"],
            "passed": passed,
        }
        results.append(result)

        publish_finding_count(rule["check_name"], actual_value)
        logger.info(
            "Step 6/7: rule check_name=%s returned Actual_Value=%s passed=%s",
            rule["check_name"],
            actual_value,
            passed,
        )
        if findings:
            logger.info("Finding sample for %s: %s", rule["check_name"], json.dumps(findings[:10], default=str))

        if not passed:
            logger.info("Rule check_name=%s failed; writing S3 error file", rule["check_name"])
            failed_results.append(result)
            write_error_file(result)

    logger.info(
        "Step 7/7: completed RPIN data quality checks; total_rules=%s failed_rule_count=%s",
        len(results),
        len(failed_results),
    )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "failed_rule_count": len(failed_results),
                "results": results,
            },
            default=str,
        ),
    }


def read_rules():
    logger.info("Reading RPIN rule file from s3://%s/%s", RULES_BUCKET, RULES_KEY)
    response = s3.get_object(Bucket=RULES_BUCKET, Key=RULES_KEY)
    body = response["Body"].read().decode("utf-8")
    rules = [normalize_rule(row) for row in csv.DictReader(StringIO(body))]

    if not rules:
        raise ValueError(f"No RPIN rules found in s3://{RULES_BUCKET}/{RULES_KEY}")

    return rules


def normalize_rule(row):
    # expected_value is optional in the CSV and defaults to zero findings.
    required_columns = ["check_name", "sql_check", "table", "operator"]
    missing_columns = [column for column in required_columns if not row.get(column)]
    if missing_columns:
        raise ValueError(f"RPIN rule is missing required columns: {', '.join(missing_columns)}")

    expected_value = row.get("expected_value")
    return {
        "check_name": row["check_name"].strip(),
        "sql_check": row["sql_check"].strip(),
        "table": row["table"].strip(),
        "operator": row["operator"].strip(),
        "expected_value": int(expected_value) if str(expected_value or "").strip() else 0,
    }


def get_db_credentials(secret_arn):
    logger.info("Fetching database credentials from Secrets Manager")
    secret = secretsmanager.get_secret_value(SecretId=secret_arn)
    credentials = json.loads(secret["SecretString"])

    if "username" not in credentials or "password" not in credentials:
        raise ValueError("DB secret must contain username and password keys")

    return {
        "username": credentials["username"],
        "password": credentials["password"],
    }


def parse_db_connection_url(connection_url):
    # The source value is JDBC-formatted; pymssql uses the parsed host, port, and database.
    match = re.match(r"^jdbc:sqlserver://([^:;]+)(?::(\d+))?;(.*)$", connection_url)
    if not match:
        raise ValueError(f"Cannot parse SQL Server connection URL: {connection_url}")

    host = match.group(1)
    port = int(match.group(2) or "1433")
    properties = parse_connection_properties(match.group(3))
    database = properties.get("databaseName") or properties.get("database")

    if not database:
        raise ValueError("SQL Server connection URL must include databaseName")

    return {
        "server": host,
        "port": port,
        "database": database,
    }


def parse_connection_properties(properties):
    parsed = {}
    for part in properties.split(";"):
        if not part or "=" not in part:
            continue
        key, value = part.split("=", 1)
        parsed[key] = value
    return parsed


def execute_check(sql, credentials, connection_params):
    logger.info(
        "Opening SQL Server connection to server=%s port=%s database=%s",
        connection_params["server"],
        connection_params["port"],
        connection_params["database"],
    )
    try:
        import pymssql
    except ImportError as exc:
        raise RuntimeError(
            "Missing pymssql dependency. Package pymssql with the Lambda artifact or attach a compatible Lambda layer."
        ) from exc

    try:
        connection = pymssql.connect(
            server=connection_params["server"],
            port=connection_params["port"],
            database=connection_params["database"],
            user=credentials["username"],
            password=credentials["password"],
            login_timeout=30,
            timeout=60,
            charset="UTF-8",
        )
        logger.info(
            "Connected to SQL Server database server=%s port=%s database=%s",
            connection_params["server"],
            connection_params["port"],
            connection_params["database"],
        )
    except Exception as exc:
        logger.exception("SQL Server connection failed")
        raise RuntimeError("Failed to connect to SQL Server database") from exc

    with connection:
        with connection.cursor(as_dict=True) as cursor:
            logger.info("Executing RPIN SQL check")
            cursor.execute(sql)
            rows = cursor.fetchall()
            logger.info("SQL check execution completed; rows_returned=%s", len(rows))
            return rows


def compare(actual_value, operator, expected_value):
    logger.info(
        "Comparing rule result Actual_Value=%s operator=%s expected_value=%s",
        actual_value,
        operator,
        expected_value,
    )
    if operator in ("=", "=="):
        return actual_value == expected_value
    if operator == "!=":
        return actual_value != expected_value
    if operator == ">":
        return actual_value > expected_value
    if operator == ">=":
        return actual_value >= expected_value
    if operator == "<":
        return actual_value < expected_value
    if operator == "<=":
        return actual_value <= expected_value
    raise ValueError(f"Unsupported operator for RPIN rule: {operator}")


def publish_finding_count(check_name, finding_count):
    logger.info(
        "Publishing finding count metric namespace=%s metric=%s check_name=%s value=%s",
        METRIC_NAMESPACE,
        METRIC_NAME,
        check_name,
        finding_count,
    )
    cloudwatch.put_metric_data(
        Namespace=METRIC_NAMESPACE,
        MetricData=[
            {
                "MetricName": METRIC_NAME,
                "Dimensions": [
                    {
                        "Name": "CheckName",
                        "Value": check_name,
                    }
                ],
                "Unit": "Count",
                "Value": finding_count,
            }
        ],
    )


def write_error_file(rule_result):
    if not ERROR_BUCKET:
        raise ValueError("Missing required environment variable: ERROR_BUCKET")

    created_timestamp = datetime.now(timezone.utc).isoformat()
    key = build_error_key(rule_result["check_name"], created_timestamp)
    csv_body = build_error_csv(created_timestamp, rule_result)

    logger.info("Writing RPIN error file to s3://%s/%s", ERROR_BUCKET, key)
    s3.put_object(
        Bucket=ERROR_BUCKET,
        Key=key,
        Body=csv_body.encode("utf-8"),
        ContentType="text/csv",
    )
    logger.info("Wrote RPIN error file: s3://%s/%s", ERROR_BUCKET, key)


def build_error_key(check_name, created_timestamp):
    safe_timestamp = created_timestamp.replace(":", "").replace("+", "Z")
    return f"{ERROR_PREFIX.rstrip('/')}/{check_name}/{safe_timestamp}.csv"


def build_error_csv(created_timestamp, rule_result):
    output = StringIO()
    writer = csv.DictWriter(
        output,
        fieldnames=[
            "table",
            "check_name",
            "expected_value",
            "Actual_Value",
            "created_timestamp",
        ],
    )
    writer.writeheader()
    writer.writerow(
        {
            "table": rule_result["table"],
            "check_name": rule_result["check_name"],
            "expected_value": rule_result["expected_value"],
            "Actual_Value": rule_result["Actual_Value"],
            "created_timestamp": created_timestamp,
        }
    )
    return output.getvalue()
