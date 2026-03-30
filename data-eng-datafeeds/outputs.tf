output "bucket_name" {
  description = "S3 bucket name for the current workspace"
  value       = local.workspace.s3_bucket_name
}

output "bucket_arn" {
  description = "S3 bucket ARN for the current workspace"
  value       = "arn:aws:s3:::${local.workspace.s3_bucket_name}"
}
