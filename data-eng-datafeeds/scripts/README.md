# Data Eng Datafeeds – S3 Target Cleanup Lambda

Lambda triggered by S3 object-created events. When a new file lands in the source bucket, it checks for the same key (optionally under a prefix) in the target bucket and deletes it there.

## 
## How it works.
- Triggered by an S3 event record.
- Confirms the source object still exists (ignores stale/missing source).
- Builds `target_key = TARGET_PREFIX + object_key`.
- Checks the target bucket for that key; if missing, exits.
- If present and `DELETE_TARGET=true`, deletes `s3://TARGET_BUCKET/target_key`; otherwise logs and keeps it.

## Environment variables
- `TARGET_BUCKET` (or legacy `LANDING_BUCKET`): bucket to check and delete from.
- `TARGET_PREFIX` (default ` `): prefix to prepend to the target object key.
- `DELETE_TARGET` (or legacy `DELETE_SOURCE`, default `true`): whether to delete the matching target object when found.

Sample for QA (see `scripts/.env`):
```
TARGET_BUCKET=data-eng-datafeeds-qa
TARGET_PREFIX=
DELETE_TARGET=true
```

## Terraform pieces (add where managed)
1) Bucket exists via `s3.tf` module using `local.workspace.s3_bucket_name`.
2) Add S3 → Lambda notification on that bucket (e.g., `aws_s3_bucket_notification`) with the desired events and prefix/suffix filters.
3) Add matching `aws_lambda_permission` allowing `s3.amazonaws.com` with `source_arn` set to the bucket.
4) Ensure the Lambda role allows `HeadObject` and `DeleteObject` on the target bucket/prefix.
5) Set the Lambda env vars above in the deployment.

## Notes
- Only one `aws_s3_bucket_notification` resource per bucket; add all notifications inside it. 
