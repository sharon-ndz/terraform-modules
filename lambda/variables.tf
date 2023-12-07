variable "account" {
  description = "Current AWS profile"
}

variable "env" {
  type = string
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "project" {
}

variable "create_role" {
  description = "Controls whether IAM role for Lambda Function should be created"
  type        = bool
  default     = true
}

variable "lambda_name" {
  type = string
}

variable "lambda_role" {
  description = " IAM role ARN attached to the Lambda Function. This governs both who / what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. See Lambda Permission Model for more details."
  type        = string
  default     = ""
}

variable "lambda_handler" {
  type = string
}

variable "filename" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "runtime" {
  type = string
}

variable "memsize" {
  type = string
}

variable "publish" {
}

variable "lambda_vars" {
  type = map(string)
}

variable "tags" {
  default = {}
  type    = map(string)
}
