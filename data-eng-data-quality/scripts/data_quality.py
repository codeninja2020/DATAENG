"""Glue Python Shell data quality runner for TENMAID_UAT Members.

Pipeline stages:
  1. Read DQDL rules file from S3.
  2. Parse IsComplete rules from DQDL.
  3. Fetch DB credentials from Secrets Manager and JDBC connection properties from Glue.
  4. Run Pandas pre-flight checks directly against MSSQL.
  5. Trigger the Glue Data Quality ruleset evaluation run (results visible in Glue console).
  6. Wait for the evaluation to complete.
  7. Build a Pandas frame from the Glue Data Quality rule results.
  8. Raise if the pre-flight or Glue Data Quality checks failed.
"""

import json
import re
import sys
import time
from typing import Any, Dict, List

import boto3
import pandas as pd
import pymssql
from awsglue.utils import getResolvedOptions

#  Job arguments 
args = getResolvedOptions(
    sys.argv,
    [
        "JDBC_SECRET_ARN",
        "DQDL_S3_PATH",
        "RULESET_NAME",
        "GLUE_DATABASE_NAME",
        "GLUE_TABLE_NAME",
        "GLUE_CONNECTION_NAME",
        "AWS_REGION",
    ],
)

JDBC_SECRET_ARN = args["JDBC_SECRET_ARN"]
DQDL_S3_PATH = args["DQDL_S3_PATH"]
RULESET_NAME = args["RULESET_NAME"]
GLUE_DATABASE_NAME = args["GLUE_DATABASE_NAME"]
GLUE_TABLE_NAME = args["GLUE_TABLE_NAME"]
GLUE_CONNECTION_NAME = args["GLUE_CONNECTION_NAME"]
AWS_REGION = args["AWS_REGION"]

# Polling interval and total timeout for the Glue DQ evaluation run.
POLL_INTERVAL_SECONDS = 15
EVALUATION_TIMEOUT_SECONDS = 600


#  Helpers 

def get_db_credentials() -> Dict[str, str]:
    """Fetch MSSQL username and password from Secrets Manager."""
    client = boto3.client("secretsmanager", region_name=AWS_REGION)
    secret = client.get_secret_value(SecretId=JDBC_SECRET_ARN)
    creds = json.loads(secret["SecretString"])
    return {"username": creds["username"], "password": creds["password"]}


def get_connection_properties() -> Dict[str, str]:
    """Retrieve the Glue JDBC connection properties (URL, etc.) by connection name."""
    client = boto3.client("glue", region_name=AWS_REGION)
    response = client.get_connection(Name=GLUE_CONNECTION_NAME)
    return response["Connection"]["ConnectionProperties"]


def read_dqdl_from_s3(s3_path: str) -> str:
    """Download the DQDL rules file from S3 and return its content as a string."""
    s3 = boto3.client("s3", region_name=AWS_REGION)
    bucket, key = s3_path.replace("s3://", "").split("/", 1)
    response = s3.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf-8")


def parse_is_complete_rules(dqdl: str) -> List[Dict[str, Any]]:
    """Parse all IsComplete rules and their optional WHERE filters from DQDL text.

    Returns a list of dicts with keys: column, where (nullable).
    """
    pattern = re.compile(
        r'IsComplete\s+"(?P<column>[^"]+)"(?:\s+where\s+"(?P<where>[^"]+)")?',
        re.IGNORECASE,
    )
    return [m.groupdict() for m in pattern.finditer(dqdl)]


#  Stage 4: Pandas pre-flight checks 

