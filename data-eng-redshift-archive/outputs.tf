output "s3_bucket_arn" {
  description = "The ARN of the Redshift archive S3 bucket"
  value       = module.redshift_archive_s3_bucket.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "The name of the Redshift archive S3 bucket"
  value       = module.redshift_archive_s3_bucket.s3_bucket_id
}

output "redshift_archive_put_role_arn" {
  description = "The ARN of the Redshift role permitted to put objects in the archive bucket"
  value       = aws_iam_role.redshift_archive_put.arn
}
