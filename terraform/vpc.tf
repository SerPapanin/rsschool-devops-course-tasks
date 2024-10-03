# Create the VPC
resource "aws_vpc" "rsschool-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rsschool-vpc"
  }
}
