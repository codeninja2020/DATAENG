variable "aws_region" {
  description = "AWS region where the Glue Data Quality ruleset is deployed."
  type        = string
  default     = "eu-west-1"
}

variable "cicd_role" {
  description = "The name of the CICD role to assume."
  type        = string
  default     = "cicd-tf-apply"
}

variable "ruleset_name" {
  description = "Name of the Glue Data Quality ruleset."
  type        = string
  default     = "RPIN Dataquality check"
}

variable "data_quality_evaluation_context" {
  description = "Glue Data Quality evaluation context used when publishing CloudWatch metrics."
  type        = string
  default     = "rpin-dataquality-check"
}

variable "data_quality_failed_metric_name" {
  description = "CloudWatch metric name published by Glue Data Quality when a rule fails."
  type        = string
  default     = "glue.dataquality.rules.failed"
}

variable "data_quality_metric_namespace" {
  description = "CloudWatch namespace used by Glue Data Quality metrics."
  type        = string
  default     = "Glue"
}

variable "glue_catalog_table_name" {
  description = "Glue Data Catalog table created by the TENMAID_UAT crawler for dbo.Members."
  type        = string
  default     = "tenmaid_uat_tenmaid_uat_dbo_members"
}

variable "glue_job_name" {
  description = "Name of the Glue Python Shell job that runs data quality checks."
  type        = string
  default     = "data-eng-data-quality-tenmaid-uat"
}

variable "glue_job_role_name" {
  description = "Name of the IAM role assumed by the data quality Glue job."
  type        = string
  default     = "data-eng-data-quality-glue-role"
}

variable "glue_jdbc_connection_name" {
  description = "Name of the existing HSBC datafeed JDBC Glue connection for TENMAID_UAT."
  type        = string
  default     = "hsbc-datafeed-mssql-etl-tenmaid-uat-jdbc"
}

variable "glue_network_connection_name" {
  description = "Name of the existing HSBC datafeed network Glue connection for RDS VPC access."
  type        = string
  default     = "hsbc-datafeed-mssql-etl-rds-vpc"
}

variable "jdbc_secret_name" {
  description = "Name of the existing HSBC datafeed JDBC credentials secret in Secrets Manager."
  type        = string
  default     = "hsbc-datafeed-mssql-etl-jdbc-credentials"
}
