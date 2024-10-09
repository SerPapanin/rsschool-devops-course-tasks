variable "aws_region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tf_env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "rs-school-devops"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "panin"
}

variable "github_action_iam_policies_list" {
  description = "Github Action policies"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  ]
}

# VPC variables
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Public SSH key
variable "panin_key" {
  description = "Key pair name for SSH access to the Bastion Host"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWDf4OY1ZOWHMcgEvmbRJyFSzq92ZKp5HGHuX9AUsCU sergey_panin@lineate.com"
}

# List of CIDR blocks that are allowed to SSH into the Bastion Host
# Default is empty list, which will block SSH access
variable "allowed_ssh_bastion_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the Bastion Host"
  type        = list(string)
  default     = []
}
