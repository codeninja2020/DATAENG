locals {
  supported_workspaces = ["qa"]

  account_id = {
    qa = "236130610212"
  }

  datafeed_bucket_names = {
    qa = "bi-qa.tenproduct.com"
  }

  # Default JDBC URLs per workspace. Override at plan/apply time via var.jdbc_url when needed.
  jdbc_urls = {
    qa = "jdbc:sqlserver://tenmaid-v1-db-qa-eu-west-1.csqvz1wpln3e.eu-west-1.rds.amazonaws.com:1433;databaseName=TENMAID_UAT;encrypt=true;trustServerCertificate=false;loginTimeout=30"
  }

  jdbc_driver_s3_path = "s3://${local.datafeed_bucket_name}/aws_glue/mssql-jdbc-13.4.0.jre11.jar"
  jdbc_driver_s3_arn  = "arn:aws:s3:::${local.datafeed_bucket_name}/aws_glue/mssql-jdbc-13.4.0.jre11.jar"

  # Glue script and helper module paths. Scripts are uploaded to the HSBC scripts prefix in the datafeed bucket.
  scripts_prefix      = "HSBC/scripts"
  glue_script_s3_path = coalesce(var.glue_script_s3_path, "s3://${local.datafeed_bucket_name}/${local.scripts_prefix}/glue_mssql_etl.py")
  glue_script_s3_arn  = coalesce(var.glue_script_s3_arn, "arn:aws:s3:::${local.datafeed_bucket_name}/${local.scripts_prefix}/glue_mssql_etl.py")
  validation_s3_path  = "s3://${local.datafeed_bucket_name}/${local.scripts_prefix}/validation.py"
  load_s3_path        = "s3://${local.datafeed_bucket_name}/${local.scripts_prefix}/load.py"
  extra_py_files_s3_arns = [
    "arn:aws:s3:::${local.datafeed_bucket_name}/${local.scripts_prefix}/validation.py",
    "arn:aws:s3:::${local.datafeed_bucket_name}/${local.scripts_prefix}/load.py",
  ]

  # VPC networking config per workspace for Glue → RDS connectivity.
  rds_vpc_config = {
    qa = {
      subnet_id          = "subnet-003ac5a8b9146333f" # eu-west-1a, ten-apps-nat-subnet-qa
      security_group_ids = ["sg-08ce049c284191bfa"]   # all-outbound from ten apps-qa
      availability_zone  = "eu-west-1a"
    }
  }

  rds_vpc = lookup(local.rds_vpc_config, terraform.workspace, null)

  workspace_account_id = lookup(local.account_id, terraform.workspace, "000000000000")
  datafeed_bucket_name = lookup(local.datafeed_bucket_names, terraform.workspace, "unsupported-workspace")
  datafeed_bucket_arn  = "arn:aws:s3:::${local.datafeed_bucket_name}"
  jdbc_url             = coalesce(var.jdbc_url, lookup(local.jdbc_urls, terraform.workspace, null))
  crawler_jdbc_url = local.jdbc_url != null ? format(
    "%s;",
    regex("^jdbc:sqlserver://[^;]+;databaseName=[^;]+", local.jdbc_url)
  ) : null
  data_engineering_slack_topic_arn = (
    "arn:aws:sns:${var.aws_region}:${local.workspace_account_id}:sns-slack-alerting-data-engineering"
  )

  datafeed_prefixes = [
    var.incoming_prefix,
    var.error_prefix,
    var.archive_prefix,
    var.checkpoint_prefix,
  ]

  datafeed_object_arns = [
    for prefix in local.datafeed_prefixes : "${local.datafeed_bucket_arn}/${trimsuffix(prefix, "/")}/*"
  ]
}
