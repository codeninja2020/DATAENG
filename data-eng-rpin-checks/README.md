# RPIN Data Quality Lambda

Runs RPIN data quality checks against the QA TENMAID_UAT SQL Server database.

## Architecture
Based on Patterns for checking data quality.

This component follows the data-quality check pattern of separating rule definition, execution, evidence, and alerting:

2. The Lambda reads `rpin_checks.csv` from S3 so rule changes do not require code changes.
3. The Lambda looks up an existing Secrets Manager secret and uses the existing QA RDS network path configured in Terraform.
4. Each rule executes the SQL stored in `sql_check`.
5. The Lambda compares `Actual_Value` with `expected_value` using the configured `operator`.
6. Failed checks are written to S3 as CSV evidence under `rpin-data-quality/errors/`.
7. CloudWatch metrics drive alerting for RPIN findings.


The Lambda uses existing database credentials and existing network connectivity. This component does not create database users, VPCs, subnets, security groups, routes, endpoints, Glue Catalog resources, or crawlers.

## Runtime

- Terraform uploads `scripts/rpin_checks.csv` to `s3://bi-qa.tenproduct.com/rpin-data-quality/rules/rpin_checks.csv`.
- Terraform uploads `scripts/pymysql.zip` to S3, creates a Lambda layer from that object, and attaches the resulting layer ARN to the Lambda.
- EventBridge Scheduler runs the Lambda daily at 10:00 `Europe/Dublin`, matching the eu-west-1 regional timezone.
- The Lambda reads the rule CSV from S3 at runtime.
- Each rule contains the SQL to execute in the `sql_check` column.
- Database credentials come from the configured Secrets Manager secret.
- The Lambda connects with `pymssql` using `DB_CONNECTION_URL`.
- The Lambda uses the QA RDS VPC subnet and security group configured in Terraform.

## Schedule

EventBridge Scheduler runs the Lambda daily at 10:00 in the eu-west-1 regional timezone:

```hcl
schedule_expression = "cron(0 10 * * ? *)"
schedule_timezone   = "Europe/Dublin"
```

The schedule uses `flexible_time_window.mode = "OFF"` so the check runs at the configured time instead of inside a flexible delivery window.

## Rule File

The rule CSV columns are:

```csv
check_name,sql_check,table,operator,expected_value
```

- `check_name`: metric dimension and S3 error subfolder.
- `sql_check`: SQL query to execute.
- `table`: source table name written to error output.
- `operator`: comparison operator for `Actual_Value` and `expected_value`.
- `expected_value`: expected result count; blank values default to `0`.

## Failure Output

When a rule fails, the Lambda writes a CSV to:

```text
s3://bi-qa.tenproduct.com/rpin-data-quality/errors/<check_name>/<timestamp>.csv
```

The error CSV columns are:

```csv
table,check_name,expected_value,Actual_Value,created_timestamp
```

RPIN data quality findings do not fail the Lambda invocation.

## Alerts

Only one alert path is configured:

- `DataEngineering/DataQuality/RpinCheckFindings`: fires when RPIN errors are observed.

The alarm notifies `sns-slack-alerting-data-engineering`.

## Not Included

Glue Catalog and crawler resources are intentionally excluded for now.

## Dependency Packaging

`pymssql` is required to connect to SQL Server. Terraform creates the managed dependency layer from `scripts/pymysql.zip`:

- `aws_s3_object.pymysql_layer` uploads `scripts/pymysql.zip` to the configured S3 bucket.
- `aws_lambda_layer_version.pymysql` references that S3 object and exposes the layer ARN.
- `aws_lambda_function.rpin_data_quality` attaches that ARN, plus any additional ARNs configured in `var.lambda_layer_arns`.

## Local Tests

Run unit tests from the component root:

```bash
python3 -m unittest tests/test_rpin_data_quality.py
```