def run_pandas_checks(
    rules: List[Dict[str, Any]], creds: Dict[str, str], conn_props: Dict[str, str]
) -> List[Dict[str, Any]]:
    """Execute each parsed IsComplete rule against MSSQL using Pandas.

    Connects directly via pymssql, pulling only the target column (+ WHERE filter)
    to keep the query lightweight. Returns one result dict per rule.
    """
    # Parse host, port, and database from the JDBC connection URL.
    jdbc_url = conn_props.get("JDBC_CONNECTION_URL", "")
    host_match = re.search(r"sqlserver://([^:]+):(\d+)", jdbc_url)
    if not host_match:
        raise ValueError(f"Cannot parse host/port from JDBC URL: {jdbc_url}")

    host = host_match.group(1)
    port = int(host_match.group(2))
    db_match = re.search(r"databaseName=([^;]+)", jdbc_url)
    database = db_match.group(1) if db_match else "TENMAID_UAT"

    results = []
    print(f"  Connecting to {host}:{port}/{database}")
    with pymssql.connect(
        server=host,
        port=port,
        database=database,
        user=creds["username"],
        password=creds["password"],
    ) as conn:
        for rule in rules:
            column = rule["column"]
            where_clause = rule.get("where") or ""

            # Select only the column under test, filtered to the relevant rows.
            sql = f"SELECT [{column}] FROM dbo.Members"
            if where_clause:
                sql += f" WHERE {where_clause}"

            df = pd.read_sql(sql, conn)
            total = len(df)
            null_count = int(df[column].isna().sum())
            passed = null_count == 0

            result = {
                "rule": f'IsComplete "{column}"' + (f' where "{where_clause}"' if where_clause else ""),
                "total_rows": total,
                "null_count": null_count,
                "passed": passed,
            }
            results.append(result)

            status = "PASS" if passed else "FAIL"
            print(f"  [{status}] {result['rule']} — {null_count}/{total} null values")

    return results


#  Stage 5: Glue Data Quality evaluation 

def trigger_glue_dq_evaluation() -> str:
    """Start a Glue Data Quality ruleset evaluation run.

    The run targets the Glue Data Catalog table via the named JDBC connection.
    CloudWatch metrics are enabled so the existing alarm can fire on failures.
    Returns the RunId to poll for completion.
    """
    client = boto3.client("glue", region_name=AWS_REGION)

    # Derive the IAM role ARN from the current caller identity so the evaluation
    # run uses the same permissions as this job.
    sts = boto3.client("sts", region_name=AWS_REGION)
    caller_arn = sts.get_caller_identity()["Arn"]
    role_arn = (
        caller_arn
        .replace(":assumed-role/", ":role/")
        .rsplit("/", 1)[0]
        .replace("sts", "iam")
    )

    response = client.start_data_quality_ruleset_evaluation_run(
        DataSource={
            "GlueTable": {
                "DatabaseName": GLUE_DATABASE_NAME,
                "TableName": GLUE_TABLE_NAME,
                "ConnectionName": GLUE_CONNECTION_NAME,
            }
        },
        RulesetNames=[RULESET_NAME],
        Role=role_arn,
        AdditionalRunOptions={"CloudWatchMetricsEnabled": True},
    )
    return response["RunId"]


def wait_for_evaluation(run_id: str) -> Dict[str, Any]:
    """Poll the evaluation run until it reaches a terminal state or times out."""
    client = boto3.client("glue", region_name=AWS_REGION)
    terminal_states = {"SUCCEEDED", "FAILED", "STOPPED", "ERROR"}
    elapsed = 0

    while elapsed < EVALUATION_TIMEOUT_SECONDS:
        response = client.get_data_quality_ruleset_evaluation_run(RunId=run_id)
        status = response.get("Status")

        if status in terminal_states:
            return response

        print(f"  Run {run_id}: {status} — waiting ({elapsed}s elapsed)")
        time.sleep(POLL_INTERVAL_SECONDS)
        elapsed += POLL_INTERVAL_SECONDS

    raise TimeoutError(
        f"Evaluation run {run_id} did not complete within {EVALUATION_TIMEOUT_SECONDS}s"
    )


