# Package the S3 object rename Lambda from the local scripts directory.
data "archive_file" "lambda_s3_rename" {
  type        = "zip"
  source_dir  = "${path.module}/scripts"
  output_path = "${path.module}/.terraform/lambda_s3_rename_${terraform.workspace}.zip"
}

data "aws_s3_bucket" "ivector" {
  bucket = local.ivector_bucket_name
}

# IAM role assumed by AWS Transfer Family for the Ivector SFTP user.
resource "aws_iam_role" "ivector_transfer_access" {
  name = local.ivector_transfer_role_name

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

# S3 access policy scoped to the Ivector user's home directory prefix.
resource "aws_iam_policy" "ivector_transfer_s3" {
  name = local.ivector_transfer_policy_name

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
        Condition = {
          StringLike = {
            "s3:prefix" = [
              local.ivector_home_directory_prefix,
              "${local.ivector_home_directory_prefix}/*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${local.ivector_bucket_arn}/${local.ivector_home_directory_prefix}/*"
      }
    ]
  })
}

# Attach the Ivector S3 access policy to the Transfer Family role.
resource "aws_iam_role_policy_attachment" "ivector_transfer_s3" {
  role       = aws_iam_role.ivector_transfer_access.name
  policy_arn = aws_iam_policy.ivector_transfer_s3.arn
}

# IAM role assumed by AWS Transfer Family for the Mercury Hub SFTP user.
resource "aws_iam_role" "mercury_hub_transfer_access" {
  name = local.mercury_hub_transfer_role_name

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

# S3 access policy scoped to the Mercury Hub user's home directory prefix.
resource "aws_iam_policy" "mercury_hub_transfer_s3" {
  name = local.mercury_hub_transfer_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = local.mercury_hub_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              local.mercury_hub_home_directory_prefix,
              "${local.mercury_hub_home_directory_prefix}/*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${local.mercury_hub_bucket_arn}/${local.mercury_hub_home_directory_prefix}/*"
      }
    ]
  })
}

# Attach the Mercury Hub S3 access policy to the Transfer Family role.
resource "aws_iam_role_policy_attachment" "mercury_hub_transfer_s3" {
  role       = aws_iam_role.mercury_hub_transfer_access.name
  policy_arn = aws_iam_policy.mercury_hub_transfer_s3.arn
}

# IAM role assumed by AWS Transfer Family for the Petru SFTP user.
resource "aws_iam_role" "petru_transfer_access" {
  name = local.petru_transfer_role_name

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

# S3 access policy allowing Petru to read and write both Ivector and Mercury Hub prefixes.
resource "aws_iam_policy" "petru_transfer_s3" {
  name = local.petru_transfer_policy_name

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
        Condition = {
          StringLike = {
            "s3:prefix" = [
              local.ivector_home_directory_prefix,
              "${local.ivector_home_directory_prefix}/*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = local.mercury_hub_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              local.mercury_hub_home_directory_prefix,
              "${local.mercury_hub_home_directory_prefix}/*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = [
          "${local.ivector_bucket_arn}/${local.ivector_home_directory_prefix}/*",
          "${local.mercury_hub_bucket_arn}/${local.mercury_hub_home_directory_prefix}/*"
        ]
      }
    ]
  })
}

# Attach the Petru S3 access policy to the Transfer Family role.
resource "aws_iam_role_policy_attachment" "petru_transfer_s3" {
  role       = aws_iam_role.petru_transfer_access.name
  policy_arn = aws_iam_policy.petru_transfer_s3.arn
}

# Lambda role used by data-eng-file-rename to normalize uploaded SFTP filenames.
resource "aws_iam_role" "file_rename_lambda" {
  name = local.file_rename_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# S3 object access policy for the file rename Lambda.
resource "aws_iam_policy" "file_rename_s3" {
  name = local.file_rename_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = local.ivector_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = concat(
              local.file_rename_roots,
              [for root in local.file_rename_roots : "${root}/*"]
            )
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionTagging",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectTagging",
          "s3:DeleteObjectVersion"
        ]
        Resource = local.file_rename_object_arns
      }
    ]
  })
}

# Attach the S3 rename policy to the file rename Lambda role.
resource "aws_iam_role_policy_attachment" "file_rename_s3" {
  role       = aws_iam_role.file_rename_lambda.name
  policy_arn = aws_iam_policy.file_rename_s3.arn
}

