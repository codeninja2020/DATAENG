# S3 Archive Cleanup Lambda

Deletes an object in a configured root when the matching archived object arrives. We use the same bucket for source events (`<root>/sql-archive/...`) and target deletions (`<root>/incoming/...`).

## Flow
- Triggered by S3 ObjectCreated:* on keys under each configured archive root prefix.
- Confirms the source object still exists (stale events are ignored).
- Builds `target_key` by mapping `<root>/sql-archive/<path>` to `<root>/incoming/<path>`.
- If the archived path starts with an 8-digit date folder such as `20260419/`, that date folder is removed before deleting the target object.
- If the target exists and DELETE_TARGET=true, deletes s3://TARGET_BUCKET/target_key; otherwise logs and keeps it.

Configured archive roots:
- BE_DJANGO_POSTGRES_CSV/sql-archive/
- CA_BOA_Reports/sql-archive/
- CMS/sql-archive/
- PREFERENCE_CSV/sql-archive/
- ivector/sql-archive/
- mercuryhub/sql-archive/

## Environment variables
- TARGET_BUCKET (or legacy LANDING_BUCKET): bucket to check and delete from.
- ARCHIVE_ROOTS: comma-separated roots to map from `<root>/sql-archive/` to `<root>/`.
- ARCHIVE_FOLDER: archive folder name under each configured root. Defaults to `sql-archive`.
- TARGET_FOLDER: target folder name under each configured root. Defaults to `incoming`.
- TARGET_PREFIX (legacy, default CMS/): used only when ARCHIVE_ROOTS does not match the object key.
- SOURCE_PREFIX_STRIP (legacy, default CMS/sql-archive/): leading segment removed from the source key before applying TARGET_PREFIX.
- DELETE_TARGET (or legacy DELETE_SOURCE, default true): delete when present; if false, only logs.

Example:
```
TARGET_BUCKET=bi-staging.tenproduct.com
ARCHIVE_ROOTS=BE_DJANGO_POSTGRES_CSV,CA_BOA_Reports,CMS,PREFERENCE_CSV,ivector,mercuryhub
ARCHIVE_FOLDER=sql-archive
TARGET_FOLDER=incoming
DELETE_TARGET=true
```

Example mapping:
- `CMS/sql-archive/20260419/Dining.csv` -> deletes `CMS/incoming/Dining.csv`

## Terraform wiring (module)
- Bucket name comes from local
- aws_s3_bucket_notification targets this Lambda with one filter_prefix per configured archive root.
- aws_lambda_permission allows s3.amazonaws.com with source_arn set to the bucket ARN.
- IAM policy allows HeadObject/DeleteObject on the target bucket/prefix.

## Local tests
Run the Lambda unit test script from the component root:

```
python3 -m unittest tests/test_lambda_s3_delete.py
```
