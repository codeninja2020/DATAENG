
module "ten_copilot_frontend_s3_bucket" {
  source                 = "../modules/s3-bucket"
  s3_bucket_name         = local.workspace.s3_bucket_name
  enable_versioning      = false
  enable_mfa_delete      = false
  enable_website_hosting = false
  block_public_access = {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }
  intelligent_tiering = true
}

