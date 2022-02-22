variable "region" {}
variable "s3_backup_bucket_name" {}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "env" {
  type        = string
  description = "Application Environment"
}


variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(string)
}

variable "schedule_expression" {}
