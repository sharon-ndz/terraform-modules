variable "environment" {
  type        = string
  description = "Deployment environment (dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "api_gateway_name" {
  type        = string
  description = "Name for API Gateway"
}

variable "api_gateway_description" {
  type        = string
  description = "API Gateway description"
}

variable "vpc_link_name" {
  type        = string
  description = "Name of the VPC Link"
}

variable "vpc_link_arn" {
  type        = string
  description = "Target NLB ARN for VPC Link"
}

variable "api_log_group_prefix" {
  type        = string
  description = "Prefix for CloudWatch Log Group name (e.g., /aws/api-gateway/)"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "Retention days for logs"
}

variable "api_stage_name" {
  type        = string
  default     = "default"
  description = "API Gateway stage name"
}

variable "backend_port" {
  type        = number
  default     = 4000
  description = "Backend port to target"
}

variable "nlb_dns_name" {
  type        = string
  description = "DNS name of the NLB"
}
