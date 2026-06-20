variable "aws_region" {
  description = "AWS region where the HSBC Glue datafeed job is deployed."
  type        = string
  default     = "eu-west-1"
}

variable "cicd_role" {
  description = "The name of the CICD role to assume."
  type        = string
  default     = "cicd-tf-apply"
}

variable "glue_job_name" {
  description = "Name of the HSBC datafeed Glue job."
  type        = string
  default     = "hsbc-datafeed-mssql-etl"
}

variable "glue_job_description" {
  description = "Description for the HSBC datafeed Glue job."
  type        = string
  default     = "AWS Glue ETL for HSBC member datafeed into Microsoft SQL Server"
}

variable "role_name" {
  description = "Name of the IAM role assumed by AWS Glue."
  type        = string
  default     = "hsbc-datafeed-glue-role"
}

variable "glue_version" {
  description = "AWS Glue runtime version for the ETL job."
  type        = string
  default     = "4.0"
}

variable "worker_type" {
  description = "AWS Glue worker type for the ETL job."
  type        = string
  default     = "G.16X"
}

variable "number_of_workers" {
  description = "Number of AWS Glue workers allocated to the ETL job."
  type        = number
  default     = 7
}

variable "timeout_minutes" {
  description = "Glue job timeout in minutes."
  type        = number
  default     = 60
}

variable "max_retries" {
  description = "Maximum number of Glue job retry attempts."
  type        = number
  default     = 0
}

variable "incoming_prefix" {
  description = "S3 prefix where incoming HSBC feed files are read."
  type        = string
  default     = "HSBC/incoming/"
}

variable "error_prefix" {
  description = "S3 prefix where invalid feed rows are written."
  type        = string
  default     = "HSBC/errors/"
}

variable "archive_prefix" {
  description = "S3 prefix where processed feed files are archived."
  type        = string
  default     = "HSBC/archive/"
}

variable "checkpoint_prefix" {
  description = "S3 prefix where deterministic ETL chunk checkpoints are stored."
  type        = string
  default     = "HSBC/checkpoints/"
}

variable "glue_script_s3_path" {
  type        = string
  description = "S3 URI for scripts/glue_mssql_etl.py. Defaults to s3://<workspace-bucket>/HSBC/scripts/glue_mssql_etl.py."
  default     = null
  nullable    = true
}

variable "glue_script_s3_arn" {
  type        = string
  description = "S3 object ARN for the Glue script. Defaults to the ARN derived from the workspace bucket."
  default     = null
  nullable    = true
}

variable "jdbc_url" {
  type        = string
  sensitive   = true
  description = "Optional SQL Server JDBC URL override. Defaults to the workspace-specific URL."
  default     = null
  nullable    = true
}

variable "target_table" {
  description = "SQL Server target table merged into by the Glue job."
  type        = string
  default     = "dbo.Members"
}

variable "glue_catalog_database_name" {
  description = "Glue Data Catalog database name for TENMAID_UAT crawler tables."
  type        = string
  default     = "tenmaid_uat"
}

variable "glue_crawler_name" {
  description = "Name of the Glue crawler that catalogs TENMAID_UAT."
  type        = string
  default     = "hsbc-datafeed-tenmaid-uat-crawler"
}

variable "glue_crawler_jdbc_path" {
  description = "JDBC include path crawled from TENMAID_UAT."
  type        = string
  default     = "TENMAID_UAT/dbo/%"
}

variable "glue_crawler_table_prefix" {
  description = "Prefix applied to tables created by the TENMAID_UAT Glue crawler."
  type        = string
  default     = "tenmaid_uat_"
}

variable "input_delimiter" {
  description = "Delimiter used by the incoming HSBC CSV feed."
  type        = string
  default     = ","
}

variable "glue_default_arguments" {
  description = "Additional default arguments to pass to the Glue job."
  type        = map(string)
  default     = {}
}
