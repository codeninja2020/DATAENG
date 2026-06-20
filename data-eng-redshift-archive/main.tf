# Create the workspace-specific S3 bucket used for Redshift archives.
module "redshift_archive_s3_bucket" {
  source = "../modules/s3-bucket"

  s3_bucket_name      = local.bucket_name
  enable_versioning   = true
  intelligent_tiering = true
}

# Allow Amazon Redshift to assume the archive upload role.
data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

# Create the IAM role in the QA account for the Redshift cluster.
resource "aws_iam_role" "redshift_archive_put" {
  provider = aws.usw2

  name               = local.redshift_role_name
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
}

# Grant the Redshift role permission to list the archive bucket.
data "aws_iam_policy_document" "redshift_archive_put" {
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      module.redshift_archive_s3_bucket.s3_bucket_arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${module.redshift_archive_s3_bucket.s3_bucket_arn}/*"]
  }
}

# Attach the least-privilege S3 read, list, and write policy to the Redshift role.
resource "aws_iam_role_policy" "redshift_archive_put" {
  provider = aws.usw2

  name   = local.redshift_role_name
  role   = aws_iam_role.redshift_archive_put.id
  policy = data.aws_iam_policy_document.redshift_archive_put.json
}

# Allow the cross-account Redshift role to access the production archive bucket.
data "aws_iam_policy_document" "redshift_archive_bucket_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.redshift_archive_put.arn]
    }

    actions   = ["s3:ListBucket"]
    resources = [module.redshift_archive_s3_bucket.s3_bucket_arn]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.redshift_archive_put.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${module.redshift_archive_s3_bucket.s3_bucket_arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "redshift_archive_access" {
  bucket = module.redshift_archive_s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.redshift_archive_bucket_access.json
}

# Read the existing Redshift cluster and its currently associated IAM roles.
data "aws_redshift_cluster" "selected" {
  provider = aws.usw2

  cluster_identifier = local.redshift_cluster
}

# Add the archive upload role while preserving the cluster's existing IAM roles.
resource "aws_redshift_cluster_iam_roles" "archive_put" {
  provider = aws.usw2

  cluster_identifier = local.redshift_cluster
  iam_role_arns = distinct(concat(
    data.aws_redshift_cluster.selected.iam_roles,
    [aws_iam_role.redshift_archive_put.arn],
  ))

  lifecycle {
    prevent_destroy = true
  }
}
