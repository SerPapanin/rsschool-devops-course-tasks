terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      ManagedBy   = "Terraform"
    }
  }
}
