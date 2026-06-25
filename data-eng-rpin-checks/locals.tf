locals {
  # This component is intentionally scoped to QA for the first rollout.
  supported_workspaces = ["qa"]

  account_id = {
    qa = "236130610212"
  }

  db_connection_urls = {
    qa = "jdbc:sqlserver://tenmaid-v1-db-qa-eu-west-1.csqvz1wpln3e.eu-west-1.rds.amazonaws.com:1433;databaseName=TENMAID_UAT;encrypt=true;trustServerCertificate=false;loginTimeout=30"
  }

  error_bucket_names = {
    qa = "bi-qa.tenproduct.com"
  }

  rds_vpc_config = {
    # QA subnet and security group used for SQL Server RDS connectivity.
    qa = {
      subnet_ids         = ["subnet-003ac5a8b9146333f"]
      security_group_ids = ["sg-08ce049c284191bfa"]
    }
  }

  workspace_account_id = lookup(local.account_id, terraform.workspace, "000000000000")
  error_bucket_name    = lookup(local.error_bucket_names, terraform.workspace, "unsupported-workspace")
  db_connection_url    = coalesce(var.db_connection_url, lookup(local.db_connection_urls, terraform.workspace, null))
  rds_vpc = lookup(local.rds_vpc_config, terraform.workspace, {
    subnet_ids         = []
    security_group_ids = []
  })
}

check "supported_workspace" {
  # Fail fast if CI or a local run selects a workspace this component does not support.
  assert {
    condition     = contains(local.supported_workspaces, terraform.workspace)
    error_message = "This component only supports the qa Terraform workspace."
  }
}
