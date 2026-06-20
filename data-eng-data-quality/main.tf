data "aws_sns_topic" "data_engineering" {
  name = "sns-slack-alerting-data-engineering"
}

# Upload the DQDL rules file — used by the ruleset and read by the Glue job at runtime.
resource "aws_s3_object" "dqdl_script" {
  bucket       = local.bucket_name
  key          = local.dqdl_s3_key
  source       = "${path.module}/scripts/tenmaid_uat_members.dqdl"
  etag         = filemd5("${path.module}/scripts/tenmaid_uat_members.dqdl")
  content_type = "text/plain"
}

# Upload the Pandas data quality runner script.
resource "aws_s3_object" "data_quality_script" {
  bucket       = local.bucket_name
  key          = local.script_s3_key
  source       = "${path.module}/scripts/data_quality.py"
  etag         = filemd5("${path.module}/scripts/data_quality.py")
  content_type = "text/x-python"
}

resource "aws_glue_data_quality_ruleset" "tenmaid_uat_members" {
  name        = var.ruleset_name
  description = "TENMAID_UAT Members checks for schemes 2388 and 2378."

  ruleset = file("${path.module}/scripts/tenmaid_uat_members.dqdl")

  target_table {
    database_name = data.terraform_remote_state.hsbc_datafeed.outputs.glue_catalog_database_name
    table_name    = var.glue_catalog_table_name
  }

  depends_on = [aws_s3_object.dqdl_script]
}

# IAM role for the data quality Glue Python Shell job.
resource "aws_iam_role" "data_quality_glue" {
  name = var.glue_job_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "data_quality_glue_service" {
  role       = aws_iam_role.data_quality_glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "data_quality_glue_access" {
  name        = "${var.glue_job_role_name}-access"
  description = "Allows the data quality Glue job to read scripts from S3, fetch the JDBC secret, and call Glue Data Quality APIs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PassRoleToGlueDQ"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = ["arn:aws:iam::${local.workspace_account_id}:role/${var.glue_job_role_name}"]
      },
      {
        Sid    = "ReadScriptsFromS3"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:GetObjectVersion"]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}/${local.script_s3_key}",
          "arn:aws:s3:::${local.bucket_name}/${local.dqdl_s3_key}",
          "arn:aws:s3:::${local.bucket_name}/HSBC/incoming/*",
        ]
      },
      {
        Sid      = "FetchJdbcSecret"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [data.aws_secretsmanager_secret.jdbc_credentials.arn]
      },
      {
        Sid    = "GlueDataQualityApis"
        Effect = "Allow"
        Action = [
          "glue:GetConnection",
          "glue:StartDataQualityRulesetEvaluationRun",
          "glue:GetDataQualityRulesetEvaluationRun",
          "glue:GetDataQualityResult",
        ]
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_quality_glue_access" {
  role       = aws_iam_role.data_quality_glue.name
  policy_arn = aws_iam_policy.data_quality_glue_access.arn
}

resource "aws_glue_job" "data_quality" {
  name         = var.glue_job_name
  description  = "Daily Pandas data quality checks for TENMAID_UAT Members with Glue Data Quality console results."
  role_arn     = aws_iam_role.data_quality_glue.arn
  glue_version = "4.0"
  max_capacity = 0.0625 # 1 DPU Python Shell

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = local.script_s3_path
  }

  default_arguments = {
    "--additional-python-modules"        = "pandas==2.2.3,pymssql==2.3.2"
    "--JDBC_SECRET_ARN"                  = data.aws_secretsmanager_secret.jdbc_credentials.arn
    "--DQDL_S3_PATH"                     = local.dqdl_s3_path
    "--RULESET_NAME"                     = var.ruleset_name
    "--GLUE_DATABASE_NAME"               = data.terraform_remote_state.hsbc_datafeed.outputs.glue_catalog_database_name
    "--GLUE_TABLE_NAME"                  = var.glue_catalog_table_name
    "--GLUE_CONNECTION_NAME"             = var.glue_jdbc_connection_name
    "--AWS_REGION"                       = var.aws_region
    "--enable-continuous-cloudwatch-log" = "true"
  }

  connections = [var.glue_network_connection_name]

  depends_on = [
    aws_s3_object.data_quality_script,
    aws_s3_object.dqdl_script,
    aws_iam_role_policy_attachment.data_quality_glue_service,
    aws_iam_role_policy_attachment.data_quality_glue_access,
  ]
}

# Run daily at 14:00 UTC.
resource "aws_glue_trigger" "data_quality_daily" {
  name     = "${var.glue_job_name}-daily"
  type     = "SCHEDULED"
  schedule = "cron(0 14 * * ? *)"

  actions {
    job_name = aws_glue_job.data_quality.name
  }
}

resource "aws_cloudwatch_metric_alarm" "tenmaid_uat_members_null_values" {
  alarm_name          = "${var.ruleset_name}-null-values-${terraform.workspace}"
  alarm_description   = "Alerts the data engineering Slack channel when Reference1 is null for SchemeID 2388 or 2378."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 0
  metric_name         = var.data_quality_failed_metric_name
  namespace           = var.data_quality_metric_namespace
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DataQualityEvaluationContext = var.data_quality_evaluation_context
  }

  alarm_actions = [data.aws_sns_topic.data_engineering.arn]
  ok_actions    = [data.aws_sns_topic.data_engineering.arn]
}
