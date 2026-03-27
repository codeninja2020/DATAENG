
locals {
  env = {
    qa = {
      s3_bucket_name               = "data-eng-datafeeds-qa"
    }
    staging = {
      s3_bucket_name               = "data-eng-datafeeds-staging",
    }
    prod = {
      s3_bucket_name               = "data-eng-datafeeds-prod"
    }
  }
  workspace = local.env[terraform.workspace]
}

