# AWS Transfer SFTP server with an ivector bucket and managed user

locals {
  ivector_bucket_name = "ivector-${terraform.workspace}"
  ivector_bucket_arn  = "arn:aws:s3:::${local.ivector_bucket_name}"
}

resource "aws_s3_bucket" "ivector" {
  bucket        = local.ivector_bucket_name
  force_destroy = false

  tags = {
    Name = local.ivector_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "ivector" {
  bucket                  = aws_s3_bucket.ivector.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Role assumed by AWS Transfer to access S3
resource "aws_iam_role" "transfer_access" {
  name = "datafeeds-transfer-ivector-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "transfer_s3_policy" {
  name = "datafeeds-transfer-ivector-s3-${terraform.workspace}"
  role = aws_iam_role.transfer_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = local.ivector_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${local.ivector_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_transfer_server" "ivector" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
  endpoint_type          = "PUBLIC"

  tags = {
    Name = "ivector-${terraform.workspace}"
  }
}

# Managed Transfer user with a dummy SSH public key (replace before use)
resource "aws_transfer_user" "ivector_user" {
  server_id = aws_transfer_server.ivector.id
  user_name = "ivector-user"
  role      = aws_iam_role.transfer_access.arn

  home_directory      = "/${local.ivector_bucket_name}/home/ivector-user"
  home_directory_type = "PATH"

  ssh_public_key_body = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdummyReplaceMeForRealKey ivector@example"

  depends_on = [
    aws_s3_bucket.ivector,
    aws_iam_role_policy.transfer_s3_policy
  ]
}

