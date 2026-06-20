output "glue_job_name" {
  value       = aws_glue_job.hsbc_datafeed.name
  description = "AWS Glue job name."
}

output "glue_role_arn" {
  value       = aws_iam_role.hsbc_glue.arn
  description = "IAM role ARN used by the Glue job."
}

output "source_s3_path" {
  value       = "s3://${local.datafeed_bucket_name}/${var.incoming_prefix}"
  description = "S3 prefix read by the Glue job."
}

output "error_s3_path" {
  value       = "s3://${local.datafeed_bucket_name}/${var.error_prefix}"
  description = "S3 prefix where rejected records are written."
}

output "archive_s3_path" {
  value       = "s3://${local.datafeed_bucket_name}/${var.archive_prefix}"
  description = "S3 prefix where processed input files are archived."
}

output "glue_alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.glue_job_errors.alarm_name,
    aws_cloudwatch_metric_alarm.glue_failed_tasks.alarm_name,
  ]
  description = "CloudWatch alarm names that notify the Data Engineering Slack channel."
}

output "glue_catalog_database_name" {
  value       = aws_glue_catalog_database.tenmaid_uat.name
  description = "Glue Data Catalog database name for TENMAID_UAT metadata."
}

output "glue_crawler_name" {
  value       = try(aws_glue_crawler.tenmaid_uat[0].name, null)
  description = "Glue crawler name for TENMAID_UAT metadata."
}
