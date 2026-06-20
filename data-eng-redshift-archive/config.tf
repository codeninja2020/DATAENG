terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-redshift-archive/terraform.tfstate"
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
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.workspace_account_id}:role/${var.cicd_role}"
    session_name = "data-eng-redshift-archive"
  }

  default_tags {
    tags = {
      Team        = "data-eng"
      Environment = terraform.workspace
      Service     = "de-redshift-archive"
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
    }
  }
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::${local.redshift_account_id}:role/${var.cicd_role}"
    session_name = "data-eng-redshift-archive-usw2"
  }

  default_tags {
    tags = {
      Team        = "data-eng"
      Environment = terraform.workspace
      Service     = "de-redshift-archive"
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
    }
  }
}
