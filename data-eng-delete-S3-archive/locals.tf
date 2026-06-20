locals {
  account_id = {
    staging = "759286849978"
    prod    = "171408413795"
  }

  workspace = {
    s3_bucket_name = var.bucket_names[terraform.workspace]
  }

  archive_roots = [
    "BE_DJANGO_POSTGRES_CSV",
    "CA_BOA_Reports",
    "CMS",
    "PREFERENCE_CSV",
    "ivector",
    "mercuryhub",
  ]

  archive_folder_name = "sql-archive"
  target_folder_name  = "incoming"

  archive_source_object_arns = [
    for archive_root in local.archive_roots : "${local.source_bucket_arn}/${archive_root}/${local.archive_folder_name}/*"
  ]

  archive_target_object_arns = [
    for archive_root in local.archive_roots : "${local.target_bucket_arn}/${archive_root}/${local.target_folder_name}/*"
  ]

  # source (event) ,  target (deletion) paths
  source_bucket_name = local.workspace.s3_bucket_name
  target_bucket_name = local.workspace.s3_bucket_name
  source_bucket_arn  = "arn:aws:s3:::${local.source_bucket_name}"
  target_bucket_arn  = "arn:aws:s3:::${local.target_bucket_name}"
}
