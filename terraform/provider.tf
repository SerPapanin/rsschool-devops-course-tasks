terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
      #profile = "terraform_user"
    }
  }

provider "aws" {
  region = vars.aws_region
  default_tags {
    tags = {
      Environment = "Dev"
      Project     = "rsschool-devops"
      Owner       = "panin"
    }
}

  backend "s3" {}
}
