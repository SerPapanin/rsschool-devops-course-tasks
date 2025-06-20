# List of CIDR blocks that are allowed to SSH into the Bastion Host
# Default is empty list, which will block SSH access
variable "allowed_ssh_bastion_cidrs" {
  type = list(string)
}
variable "vpc_id" {
  description = "Current VPC ID"
  type        = string
}
