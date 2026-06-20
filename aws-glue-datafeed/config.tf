terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "ten-data-eng-hsbc-datafeed/terraform.tfstate"
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
      version = "6.40.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${local.workspace_account_id}:role/${var.cicd_role}"
    session_name = "ten-data-eng-hsbc-datafeed"
  }

  default_tags {
    tags = {
      Environment = terraform.workspace
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
      Service     = "hsbc-datafeed"
      Team        = "data-eng"
    }
  }
}
