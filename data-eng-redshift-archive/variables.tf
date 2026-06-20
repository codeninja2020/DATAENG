variable "cicd_role" {
  description = "The name of the CICD role to assume"
  type        = string
  default     = "cicd-tf-apply"
}
