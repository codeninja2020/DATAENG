# Look up the existing BI bucket for the active Terraform workspace.
data "aws_s3_bucket" "bi" {
  bucket = local.bucket_name
}

# Enable S3 versioning so overwritten and deleted objects retain recoverable versions.
resource "aws_s3_bucket_versioning" "bi" {
  bucket = data.aws_s3_bucket.bi.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Retain only the most recent noncurrent versions to limit storage growth.
resource "aws_s3_bucket_lifecycle_configuration" "bi" {
  bucket = data.aws_s3_bucket.bi.id

  # Versioning must be enabled before AWS accepts noncurrent-version lifecycle rules.
  depends_on = [
    aws_s3_bucket_versioning.bi
  ]

  rule {
    id     = "limit-noncurrent-versions"
    status = "Enabled"

    filter {}

    # Keep up to five newer noncurrent versions, then expire older versions after 30 days.
    noncurrent_version_expiration {
      newer_noncurrent_versions = 5
      noncurrent_days           = 30
    }
  }
}
