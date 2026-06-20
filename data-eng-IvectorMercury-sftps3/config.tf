terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-IvectorMercury-sftps3/terraform.tfstate"
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
      version = "~> 6.40.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.workspace_account_id}:role/${var.cicd_role}"
    session_name = "data-eng-IvectorMercury-sftps3"
  }

  default_tags {
    tags = {
      Team         = "data-eng"
      Environment  = terraform.workspace
      Service      = "aws-transfer"
      OwnedBy      = "terraform"
      Repository   = "ten-infrastructure"
      map-migrated = "migJ3QR7GKPRW"
    }
  }
}