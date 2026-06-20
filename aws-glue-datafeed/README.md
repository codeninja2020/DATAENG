# HSBC Datafeed Glue ETL

This component defines the AWS Glue ETL and Terraform infrastructure for loading HSBC member datafeed CSV files into Microsoft SQL Server.

The default feed location is:

```text
s3://bi-qa.tenproduct.com/HSBC/incoming/
```

The Glue job maps incoming HSBC fields to the TEN standard schema, validates records, rejects invalid
rows to S3, stages valid changed rows in SQL Server, inserts them into `TENMAID_UAT.dbo.Members`, and
archives processed input files.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `scripts/glue_mssql_etl.py` | AWS Glue Pandas ETL entry point. Orchestrates chunked S3 reads, field normalisation, validation, transactional DB writes, checkpoints, and S3 archiving. |
| `scripts/validation.py` | Feed validation — required fields, regex rules, duplicate CIN detection, and email conflict checks against SQL Server. |
| `scripts/load.py` | Data model — `MEMBERS_COLUMN_MAPPING` schema and `build_members_model()`, which shapes the validated DataFrame into the `dbo.Members` column structure. |
| `main.tf`, `variables.tf`, `outputs.tf`, `config.tf` | Terraform configuration for the Glue job, IAM role, permissions, and CloudWatch alarms. |
| `member_datafeed_example.csv` | Example HSBC feed with the expected CSV headers. |
| `tests/test_glue_validation.py` | Lightweight unit tests for validation constants and field mapping. |

## Runtime Behavior

For each run, `scripts/glue_mssql_etl.py`:

1. Lists the input objects under `SOURCE_S3_PATH`.
2. Connects to `TENMAID_UAT` and reads the current `dbo.Members` table for conflict checks and change detection.
3. Reads each CSV from S3 in chunks of up to 100,000 rows.
4. Renames source fields such as `CIN`, `segment`, `scheme_name`, and `membership_status` to TEN standard columns and adds missing standard columns.
5. Normalizes key fields:
   - trims all TEN standard fields;
   - uppercases `primary_member_reference` and `country_code`;
   - lowercases `email_address`;
   - removes whitespace from phone numbers;
6. Rejects rows that fail the feed contract, duplicate CIN checks, or email uniqueness checks against SQL Server.
7. Prepares valid rows for `dbo.Members`:
   - derives the internal `SchemeID` from `scheme_name`;
   - deduplicates same `(SchemeID, Reference1)` pairs within the feed (a CIN may appear with two schemes for a scheme switch — both are kept);
   - skips rows that are identical to the current DB record — only changed or new rows are upserted;
8. Upserts each chunk in one SQL Server transaction:
   - creates the connection-scoped temporary table `#members_staging` from the `dbo.Members` schema;
   - bulk copies valid changed rows into `#members_staging` using `pymssql.Connection.bulk_copy`;
   - deletes matching `(SchemeID, Reference1)` rows from `dbo.Members`;
   - inserts staged rows into `dbo.Members` using a set-based `INSERT INTO ... SELECT ... FROM #members_staging`;
   - drops the temporary table and commits the transaction.
9. Writes rejected rows to `ERROR_S3_PATH/file_id=<id>/chunk=<number>/rejects.csv`.
10. Writes a durable chunk checkpoint under `CHECKPOINT_S3_PATH`.
11. Copies each fully processed input object to `ARCHIVE_S3_PATH` and deletes it from the incoming prefix.

The bulk-copy operation loads only `#members_staging`. The final write to `dbo.Members` is not a second
client-side bulk copy; it is a set-based SQL Server insert from the temporary staging table.

## Input Feed

The job expects a comma-delimited CSV with a header row. See `member_datafeed_example.csv` for a complete example.

| Feed column | TEN standard column | DB column | Required | Validation |
| --- | --- | --- | --- | --- |
| `CIN` | `primary_member_reference` | `Reference1` | Yes | 10 digits or `G` followed by 10 digits. |
| `segment` | `secondary_member_reference` | `Reference2` | Yes | String. |
| `scheme_name` | `primary_programme_reference` | `Reference3` | Yes | `PrivateBank` or `Premier`; maximum 11 characters. |
| `membership_status` | `membership_status` | `MembershipStatusID` | Yes | `0` or `1`. |
| `title_code` | `title_code` | `TitleID` | Yes | Integer. |
| `first_name` | `first_name` | `FirstName` | Yes | Maximum 100 characters. |
| `last_name` | `last_name` | `Surname` | Yes | Maximum 100 characters. |
| `gender_code` | `gender_code` | `Sex` | Yes | `0`, `1`, `2`, `3`, or `4`. |
| `language_code` | `language_code` | `LanguageID` | Yes | String. |
| `date_of_birth` | `date_of_birth` | `DOB` | Yes | `YYYY-MM-DD` format. |
| `address_line_1` | `address_line_1` | — | Yes | Maximum 100 characters. |
| `address_line_2` | `address_line_2` | — | Yes | Maximum 100 characters. |
| `town_city` | `town_city` | `GeoCity` | Yes | Maximum 50 characters. |
| `state_region` | `state_region` | — | Yes | Maximum 50 characters. |
| `post_code` | `post_code` | `GeoPostcode` | Yes | Maximum 50 characters. |
| `country_code` | `country_code` | `CountryID` | Yes | Two-letter uppercase country-code format. |
| `email_address` | `email_address` | `PrimaryEmail` | Yes | HTML email input format; maximum 100 characters. |
| `main_phone` | `main_phone` | `PrimaryMobile` | Yes | E.164 format; maximum 15 digits after normalization. |
| `business_phone` | `business_phone` | — | No | E.164 format when supplied. |
| `home_phone` | `home_phone` | — | No | E.164 format when supplied. |