def build_dq_results_frame(
    evaluation: Dict[str, Any],
) -> pd.DataFrame:
    """Return one Pandas row per Glue Data Quality rule result."""
    client = boto3.client("glue", region_name=AWS_REGION)
    rows = []

    for result_id in evaluation.get("ResultIds", []):
        result = client.get_data_quality_result(ResultId=result_id)
        for rule_result in result.get("RuleResults", []):
            rows.append(
                {
                    "result_id": result_id,
                    "ruleset_name": result.get("RulesetName"),
                    "score": result.get("Score"),
                    "rule": rule_result.get("EvaluatedRule")
                    or rule_result.get("Name"),
                    "result": rule_result.get("Result"),
                    "evaluation_message": rule_result.get(
                        "EvaluationMessage"
                    ),
                    "evaluated_metrics": rule_result.get(
                        "EvaluatedMetrics", {}
                    ),
                }
            )

    columns = [
        "result_id",
        "ruleset_name",
        "score",
        "rule",
        "result",
        "evaluation_message",
        "evaluated_metrics",
    ]
    return pd.DataFrame(rows, columns=columns)


#  Entry point 

def main() -> None:
    #  Stage 1: Read DQDL from S3 
    print(f"\n[Stage 1] Reading DQDL rules from {DQDL_S3_PATH}")
    dqdl = read_dqdl_from_s3(DQDL_S3_PATH)
    print(dqdl.strip())

    #  Stage 2: Parse rules 
    print("\n[Stage 2] Parsing DQDL rules")
    rules = parse_is_complete_rules(dqdl)
    print(f"  Found {len(rules)} rule(s): {[r['rule'] for r in rules]}")

    #  Stage 3: Fetch credentials and connection properties 
    print("\n[Stage 3] Fetching DB credentials and Glue connection properties")
    creds = get_db_credentials()
    conn_props = get_connection_properties()
    print(f"  Credentials retrieved for user: {creds['username']}")
    print(f"  Connection URL: {conn_props.get('JDBC_CONNECTION_URL', 'N/A')}")

    #  Stage 4: Pandas pre-flight checks 
    print("\n[Stage 4] Running Pandas pre-flight checks against MSSQL")
    preflight_results = run_pandas_checks(rules, creds, conn_props)
    preflight_passed = all(r["passed"] for r in preflight_results)
    print(f"  Pre-flight result: {'PASSED' if preflight_passed else 'FAILED'}")

    #  Stage 5: Trigger Glue Data Quality evaluation 
    print(f"\n[Stage 5] Triggering Glue Data Quality evaluation for ruleset '{RULESET_NAME}'")
    run_id = trigger_glue_dq_evaluation()
    print(f"  Evaluation run started: {run_id}")

    #  Stage 6: Wait for completion 
    print(f"\n[Stage 6] Waiting for evaluation run {run_id} to complete")
    result = wait_for_evaluation(run_id)
    status = result.get("Status")
    print(f"  Evaluation run completed with status: {status}")

    if status != "SUCCEEDED":
        raise RuntimeError(
            f"Glue Data Quality evaluation run failed: {result.get('ErrorString')}"
        )

    #  Stage 7: Build and inspect the Glue Data Quality results frame
    print("\n[Stage 7] Building Glue Data Quality results frame")
    dq_results_frame = build_dq_results_frame(result)
    if dq_results_frame.empty:
        raise RuntimeError(
            "Glue Data Quality evaluation completed without rule results."
        )

    print(dq_results_frame.to_string(index=False))
    failed_dq_results = dq_results_frame[
        dq_results_frame["result"] != "PASS"
    ]

    if not preflight_passed:
        raise RuntimeError("Pandas pre-flight checks failed — see Stage 4 logs above.")

    if not failed_dq_results.empty:
        raise RuntimeError(
            f"{len(failed_dq_results)} Glue Data Quality rule(s) failed."
        )

    print("\n✓ All data quality checks passed.")


if __name__ == "__main__":
    main()
