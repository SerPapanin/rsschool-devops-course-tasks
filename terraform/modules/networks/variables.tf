variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_id" {
  description = "Current VPC ID"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = [] #data.aws_availability_zones.current_azs.names
}
