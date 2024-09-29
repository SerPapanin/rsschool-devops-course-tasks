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
