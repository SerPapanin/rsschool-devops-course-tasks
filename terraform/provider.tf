#AWS terraform provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
      #profile = "terraform_user"
    }
  }

  backend "s3" {}
}
# Set default region and tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.tf_env
      Project     = var.project
      Owner       = var.owner
    }
  }
}
