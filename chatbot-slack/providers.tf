terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "3.61.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.account

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Env       = var.env
      Project   = var.project
    }
  }
}