# Attach AWS managed CloudWatch Logs permissions to the file rename Lambda role.
resource "aws_iam_role_policy_attachment" "file_rename_basic_execution" {
  role       = aws_iam_role.file_rename_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# The function copies each object to its cleaned key and deletes the original object.
resource "aws_lambda_function" "file_rename" {
  filename         = data.archive_file.lambda_s3_rename.output_path
  function_name    = local.file_rename_function_name
  role             = aws_iam_role.file_rename_lambda.arn
  handler          = "lambda_s3_rename.lambda_handler"
  source_code_hash = data.archive_file.lambda_s3_rename.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      BUCKET = local.ivector_bucket_name
      ROOTS  = join(",", local.file_rename_roots)
    }
  }

  tags = {
    Name = local.file_rename_function_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.file_rename_basic_execution,
    aws_iam_role_policy_attachment.file_rename_s3
  ]
}

# Allow the Ivector bucket to invoke the file rename Lambda.
resource "aws_lambda_permission" "allow_s3_invoke_file_rename" {
  statement_id  = "AllowExecutionFromS3FileRename"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_rename.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.ivector_bucket_arn
}

# S3 bucket notifications are owned as a single resource per bucket.
resource "aws_s3_bucket_notification" "file_rename" {
  bucket = data.aws_s3_bucket.ivector.id

  dynamic "lambda_function" {
    for_each = local.file_rename_roots

    content {
      lambda_function_arn = aws_lambda_function.file_rename.arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = "${lambda_function.value}/"
    }
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_file_rename
  ]
}

resource "random_password" "petru_user_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "archive_file" "transfer_identity_provider" {
  type        = "zip"
  output_path = "${path.module}/.terraform/archive/transfer_identity_provider.zip"

  source {
    content  = file("${path.module}/lambda/transfer_identity_provider.py")
    filename = "transfer_identity_provider.py"
  }
}

resource "aws_iam_role" "transfer_identity_provider" {
  name = local.transfer_auth_lambda_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "transfer_identity_provider_secrets" {
  name = "${local.transfer_auth_lambda_name}-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [for secret in aws_secretsmanager_secret.transfer_user : secret.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "transfer_identity_provider_secrets" {
  role       = aws_iam_role.transfer_identity_provider.name
  policy_arn = aws_iam_policy.transfer_identity_provider_secrets.arn
}

resource "aws_iam_role_policy_attachment" "transfer_identity_provider_logs" {
  role       = aws_iam_role.transfer_identity_provider.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "transfer_identity_provider" {
  function_name = local.transfer_auth_lambda_name
  description   = "AWS Transfer Family custom identity provider for ${local.transfer_server_name}"

  filename         = data.archive_file.transfer_identity_provider.output_path
  source_code_hash = data.archive_file.transfer_identity_provider.output_base64sha256

  role    = aws_iam_role.transfer_identity_provider.arn
  runtime = "python3.12"
  handler = "transfer_identity_provider.lambda_handler"

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      TRANSFER_USER_SECRET_PREFIX = local.transfer_user_secret_prefix
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.transfer_identity_provider_logs,
    aws_iam_role_policy_attachment.transfer_identity_provider_secrets
  ]
}

resource "aws_transfer_server" "ivector" {
  identity_provider_type      = "AWS_LAMBDA"
  protocols                   = ["SFTP"]
  endpoint_type               = "PUBLIC"
  function                    = aws_lambda_function.transfer_identity_provider.arn
  sftp_authentication_methods = "PUBLIC_KEY_OR_PASSWORD"

  lifecycle {
    precondition {
      condition     = local.workspace_supported
      error_message = "Unsupported workspace. This component supports only staging and prod."
    }
  }

  tags = {
    Name = local.transfer_server_name
  }
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_transfer_invoke_identity_provider" {
  statement_id   = "AllowTransferFamilyInvokeIdentityProvider"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.transfer_identity_provider.function_name
  principal      = "transfer.amazonaws.com"
  source_arn     = aws_transfer_server.ivector.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_secretsmanager_secret" "transfer_user" {
  for_each = local.transfer_users

  name = "${local.transfer_user_secret_prefix}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "transfer_user" {
  for_each = local.transfer_users

  secret_id = aws_secretsmanager_secret.transfer_user[each.key].id
  secret_string = jsonencode({
    Password             = each.value.password
    PublicKeys           = each.value.public_keys
    Role                 = each.value.role_arn
    HomeDirectory        = try(each.value.home_directory, null)
    HomeDirectoryType    = each.value.home_directory_type
    HomeDirectoryDetails = try(each.value.home_directory_details, null)
  })

  depends_on = [
    aws_iam_role_policy_attachment.ivector_transfer_s3,
    aws_iam_role_policy_attachment.mercury_hub_transfer_s3,
    aws_iam_role_policy_attachment.petru_transfer_s3
  ]
}
