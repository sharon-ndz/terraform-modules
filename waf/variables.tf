variable "environment" {
  type        = string
  description = "Environment name"
}

variable "waf_rate_limit" {
  type        = number
  description = "Rate limit per 5 minutes per IP"
}

variable "api_gateway_stage_arn" {
  type        = string
  description = "ARN of the API Gateway stage to attach WAF to"
}
