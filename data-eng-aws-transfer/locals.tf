
locals {
  ivector_bucket_name = "ivector-${terraform.workspace}"
  ivector_bucket_arn  = "arn:aws:s3:::${local.ivector_bucket_name}"
}


