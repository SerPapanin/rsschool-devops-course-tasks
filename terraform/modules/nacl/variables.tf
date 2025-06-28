variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "blocked_cidrs" {
  type        = list(string)
  description = "List of CIDRs to block access"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}
