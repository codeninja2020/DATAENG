terraform {
  # Component state is isolated from other data quality jobs.
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-rpin-checks/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true

    assume_role = {
      role_arn     = "arn:aws:iam::133824686826:role/terraform-state-rw"
      session_name = "terraform-state"
    }
  }

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = var.aws_region

  # Keep the same plan/apply role pattern used across this repository.
  assume_role {
    role_arn     = "arn:aws:iam::${local.workspace_account_id}:role/${var.cicd_role}"
    session_name = "data-eng-rpin-checks"
  }

  default_tags {
    # Default tags are applied to all taggable resources in this component.
    tags = {
      Environment = terraform.workspace
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
      Service     = "data-eng-rpin-checks"
      Team        = "data-eng"
    }
  }
}
