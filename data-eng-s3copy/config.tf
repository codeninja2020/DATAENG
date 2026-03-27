# Archive Lambda function code and dependencies
data "archive_file" "lambda_s3_archive" {
  type        = "zip"
  source_dir  = "${path.module}/scripts"
  output_path = "${path.module}/.terraform/lambda_s3_archive_${terraform.workspace}.zip"

  # Ensure the archive is recreated when source files change
  depends_on = []
}

locals {
  # Using the single bucket defined in locals.tf for both source (event) and target (deletion) paths.
  source_bucket_name = local.workspace.s3_bucket_name
  target_bucket_name = local.workspace.s3_bucket_name
  source_bucket_arn  = "arn:aws:s3:::${local.source_bucket_name}"
  target_bucket_arn  = "arn:aws:s3:::${local.target_bucket_name}"
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_s3_archive_role" {
  name               = "datafeeds-lambda-s3-archive-${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "datafeeds-lambda-s3-archive-${terraform.workspace}"
  }
}

# Allow Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_s3_archive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy allowing S3 operations (HeadObject and DeleteObject)
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "datafeeds-lambda-s3-policy-${terraform.workspace}"
  role = aws_iam_role.lambda_s3_archive_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:DeleteObject"
        ]
        Resource = "${local.target_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = local.target_bucket_arn
      }
    ]
  })

  depends_on = [module.ten_copilot_frontend_s3_bucket]
}

# Lambda function
resource "aws_lambda_function" "s3_archive" {
  filename         = data.archive_file.lambda_s3_archive.output_path
  function_name    = "datafeeds-s3-archive-${terraform.workspace}"
  role             = aws_iam_role.lambda_s3_archive_role.arn
  handler          = "lambda_s3_archive.lambda_handler"
  source_code_hash = data.archive_file.lambda_s3_archive.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      TARGET_BUCKET = local.target_bucket_name
      TARGET_PREFIX = "archive/"
      DELETE_TARGET = "true"
    }
  }

  tags = {
    Name = "datafeeds-s3-archive-${terraform.workspace}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_s3_policy,
    module.ten_copilot_frontend_s3_bucket
  ]
}

# S3 bucket notification configuration to trigger Lambda on object creation
resource "aws_s3_bucket_notification" "datafeeds_bucket_notification" {
  bucket = local.source_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_archive.arn
    events              = ["s3:ObjectCreated:*"]
    # Uncomment and adjust if you want to filter by prefix or suffix
    # filter_prefix       = "uploads/"
    # filter_suffix       = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke,
    module.ten_copilot_frontend_s3_bucket
  ]
}

# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_archive.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.source_bucket_arn

  depends_on = [module.ten_copilot_frontend_s3_bucket]
}
