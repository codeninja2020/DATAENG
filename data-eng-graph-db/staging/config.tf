terraform {
  backend "s3" {
    bucket  = "tengroup-terraform-state"
    key     = "data-eng-graph-db/staging/terraform.tfstate"
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
      version = "6.46.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }
}

locals {
  account_id = {
    staging = "759286849978"
  }

  aws_account_id = lookup(local.account_id, terraform.workspace, local.account_id[local.environment])
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.aws_account_id}:role/${var.cicd_role}"
    session_name = "data-eng-graph-db-staging"
  }

  default_tags {
    tags = {
      Name        = local.cluster_identifier
      Environment = "staging"
      Product     = "data-engineering"
      Project     = "graph-db"
      Service     = local.cluster_identifier
      Team        = "data-eng"
      OwnedBy     = "terraform"
      Repository  = "ten-infrastructure"
    }
  }
}
