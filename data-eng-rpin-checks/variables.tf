variable "aws_region" {
  description = "AWS region where the RPIN data quality Lambda is deployed."
  type        = string
  default     = "eu-west-1"
}

variable "cicd_role" {
  description = "The name of the CICD role to assume."
  type        = string
  default     = "cicd-tf-apply"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function that runs the RPIN data quality check."
  type        = string
  default     = "data-eng-rpin-checks"
}

variable "lambda_role_name" {
  description = "Name of the IAM role assumed by the RPIN data quality Lambda."
  type        = string
  default     = "data-eng-rpin-checks-lambda-role"
}

variable "db_secret_name" {
  description = "Name of the existing database credentials secret in Secrets Manager."
  type        = string
  default     = "hsbc-datafeed-mssql-etl-jdbc-credentials"
}

variable "db_connection_url" {
  description = "Optional SQL Server connection URL override. Defaults to the QA TENMAID_UAT URL."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "lambda_layer_arns" {
  description = "Additional Lambda layer ARNs that provide runtime dependencies."
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "EventBridge schedule expression for the RPIN data quality Lambda."
  type        = string
  default     = "cron(0 10 * * ? *)"
}

variable "schedule_timezone" {
  description = "Timezone used by EventBridge Scheduler for the RPIN data quality Lambda schedule."
  type        = string
  default     = "Europe/Dublin"
}

variable "check_name" {
  description = "Logical name published with RPIN data quality metrics."
  type        = string
  default     = "rpin-reference1-required"
}

variable "error_prefix" {
  description = "S3 prefix where RPIN data quality error files are written."
  type        = string
  default     = "rpin-data-quality/errors/"
}

variable "rules_prefix" {
  description = "S3 prefix where RPIN data quality rule files and SQL checks are uploaded."
  type        = string
  default     = "rpin-data-quality/rules/"
}

variable "metric_namespace" {
  description = "CloudWatch namespace for RPIN data quality metrics."
  type        = string
  default     = "DataEngineering/DataQuality"
}

variable "finding_metric_name" {
  description = "CloudWatch metric name for RPIN data quality finding counts."
  type        = string
  default     = "RpinCheckFindings"
}
