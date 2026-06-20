# Create Lambda zip.
data "archive_file" "lambda_s3_archive" {
  type        = "zip"
  source_dir  = "${path.module}/scripts"
  output_path = "${path.module}/.terraform/lambda_s3_archive_${terraform.workspace}.zip"
}

data "aws_s3_bucket" "selected" {
  bucket = local.workspace.s3_bucket_name
}

resource "aws_iam_role" "lambda_s3_archive_role" {
  name = "s3-delete-lambda-s3-archive-${terraform.workspace}"
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
    Name = "s3-delete-lambda-s3-archive-${terraform.workspace}"
  }
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "s3-delete-lambda-s3-policy-${terraform.workspace}"
  role = aws_iam_role.lambda_s3_archive_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = local.archive_source_object_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = local.archive_target_object_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_s3_archive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "s3_archive" {
  filename         = data.archive_file.lambda_s3_archive.output_path
  function_name    = "s3-delete-${terraform.workspace}"
  role             = aws_iam_role.lambda_s3_archive_role.arn
  handler          = "lambda_s3_delete.lambda_handler"
  source_code_hash = data.archive_file.lambda_s3_archive.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      ARCHIVE_ROOTS  = join(",", local.archive_roots)
      ARCHIVE_FOLDER = local.archive_folder_name
      TARGET_FOLDER  = local.target_folder_name
      TARGET_BUCKET  = local.target_bucket_name
      DELETE_TARGET  = "true"
    }
  }

  tags = {
    Name = "s3-delete-s3-archive-${terraform.workspace}"
  }

  depends_on = [
    aws_iam_role_policy.lambda_s3_policy,
    aws_iam_role_policy_attachment.lambda_basic_execution
  ]
}

resource "aws_s3_bucket_notification" "s3_delete_bucket_notification" {
  bucket = data.aws_s3_bucket.selected.id

  dynamic "lambda_function" {
    for_each = local.archive_roots

    content {
      lambda_function_arn = aws_lambda_function.s3_archive.arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = "${lambda_function.value}/${local.archive_folder_name}/"
    }
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_archive.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.source_bucket_arn
}
