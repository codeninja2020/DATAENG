locals {
  supported_workspaces = ["qa"]

  account_id = {
    qa = "236130610212"
  }

  bucket_names = {
    qa = "bi-qa.tenproduct.com"
  }

  workspace_account_id  = lookup(local.account_id, terraform.workspace, "000000000000")
  bucket_name           = lookup(local.bucket_names, terraform.workspace, "unsupported-workspace")
  dqdl_s3_key           = "data-quality/${var.glue_catalog_table_name}.dqdl"
  script_s3_key         = "data-quality/data_quality.py"
  dqdl_s3_path          = "s3://${local.bucket_name}/${local.dqdl_s3_key}"
  script_s3_path        = "s3://${local.bucket_name}/${local.script_s3_key}"
}

check "supported_workspace" {
  assert {
    condition     = contains(local.supported_workspaces, terraform.workspace)
    error_message = "This component only supports the qa Terraform workspace."
  }
}

data "aws_secretsmanager_secret" "jdbc_credentials" {
  name = var.jdbc_secret_name
}
