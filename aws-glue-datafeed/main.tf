# Glue execution role and least-privilege datafeed access.
resource "aws_iam_role" "hsbc_glue" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "hsbc_glue_service" {
  role       = aws_iam_role.hsbc_glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "hsbc_glue_datafeed_access" {
  name = "${var.glue_job_name}-datafeed-access"

  policy = data.aws_iam_policy_document.hsbc_glue_datafeed_access.json
}

data "aws_iam_policy_document" "hsbc_glue_datafeed_access" {
  # Read/write/delete access scoped to the three HSBC feed prefixes.
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]
    resources = local.datafeed_object_arns
  }

  # Read access for the Glue script, JDBC driver, and helper modules.
  statement {
    actions = ["s3:GetObject"]
    resources = concat(
      [
        local.glue_script_s3_arn,
        local.jdbc_driver_s3_arn,
      ],
      local.extra_py_files_s3_arns
    )
  }

  # Bucket-level listing scoped to the HSBC prefixes only.
  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.datafeed_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [for prefix in local.datafeed_prefixes : "${trimsuffix(prefix, "/")}/*"]
    }
  }

  # Read the JDBC credentials from Secrets Manager.
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.jdbc_credentials.arn]
  }
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

data "sops_file" "hsbc_qa_secret" {
  source_file = "./secrets/hsbc_qa_secret.json.enc"
  input_type  = "json"
}

resource "aws_secretsmanager_secret" "jdbc_credentials" {
  name        = "${var.glue_job_name}-jdbc-credentials"
  description = "JDBC credentials for the HSBC datafeed Glue job. SecretString must be JSON with username TJamboStg and password keys."
}

