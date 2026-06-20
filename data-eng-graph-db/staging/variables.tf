variable "image" {
  description = "Container image URI for the graph-db deployment (e.g. 759286849978.dkr.ecr.eu-west-1.amazonaws.com/graph-db:latest)"
  type        = string
}

variable "cicd_role" {
  description = "The name of the CICD role to assume"
  type        = string
  default     = "cicd-tf-apply"
}

variable "mssql_host" {
  description = "SQL Server hostname or IP for TENMAID_UAT"
  type        = string
}

variable "mssql_user" {
  description = "SQL Server login username"
  type        = string
}

variable "mssql_password" {
  description = "SQL Server login password"
  type        = string
  sensitive   = true
}
