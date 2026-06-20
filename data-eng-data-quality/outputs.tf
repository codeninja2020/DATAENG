output "data_quality_ruleset_name" {
  description = "Name of the Glue Data Quality ruleset for TENMAID_UAT Members."
  value       = aws_glue_data_quality_ruleset.tenmaid_uat_members.name
}

output "data_quality_alarm_name" {
  description = "CloudWatch alarm name for null Reference1 values in the TENMAID_UAT Members ruleset."
  value       = aws_cloudwatch_metric_alarm.tenmaid_uat_members_null_values.alarm_name
}