# Store the SOPS-managed JDBC credentials in Secrets Manager for Glue.
resource "aws_secretsmanager_secret_version" "jdbc_credentials" {
  secret_id = aws_secretsmanager_secret.jdbc_credentials.id
  secret_string = jsonencode({
    username = data.sops_file.hsbc_qa_secret.data["username"]
    password = data.sops_file.hsbc_qa_secret.data["password"]
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Resolve the VPC from the Glue connection subnet so the Secrets Manager
# interface endpoint stays aligned with the workspace VPC config.
data "aws_subnet" "rds" {
  count = local.rds_vpc != null ? 1 : 0

  id = try(local.rds_vpc.subnet_id, null)
}

resource "aws_iam_role_policy_attachment" "hsbc_glue_datafeed_access" {
  role       = aws_iam_role.hsbc_glue.name
  policy_arn = aws_iam_policy.hsbc_glue_datafeed_access.arn
}

# Upload the existing Glue entrypoint without changing its Terraform address.
resource "aws_s3_object" "glue_mssql_etl_script" {
  bucket       = local.datafeed_bucket_name
  key          = "${local.scripts_prefix}/glue_mssql_etl.py"
  source       = "${path.module}/scripts/glue_mssql_etl.py"
  etag         = filemd5("${path.module}/scripts/glue_mssql_etl.py")
  content_type = "text/x-python"
}

# Upload the shared helper modules.
resource "aws_s3_object" "glue_python_script" {
  for_each = {
    load       = "load.py"
    validation = "validation.py"
  }

  bucket       = local.datafeed_bucket_name
  key          = "${local.scripts_prefix}/${each.value}"
  source       = "${path.module}/scripts/${each.value}"
  etag         = filemd5("${path.module}/scripts/${each.value}")
  content_type = "text/x-python"
}

# Network connection giving Glue access to the RDS VPC. Only created when VPC config
# exists for the current workspace. The AWSGlueServiceRole managed policy provides
# the ec2:CreateNetworkInterface and related permissions needed for ENI creation.
resource "aws_glue_connection" "rds_vpc" {
  count = local.rds_vpc != null ? 1 : 0

  name            = "${var.glue_job_name}-rds-vpc"
  connection_type = "NETWORK"

  physical_connection_requirements {
    subnet_id              = try(local.rds_vpc.subnet_id, null)
    security_group_id_list = try(local.rds_vpc.security_group_ids, null)
    availability_zone      = try(local.rds_vpc.availability_zone, null)
  }
}

resource "aws_glue_catalog_database" "tenmaid_uat" {
  name        = var.glue_catalog_database_name
  description = "Data Catalog database for TENMAID_UAT SQL Server metadata."
}

resource "aws_glue_connection" "tenmaid_uat_jdbc" {
  count = local.rds_vpc != null ? 1 : 0

  name            = "${var.glue_job_name}-tenmaid-uat-jdbc"
  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = local.crawler_jdbc_url
    SECRET_ID           = aws_secretsmanager_secret.jdbc_credentials.arn
  }

  physical_connection_requirements {
    subnet_id              = try(local.rds_vpc.subnet_id, null)
    security_group_id_list = try(local.rds_vpc.security_group_ids, null)
    availability_zone      = try(local.rds_vpc.availability_zone, null)
  }
}

resource "aws_glue_crawler" "tenmaid_uat" {
  count = local.rds_vpc != null ? 1 : 0

  name          = var.glue_crawler_name
  database_name = aws_glue_catalog_database.tenmaid_uat.name
  role          = aws_iam_role.hsbc_glue.arn
  table_prefix  = var.glue_crawler_table_prefix

  jdbc_target {
    connection_name = aws_glue_connection.tenmaid_uat_jdbc[0].name
    path            = var.glue_crawler_jdbc_path
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.hsbc_glue_service,
    aws_iam_role_policy_attachment.hsbc_glue_datafeed_access,
    aws_glue_connection.tenmaid_uat_jdbc
  ]
}

# AWS Glue requires self-referencing rules on security groups attached to a VPC connection.
resource "aws_security_group_rule" "glue_self_ingress" {
  for_each = local.rds_vpc != null ? toset(local.rds_vpc.security_group_ids) : toset([])

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = each.value
  description       = "Allow Glue ENI communication within the security group"
}

resource "aws_security_group_rule" "glue_self_egress" {
  for_each = local.rds_vpc != null ? toset(local.rds_vpc.security_group_ids) : toset([])

  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = each.value
  description       = "Allow Glue ENI communication within the security group"
}

resource "aws_security_group_rule" "glue_s3_egress" {
  for_each = local.rds_vpc != null ? toset(local.rds_vpc.security_group_ids) : toset([])

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.s3.id]
  security_group_id = each.value
  description       = "Allow Glue HTTPS access to S3"
}

# Existing private Secrets Manager endpoint in the Glue/RDS VPC.
data "aws_vpc_endpoint" "secretsmanager" {
  count = local.rds_vpc != null ? 1 : 0

  vpc_id       = data.aws_subnet.rds[0].vpc_id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
}

resource "aws_security_group_rule" "glue_secretsmanager_endpoint_egress" {
  for_each = local.rds_vpc != null ? {
    for pair in setproduct(
      toset(local.rds_vpc.security_group_ids),
      toset(data.aws_vpc_endpoint.secretsmanager[0].security_group_ids),
      ) : "${pair[0]}:${pair[1]}" => {
      glue_sg_id     = pair[0]
      endpoint_sg_id = pair[1]
    }
  } : {}

  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = each.value.glue_sg_id
  source_security_group_id = each.value.endpoint_sg_id
  description              = "Allow Glue HTTPS egress to existing Secrets Manager VPC endpoint"
}

resource "aws_security_group_rule" "secretsmanager_endpoint_ingress_from_glue" {
  for_each = local.rds_vpc != null ? {
    for pair in setproduct(
      toset(data.aws_vpc_endpoint.secretsmanager[0].security_group_ids),
      toset(local.rds_vpc.security_group_ids),
      ) : "${pair[0]}:${pair[1]}" => {
      endpoint_sg_id = pair[0]
      glue_sg_id     = pair[1]
    }
  } : {}

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = each.value.endpoint_sg_id
  source_security_group_id = each.value.glue_sg_id
  description              = "Allow Glue HTTPS ingress to existing Secrets Manager VPC endpoint"
}

# Glue Spark ETL job for validating and merging the HSBC member feed.
resource "aws_glue_job" "hsbc_datafeed" {
  name              = var.glue_job_name
  description       = var.glue_job_description
  role_arn          = aws_iam_role.hsbc_glue.arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = var.timeout_minutes
  max_retries       = var.max_retries

  connections = local.rds_vpc != null ? [aws_glue_connection.rds_vpc[0].name] : []

  command {
    name            = "glueetl"
    script_location = local.glue_script_s3_path
    python_version  = "3"
  }

  # JDBC credentials are read from Secrets Manager. Scheme IDs are injected as
  # Glue customer environment variables because they are non-secret runtime config.
  default_arguments = merge(
    {
      "--job-language"                     = "python"
      "--enable-auto-scaling"              = "true"
      "--enable-metrics"                   = "true"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-observability-metrics"     = "true"
      "--additional-python-modules"        = "boto3==1.35.99,pandas==2.2.3,pymssql==2.3.2"
      "--extra-jars"                       = local.jdbc_driver_s3_path
      "--extra-py-files"                   = join(",", [local.validation_s3_path, local.load_s3_path])
      "--SOURCE_S3_PATH"                   = "s3://${local.datafeed_bucket_name}/${var.incoming_prefix}"
      "--ERROR_S3_PATH"                    = "s3://${local.datafeed_bucket_name}/${var.error_prefix}"
      "--ARCHIVE_S3_PATH"                  = "s3://${local.datafeed_bucket_name}/${var.archive_prefix}"
      "--CHECKPOINT_S3_PATH"               = "s3://${local.datafeed_bucket_name}/${var.checkpoint_prefix}"
      "--JDBC_URL"                         = local.jdbc_url
      "--JDBC_SECRET_ARN"                  = aws_secretsmanager_secret.jdbc_credentials.arn
      "--TARGET_TABLE"                     = var.target_table
      "--INPUT_DELIMITER"                  = var.input_delimiter
      "--customer-driver-env-vars"         = "CUSTOMER_PRIVATE_BANK_SCHEME_ID=1591,CUSTOMER_PREMIER_SCHEME_ID=1587"
    },
    var.glue_default_arguments
  )

  depends_on = [
    # Ensure the entrypoints and helper modules exist before updating the job.
    aws_s3_object.glue_mssql_etl_script,
    aws_s3_object.glue_python_script,
    aws_iam_role_policy_attachment.hsbc_glue_service,
    aws_iam_role_policy_attachment.hsbc_glue_datafeed_access
  ]
}

# Daily schedule trigger at 14:00 UTC (14:00 GMT / 15:00 BST). AWS Glue cron runs in UTC only.
resource "aws_glue_trigger" "hsbc_datafeed_daily" {
  name     = "${var.glue_job_name}-daily"
  type     = "SCHEDULED"
  schedule = "cron(0 14 * * ? *)"

  actions {
    job_name = aws_glue_job.hsbc_datafeed.name
  }
}

# Alert when Glue observability reports a failed job run.
resource "aws_cloudwatch_metric_alarm" "glue_job_errors" {
  alarm_name          = "${aws_glue_job.hsbc_datafeed.name}-job-errors"
  alarm_description   = "P2 - Alerts when the HSBC datafeed Glue ETL job run fails."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 0
  metric_name         = "glue.error.ALL"
  namespace           = "Glue"
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  dimensions = {
    JobName            = aws_glue_job.hsbc_datafeed.name
    JobRunId           = "ALL"
    ObservabilityGroup = "error"
    Type               = "count"
  }

  alarm_actions = [local.data_engineering_slack_topic_arn]
  ok_actions    = [local.data_engineering_slack_topic_arn]
}

# Alert when Spark reports failed tasks during an ETL run.
resource "aws_cloudwatch_metric_alarm" "glue_failed_tasks" {
  alarm_name          = "${aws_glue_job.hsbc_datafeed.name}-failed-tasks"
  alarm_description   = "P3 - Alerts when the HSBC datafeed Glue ETL job reports failed Spark tasks."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 0
  metric_name         = "glue.driver.aggregate.numFailedTasks"
  namespace           = "Glue"
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  dimensions = {
    JobName  = aws_glue_job.hsbc_datafeed.name
    JobRunId = "ALL"
    Type     = "count"
  }

  alarm_actions = [local.data_engineering_slack_topic_arn]
  ok_actions    = [local.data_engineering_slack_topic_arn]
}
