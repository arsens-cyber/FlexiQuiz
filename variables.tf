variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., staging, prod)."
  type        = string
}

variable "domain_name" {
  description = "The root domain name for the application (must be managed in Route 53)."
  type        = string
}

variable "dashboard_subdomain" {
  description = "The subdomain for the dashboard."
  type        = string
}

variable "admin_email" {
  description = "Email address to receive monitoring alerts."
  type        = string
}