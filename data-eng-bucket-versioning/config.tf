terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-bucket-versioning/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true

    assume_role = {
      role_arn     = "arn:aws:iam::133824686826:role/terraform-state-rw"
      session_name = "terraform-state"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${lookup(local.account_id, terraform.workspace, terraform.workspace)}:role/${var.cicd_role}"
    session_name = "data-eng-bucket-versioning"
  }

  default_tags {
    tags = {
      Environment = terraform.workspace
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
      Service     = "data-eng-bucket-versioning"
      Team        = "data-eng"
    }
  }
}
