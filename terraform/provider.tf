terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }

  backend "s3" {
    bucket         	   = "panin-rs-school-tf-state"
    key              	 = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
  }
}
