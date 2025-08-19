terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Creates a unique name prefix for all resources
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}