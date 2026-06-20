variable "aws_region" {
  description = "AWS region for the S3 bucket lookup."
  type        = string
  default     = "eu-west-1"
}

variable "cicd_role" {
  description = "The name of the CICD role to assume."
  type        = string
  default     = "cicd-tf-apply"
}
