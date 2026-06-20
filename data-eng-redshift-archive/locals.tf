locals {
  # AWS account IDs keyed by Terraform workspace.
  account_id = {
    prod = "171408413795"
  }

  workspace_account_id = lookup(local.account_id, terraform.workspace)
  redshift_account_id  = "970646469978"
  bucket_name          = "ten-de-redshift-archive-${terraform.workspace}"
  redshift_cluster     = "tp-usw2-qa-redshift"
  redshift_role_name   = "de-redshift-archive-put-${terraform.workspace}"
}
