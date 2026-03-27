terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-datafeeds/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true


    assume_role = {
      role_arn     = "arn:aws:iam::133824686826:role/terraform-state-rw" // todo: build new role 
      session_name = "terraform-state"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  account_id = {
    qa      = "236130610212"
    staging = "759286849978"
    prod    = "171408413795"
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${lookup(local.account_id, terraform.workspace)}:role/cicd-tf-apply"
    session_name = "terraform-eks"
  }

  default_tags {
    tags = {
      Team        = "data-eng"
      Environment = terraform.workspace
      Product     = "datafeeds"
      Service     = "datafeeds"
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
      CostCentre  = "Tech Dev"
    }
  }
}
