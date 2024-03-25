variable "prefix" {
  description = "Prefix for resources"
  type       = string
  default = "gen3-admin"
}

variable "ssh_allowed_ips" {
  description = "List of IP addresses allowed to connect to the EC2 instance over SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aws_cli_profile" {
  description = "AWS CLI profile to use"
  type        = string
  # default     = "default"
}

variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.120.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.120.10.0/24"
}