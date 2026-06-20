locals {
  # This component is deployed only to staging and prod workspaces.
  supported_workspaces = ["staging", "prod"]

  # AWS account IDs keyed by Terraform workspace.
  account_id = {
    staging = "759286849978"
    prod    = "171408413795"
  }

  # Existing BI buckets used by the Ivector SFTP landing area.
  ivector_bucket_names = {
    staging = "bi-staging.tenproduct.com"
    prod    = "bi-prod.tenproduct.com"
  }

  mercury_hub_bucket_names = {
    staging = "bi-staging.tenproduct.com"
    prod    = "bi-prod.tenproduct.com"
  }

  # Resolve workspace-specific bucket settings and reusable S3 ARNs.
  workspace_account_id              = lookup(local.account_id, terraform.workspace, "000000000000")
  workspace_supported               = contains(local.supported_workspaces, terraform.workspace)
  ivector_bucket_name               = lookup(local.ivector_bucket_names, terraform.workspace, "unsupported-workspace")
  ivector_bucket_arn                = "arn:aws:s3:::${local.ivector_bucket_name}"
  mercury_hub_bucket_name           = lookup(local.mercury_hub_bucket_names, terraform.workspace, "unsupported-workspace")
  mercury_hub_bucket_arn            = "arn:aws:s3:::${local.mercury_hub_bucket_name}"
  ivector_home_directory_prefix     = "ivector"
  mercury_hub_home_directory_prefix = "mercuryhub"

  # The rename Lambda watches the incoming subdirectory of each SFTP landing prefix.
  file_rename_roots = [
    "CA_BOA_Reports/incoming",
    "CMS/incoming",
    "BE_DJANGO_POSTGRES_CSV/incoming",
    "PREFERENCE_CSV/incoming",
    "${local.ivector_home_directory_prefix}/incoming",
    "${local.mercury_hub_home_directory_prefix}/incoming",
  ]

  # Workspace-scoped resource names keep staging and prod infrastructure separate.
  transfer_server_name             = "ivector-${terraform.workspace}"
  ivector_transfer_role_name       = "aws-transfer-ivector-${terraform.workspace}"
  mercury_hub_transfer_role_name   = "aws-transfer-mercury-hub-${terraform.workspace}"
  petru_transfer_role_name         = "aws-transfer-petru-${terraform.workspace}"
  ivector_transfer_policy_name     = "aws-transfer-ivector-s3-${terraform.workspace}"
  mercury_hub_transfer_policy_name = "aws-transfer-mercury-hub-s3-${terraform.workspace}"
  petru_transfer_policy_name       = "aws-transfer-petru-s3-${terraform.workspace}"
  file_rename_function_name        = "data-eng-file-rename-${terraform.workspace}"
  file_rename_role_name            = "data-eng-file-rename-lambda-${terraform.workspace}"
  file_rename_policy_name          = "data-eng-file-rename-s3-${terraform.workspace}"

  # Object ARNs granted to the rename Lambda for in-place renames under root/incoming/*.
  file_rename_object_arns = flatten([
    for root in local.file_rename_roots : [
      "${local.ivector_bucket_arn}/${root}/*",
    ]
  ])

  transfer_auth_lambda_name   = "aws-transfer-identity-${terraform.workspace}"
  transfer_user_secret_prefix = "aws-transfer/${local.transfer_server_name}"
  transfer_users = {
    (var.ivector_user_name) = {
      password            = var.ivector_user_password
      public_keys         = [var.ivector_user_ssh_public_key]
      role_arn            = aws_iam_role.ivector_transfer_access.arn
      home_directory      = "/${local.ivector_bucket_name}/${local.ivector_home_directory_prefix}"
      home_directory_type = "PATH"
    }
    (var.mercury_hub_user_name) = {
      password            = var.mercury_hub_user_password
      public_keys         = [var.mercury_hub_user_ssh_public_key]
      role_arn            = aws_iam_role.mercury_hub_transfer_access.arn
      home_directory      = "/${local.mercury_hub_bucket_name}/${local.mercury_hub_home_directory_prefix}"
      home_directory_type = "PATH"
    }
    (var.petru_user_name) = {
      password            = var.petru_user_password != null ? var.petru_user_password : random_password.petru_user_password.result
      public_keys         = [var.petru_user_ssh_public_key]
      role_arn            = aws_iam_role.petru_transfer_access.arn
      home_directory_type = "LOGICAL"
      home_directory_details = jsonencode([
        {
          Entry  = "/ivector"
          Target = "/${local.ivector_bucket_name}/${local.ivector_home_directory_prefix}"
        },
        {
          Entry  = "/mercuryhub"
          Target = "/${local.mercury_hub_bucket_name}/${local.mercury_hub_home_directory_prefix}"
        }
      ])
    }
  }
}
