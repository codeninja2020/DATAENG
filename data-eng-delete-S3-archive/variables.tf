variable "bucket_names" {
  description = "S3 bucket names keyed by Terraform workspace."
  type        = map(string)
  default = {
    staging = "bi-staging.tenproduct.com"
    prod    = "bi-prod.tenproduct.com"
  }
}

variable "aws_region" {
  description = "AWS region for the Lambda and S3 lookup."
  type        = string
  default     = "eu-west-1"
}

variable "cicd_role" {
  description = "The name of the CICD role to assume."
  type        = string
  default     = "cicd-tf-apply"
}

