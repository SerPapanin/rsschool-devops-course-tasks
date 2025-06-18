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