The default delimiter is comma. Override it with the Glue `--INPUT_DELIMITER` argument or Terraform `input_delimiter` variable when needed.

Legacy aliases including `Segment`, `FirstName`, `Surname`, `Gender`, `DOB`, `DateOfBirth`,
`Membership_status`, `MembershipStatus`, `Email`, `EmailAddress`, `Postcode`, and `PostCode`
are also mapped when present.

## Validation

Required TEN standard fields:

- `primary_member_reference`
- `secondary_member_reference`
- `primary_programme_reference`
- `membership_status`
- `title_code`
- `first_name`
- `last_name`
- `gender_code`
- `language_code`
- `date_of_birth`
- `address_line_1`
- `address_line_2`
- `town_city`
- `state_region`
- `post_code`
- `country_code`
- `email_address`
- `main_phone`

Additional validation rules:

- `primary_member_reference` must be either 10 digits or `G` followed by 10 digits.
- `primary_programme_reference` must be `PrivateBank` or `Premier`.
- `date_of_birth` must be in `YYYY-MM-DD` format.
- `membership_status` must be `0` or `1`.
- `title_code` must be an integer.
- `gender_code` must be `0`, `1`, `2`, `3`, or `4`.
- `country_code` must use a two-letter uppercase country-code format.
- `country_code` must be present in the configured ISO 3166-1 alpha-2 allowlist.
- `post_code` must match a UK postcode format.
- `email_address` must match the HTML email input format and be no longer than 100 characters.
- Main, business, and home phone numbers must use E.164 format with 7-15 digits when provided.
- Fields with specified feed limits are rejected when their maximum length is exceeded.
- `primary_member_reference` must be unique within the incoming feed **per scheme**. The same CIN may appear with two different `scheme_name` values (e.g. a scheme switch) — both rows are valid and processed independently.
- `email_address` must not already belong to a different `primary_member_reference` in the target SQL Server table.

Invalid rows are not merged. They are written to the configured error S3 prefix with validation details.

The proposed contract states that `scheme_name` has a maximum length of 10 characters, but also defines
`PrivateBank` as a valid value. The ETL permits 11 characters so that the supplied `PrivateBank` value is accepted.

The ETL validations are aligned with the supplied `TENMAID_UAT.dbo.Members` validation report where the incoming
feed provides the corresponding value. `MemberID` checks remain database-side because the feed does not supply it.

## Alerting

Glue metrics, continuous CloudWatch logs, and Glue 4.0 observability metrics are enabled for the job.

| Alarm | Priority | Condition |
| --- | --- | --- |
| `<glue-job-name>-job-errors` | P2 | `Glue/glue.error.ALL` is greater than zero within five minutes. |
| `<glue-job-name>-failed-tasks` | P3 | `Glue/glue.driver.aggregate.numFailedTasks` is greater than zero within five minutes. |

Both alarms use `sns-slack-alerting-data-engineering` for `alarm_actions` and `ok_actions`. The existing
Amazon Q Developer Slack channel configuration subscribes that SNS topic to the Data Engineering alerts channel.
Missing metric data is treated as healthy.

## SQL Server Requirements

Valid changed rows are first bulk copied into the connection-scoped SQL Server temporary table
`#members_staging`. They are then inserted into `TENMAID_UAT.dbo.Members` with:

```sql
INSERT INTO dbo.Members (<columns>)
SELECT <columns>
FROM #members_staging;
```

This staging load, deletion of matching target rows, and final set-based insert execute in one database
transaction for each input chunk.

