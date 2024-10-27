# AWS region for creating resources
#aws_region = ""
# AZs where subnets will be spread
#azs     = ["us-east-1a", "us-east-1b"]
# Allowed CIDRs to SSH access to bastion host
allowed_ssh_bastion_cidrs = ["95.104.117.178/32", "212.58.103.152/32"]
# Private subnets CIDRs
private_subnet_cidrs = ["10.0.6.0/24", "10.0.7.0/24"]
# Public subnets CIDRs
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
# Public SSH key pushed to instances
public_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWDf4OY1ZOWHMcgEvmbRJyFSzq92ZKp5HGHuX9AUsCU"
# Blocked CIDRs for NACL HTTP/HTTPS block
blocked_cidrs = ["86.57.248.100/32"]
