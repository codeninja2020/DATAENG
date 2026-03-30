output "source_bucket_name" {
  description = "Bucket that emits the S3 ObjectCreated events"
  value       = local.source_bucket_name
}

output "source_bucket_arn" {
  description = "ARN of the source bucket"
  value       = local.source_bucket_arn
}

output "target_bucket_name" {
  description = "Bucket checked for matching objects to delete"
  value       = local.target_bucket_name
}

output "target_bucket_arn" {
  description = "ARN of the target bucket"
  value       = local.target_bucket_arn
}

output "lambda_function_name" {
  description = "Cleanup Lambda function name"
  value       = aws_lambda_function.s3_archive.function_name
}

output "lambda_function_arn" {
  description = "Cleanup Lambda function ARN"
  value       = aws_lambda_function.s3_archive.arn
}
