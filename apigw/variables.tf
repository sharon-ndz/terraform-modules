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

variable "apigw_name" {
  type = string
}

variable "apigw_path" {
  type = string
}

variable "apigw_authorization" {
  type = string
}

variable "apigw_http_method" {
  type = string
}

variable "apigw_key" {
}

variable "apigw_status_code" {
  type = string
}

variable "response_models" {
  type = map(string)
}

variable "response_parameters" {
  type = map(string)
}

variable "apigw_integration_type" {
  type = string
}

variable "apigw_request_templates" {
  type = map(string)
}

variable "apigw_response_templates" {
  type = map(string)
}

variable "apigw_stage_name" {
  type    = string
  default = "default"
}
