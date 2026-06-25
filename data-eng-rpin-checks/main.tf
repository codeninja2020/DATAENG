# Package only the Lambda handler. Runtime rules are read from S3.
data "archive_file" "rpin_lambda" {
  type        = "zip"
  output_path = "${path.module}/.terraform/rpin_data_quality_${terraform.workspace}.zip"

  source {
    content  = file("${path.module}/scripts/rpin_data_quality.py")
    filename = "rpin_data_quality.py"
  }
}

# Resolve the existing database credentials secret.
data "aws_secretsmanager_secret" "db_credentials" {
  name = var.db_secret_name
}

# Existing Data Engineering Slack SNS integration used by CloudWatch alarms.
data "aws_sns_topic" "data_engineering" {
  name = "sns-slack-alerting-data-engineering"
}

# Existing BI bucket used for both rule input and RPIN error output.
data "aws_s3_bucket" "error_bucket" {
  bucket = local.error_bucket_name
}

# Upload the rule CSV so checks can be changed without editing Lambda code.
resource "aws_s3_object" "rpin_rules" {
  bucket       = data.aws_s3_bucket.error_bucket.id
  key          = "${trimsuffix(var.rules_prefix, "/")}/rpin_checks.csv"
  source       = "${path.module}/scripts/rpin_checks.csv"
  etag         = filemd5("${path.module}/scripts/rpin_checks.csv")
  content_type = "text/csv"
}

# Upload the Python dependency layer artifact so Lambda can reference it by S3 object.
resource "aws_s3_object" "pymysql_layer" {
  bucket       = data.aws_s3_bucket.error_bucket.id
  key          = "${trimsuffix(var.rules_prefix, "/")}/pymysql.zip"
  source       = "${path.module}/scripts/pymysql.zip"
  etag         = filemd5("${path.module}/scripts/pymysql.zip")
  content_type = "application/zip"
}

resource "aws_lambda_layer_version" "pymysql" {
  layer_name          = "${var.lambda_function_name}-pymysql"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = data.aws_s3_bucket.error_bucket.id
  s3_key              = aws_s3_object.pymysql_layer.key
  source_code_hash    = filebase64sha256("${path.module}/scripts/pymysql.zip")
}

# Trust policy for Lambda execution.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

# Least-privilege runtime permissions for the Lambda.
data "aws_iam_policy_document" "rpin_lambda_access" {
  statement {
    sid       = "FetchJdbcSecret"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [data.aws_secretsmanager_secret.db_credentials.arn]
  }

  statement {
    # CloudWatch metrics do not support resource-level scoping.
    sid       = "PublishDataQualityMetric"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    sid       = "WriteErrorFile"
    actions   = ["s3:PutObject"]
    resources = ["${data.aws_s3_bucket.error_bucket.arn}/${trimsuffix(var.error_prefix, "/")}/*"]
  }

  statement {
    sid       = "ReadRuleFiles"
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.error_bucket.arn}/${aws_s3_object.rpin_rules.key}"]
  }
}

data "aws_iam_policy_document" "scheduler_invoke_lambda" {
  statement {
    sid       = "InvokeRpinDataQualityLambda"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.rpin_data_quality.arn]
  }
}

# Lambda execution role and policy attachments.
resource "aws_iam_role" "rpin_lambda" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "rpin_scheduler" {
  name               = "${var.lambda_function_name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_policy" "rpin_lambda_access" {
  name        = "${var.lambda_role_name}-access"
  description = "Allows the RPIN data quality Lambda to fetch DB credentials and publish metrics."
  policy      = data.aws_iam_policy_document.rpin_lambda_access.json
}

resource "aws_iam_policy" "scheduler_invoke_lambda" {
  name        = "${var.lambda_function_name}-scheduler-invoke"
  description = "Allows EventBridge Scheduler to invoke the RPIN data quality Lambda."
  policy      = data.aws_iam_policy_document.scheduler_invoke_lambda.json
}

resource "aws_iam_role_policy_attachment" "rpin_lambda_access" {
  role       = aws_iam_role.rpin_lambda.name
  policy_arn = aws_iam_policy.rpin_lambda_access.arn
}

resource "aws_iam_role_policy_attachment" "scheduler_invoke_lambda" {
  role       = aws_iam_role.rpin_scheduler.name
  policy_arn = aws_iam_policy.scheduler_invoke_lambda.arn
}

resource "aws_iam_role_policy_attachment" "rpin_lambda_basic_execution" {
  role       = aws_iam_role.rpin_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "rpin_lambda_vpc_access" {
  role       = aws_iam_role.rpin_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# The Lambda runs inside the QA RDS VPC and reads DB credentials from Secrets Manager.
resource "aws_lambda_function" "rpin_data_quality" {
  filename         = data.archive_file.rpin_lambda.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.rpin_lambda.arn
  handler          = "rpin_data_quality.lambda_handler"
  source_code_hash = data.archive_file.rpin_lambda.output_base64sha256
  runtime          = "python3.11"
  timeout          = 300
  memory_size      = 512
  layers           = concat(var.lambda_layer_arns, [aws_lambda_layer_version.pymysql.arn])

  environment {
    # SQL text comes from the S3 rule file; DB credentials and target are environment config.
    variables = {
      AWS_REGION        = var.aws_region
      ERROR_BUCKET      = data.aws_s3_bucket.error_bucket.id
      ERROR_PREFIX      = var.error_prefix
      DB_SECRET_ARN     = data.aws_secretsmanager_secret.db_credentials.arn
      DB_CONNECTION_URL = local.db_connection_url
      METRIC_NAME       = var.finding_metric_name
      METRIC_NAMESPACE  = var.metric_namespace
      RULES_BUCKET      = data.aws_s3_bucket.error_bucket.id
      RULES_KEY         = aws_s3_object.rpin_rules.key
    }
  }

  vpc_config {
    # Required for network access to the QA SQL Server RDS instance.
    subnet_ids         = local.rds_vpc.subnet_ids
    security_group_ids = local.rds_vpc.security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.rpin_lambda_access,
    aws_iam_role_policy_attachment.rpin_lambda_basic_execution,
    aws_iam_role_policy_attachment.rpin_lambda_vpc_access,
    aws_lambda_layer_version.pymysql,
    aws_s3_object.rpin_rules,
  ]
}

# Daily EventBridge Scheduler invocation at 10:00 in the eu-west-1 regional timezone.
resource "aws_scheduler_schedule" "rpin_data_quality_daily" {
  name                         = "${var.lambda_function_name}-daily"
  description                  = "Runs the RPIN data quality Lambda."
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.rpin_data_quality.arn
    role_arn = aws_iam_role.rpin_scheduler.arn
  }
}

# Alert on observed RPIN data quality findings.
resource "aws_cloudwatch_metric_alarm" "rpin_findings" {
  alarm_name          = "${var.lambda_function_name}-findings-${terraform.workspace}"
  alarm_description   = "P2 - Alerts when the RPIN data quality check finds Members rows with missing Reference1 values."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 0
  metric_name         = var.finding_metric_name
  namespace           = var.metric_namespace
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  dimensions = {
    CheckName = var.check_name
  }

  alarm_actions = [data.aws_sns_topic.data_engineering.arn]
  ok_actions    = [data.aws_sns_topic.data_engineering.arn]
}