| Members column | Staging column | Notes |
| --- | --- | --- |
| `Reference1` | `primary_member_reference` | |
| `Reference2` | `secondary_member_reference` | |
| `Reference3` | `primary_programme_reference` | |
| `MembershipStatusID` | `membership_status` | |
| `TitleID` | `title_code` | |
| `FirstName` | `first_name` | |
| `MiddleName` | `middle_name` | |
| `Surname` | `last_name` | |
| `Sex` | `gender_code` | |
| `LanguageID` | `language_code` | |
| `DOB` | `date_of_birth` | |
| `GeoCity` | `town_city` | |
| `GeoPostcode` | `post_code` | |
| `CountryID` | `country_code` | |
| `PrimaryMobile` | `main_phone` | |
| `PrimaryEmail` | `email_address` | |
| `DateJoined` | — | INSERT only; set to the job run timestamp on first load. |

The supplied database validation report confirms these relevant Members columns:

`MemberID`, `SchemeID`, `CountryID`, `DOB`, `FirstName`, `GeoCity`, `GeoPostcode`, `LanguageID`,
`MembershipStatusID`, `PrimaryEmail`, `PrimaryMobile`, `Reference1`, `Reference2`, `Reference3`, `Sex`,
`Surname`, `TitleID`, and `MiddleName`.

The ETL maps `scheme_name` to both:

- `primary_programme_reference`, written to `dbo.Members.Reference3`;
- an internal `scheme_id`, written to `dbo.Members.SchemeID`.

| Incoming `scheme_name` | `dbo.Members.Reference3` | Internal SchemeID source |
| --- | --- | --- |
| `PrivateBank` | `PrivateBank` | `CUSTOMER_PRIVATE_BANK_SCHEME_ID` |
| `Premier` | `Premier` | `CUSTOMER_PREMIER_SCHEME_ID` |

The internal IDs are supplied through required Glue environment variables and are intentionally not stored in
Terraform. Each value must contain a numeric TENMAID SchemeID. The ETL does not set `MemberID` and relies on the
Members table/database behavior for that field.
Feed fields without a confirmed `dbo.Members` destination are validated but not written to the database.

The write is scheme-scoped:

- valid changed rows are bulk copied into `#members_staging`;
- existing rows are matched on `SchemeID` and `Reference1` and deleted before reinsertion;
- staged rows are inserted into `dbo.Members` using `INSERT INTO ... SELECT`;
- email uniqueness checks are scoped to the derived `SchemeID`;
- inserts require `MemberID` and any other mandatory unmapped columns to have database defaults, triggers,
  or another existing population mechanism.
- the job will fail rather than insert an incomplete member if the Members table requires an omitted value.

The following validated feed fields have no corresponding `dbo.Members` column and are not written to the database:

- `address_line_1`;
- `address_line_2`;
- `state_region`;
- `business_phone`;
- `home_phone`.

`DateJoined` is set to the job run timestamp on first insert and is not changed on subsequent runs.

The Glue driver requires these environment variables:

- `USERNAME`
- `PASSWORD`
- `CUSTOMER_PRIVATE_BANK_SCHEME_ID`
- `CUSTOMER_PREMIER_SCHEME_ID`

Configure them through the Glue `--customer-driver-env-vars` argument. The values are required at runtime and are not provisioned
by this Terraform component. Do not commit credentials to Terraform or this repository.

Example argument format:

```text
USERNAME=<username>,PASSWORD=<password>,CUSTOMER_PRIVATE_BANK_SCHEME_ID=<id>,CUSTOMER_PREMIER_SCHEME_ID=<id>
```

The scheme IDs must reference existing `TENMAID_UAT` schemes. If either mapping is missing or non-numeric, the Glue
job fails before reading or writing member records.

For the `qa` workspace, the default `JDBC_URL` connects to the QA TENMAID RDS instance and selects
`TENMAID_UAT`:

```text
jdbc:sqlserver://tenmaid-v1-db-qa-eu-west-1.csqvz1wpln3e.eu-west-1.rds.amazonaws.com:1433;databaseName=TENMAID_UAT;encrypt=true;trustServerCertificate=false;loginTimeout=30
```

Glue must have VPC/network access to the RDS endpoint. The local bastion tunnel endpoint `localhost:8433`
must not be used by Glue.

## Glue Job Arguments

Terraform configures these default Glue arguments:

| Argument | Description |
| --- | --- |
| `--SOURCE_S3_PATH` | Incoming feed S3 URI. |
| `--ERROR_S3_PATH` | S3 URI for rejected rows. |
| `--ARCHIVE_S3_PATH` | S3 URI for processed files. |
| `--JDBC_URL` | SQL Server JDBC URL. |
| `--TARGET_TABLE` | SQL Server target table, default `dbo.Members`. |
| `--INPUT_DELIMITER` | Input CSV delimiter, default `,`. |
| `--extra-jars` | S3 URI for the Microsoft SQL Server JDBC driver JAR (`mssql-jdbc-13.4.0.jre11.jar`). |
| `--extra-py-files` | Comma-separated S3 URIs for `validation.py` and `load.py`. |
| `--enable-metrics` | Enables Glue job metrics. |
| `--enable-continuous-cloudwatch-log` | Enables continuous CloudWatch logging. |
| `--enable-observability-metrics` | Enables Glue 4.0 observability metrics used by the job-error alarm. |
| `--customer-driver-env-vars` | Runtime-supplied argument containing `USERNAME`, `PASSWORD`, `CUSTOMER_PRIVATE_BANK_SCHEME_ID`, and `CUSTOMER_PREMIER_SCHEME_ID`. |

