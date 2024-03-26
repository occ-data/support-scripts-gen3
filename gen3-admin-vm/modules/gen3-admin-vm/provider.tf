terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "aws" {
    region = var.aws_region
    profile = var.aws_cli_profile
}