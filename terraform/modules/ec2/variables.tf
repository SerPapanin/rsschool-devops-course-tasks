variable "public_ssh_key" {
  description = "Key pair name for SSH access to the Bastion Host"
}
# List of the public subnet IDs
variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

# List of the private subnet IDs
variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "bastion_ssm_profile_name" {
  description = "The name of the IAM instance profile for the Bastion Host"
}
variable "private_ssm_profile_name" {
  description = "The name of the IAM instance profile for the private hosts"
}

variable "bastion_host_sg_id" {
  description = "The ID of the security group for the Bastion Host"
}

variable "private_hosts_sg_id" {
  description = "The ID of the security group for the private hosts"
}
# Used for adding default route for private hosts through bastion host
variable "private_route_table_id" {
  description = "ID of the private route table"
  type        = string
}
# Get the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