## Terraform

Terraform files live in this component directory.

The configuration provisions:

- an AWS Glue IAM role;
- the AWS managed Glue service-role policy attachment;
- S3 permissions for `ListBucket`, `GetObject`, `PutObject`, and `DeleteObject` under the HSBC datafeed prefix;
- a Glue network connection into `ten-apps-qa-vpc` so the job can reach the TENMAID RDS endpoint;
- an AWS Glue Spark ETL job with `--extra-jars`, `--extra-py-files`, and all feed arguments pre-configured;
- a daily scheduled trigger at 14:00 UTC (14:00 GMT / 15:00 BST);
- CloudWatch alarms for failed Glue job runs and failed Spark tasks.

The CloudWatch alarms publish alarm and recovery notifications to the
`sns-slack-alerting-data-engineering` SNS topic, which is connected to the Data Engineering Slack channel.

The component is currently enabled for the `qa` environment only through `.component_config.yml`.

All Terraform variables have workspace-derived defaults. No variables are required at apply time.

Useful defaults:

| Variable | Default |
| --- | --- |
| `aws_region` | `eu-west-1` |
| qa bucket | `bi-qa.tenproduct.com` |
| `incoming_prefix` | `HSBC/incoming/` |
| `error_prefix` | `HSBC/errors/` |
| `archive_prefix` | `HSBC/archive/` |
| `glue_version` | `4.0` |
| `worker_type` | `G.1X` |
| `number_of_workers` | `2` |
| `target_table` | `dbo.Members` |
| `jdbc_url` | QA TENMAID RDS endpoint, `TENMAID_UAT` |
| `glue_script_s3_path` | `s3://bi-qa.tenproduct.com/HSBC/scripts/glue_mssql_etl.py` |
| VPC subnet | `subnet-003ac5a8b9146333f` (`eu-west-1a`, `ten-apps-nat-subnet-qa`) |
| VPC security group | `sg-08ce049c284191bfa` (`all-outbound from ten apps-qa`) |

Upload all three Glue scripts to S3 before running the job:

```bash
aws s3 cp scripts/glue_mssql_etl.py s3://bi-qa.tenproduct.com/HSBC/scripts/glue_mssql_etl.py
aws s3 cp scripts/validation.py      s3://bi-qa.tenproduct.com/HSBC/scripts/validation.py
aws s3 cp scripts/load.py            s3://bi-qa.tenproduct.com/HSBC/scripts/load.py
```

`--extra-py-files` and `--extra-jars` are wired automatically by Terraform — no manual argument updates needed after upload.

Run a local Terraform plan from this component directory when required:

```bash
terraform init
terraform workspace select qa
terraform plan
```

All infrastructure changes must be delivered through a pull request. CI runs the affected Terraform plan,
and Terraform applies automatically after the reviewed pull request is merged.

## Local Tests

The local test suite checks the ETL validation constants without requiring AWS Glue or Spark imports.

```bash
python3 -m unittest discover -s tests
```

## Notes

- AWS Glue connects to SQL Server via a Glue network connection (`hsbc-datafeed-mssql-etl-rds-vpc`) in `ten-apps-qa-vpc` (subnet `subnet-003ac5a8b9146333f`, security group `sg-08ce049c284191bfa`). The subnet is associated with `ten-apps-nat-rt-qa`, which has the default NAT route managed by the `network` component. The `AWSGlueServiceRole` managed policy provides the EC2 permissions needed to create the ENI.
- `MemberID` and any other mandatory unmapped Members columns must be populated by existing database behavior.
- Writes, deletes, and email uniqueness checks are scoped to the environment-supplied internal SchemeID selected from `scheme_name`.
- The Microsoft SQL Server JDBC driver (`mssql-jdbc-13.4.0.jre11.jar`) is loaded from `s3://<workspace-bucket>/aws_glue/` via the `--extra-jars` Glue argument and must be present in that S3 path before the job runs.
- The archive step requires `SOURCE_S3_PATH` and `ARCHIVE_S3_PATH` to use the same S3 bucket.
- The `sns-slack-alerting-data-engineering` SNS topic and its Slack integration must already exist in the target account.
- **Atomicity**: for each input chunk, temporary-table creation, bulk copy, deletion of matching target rows, and insertion into `dbo.Members` use one `pymssql` connection and transaction. `XACT_ABORT` is enabled, and failures trigger a rollback.
