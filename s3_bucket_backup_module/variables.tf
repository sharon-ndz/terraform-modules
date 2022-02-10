variable "region" {}
variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(string)
}
variable "s3_dest_bucket_name" {}
variable "s3_source_bucket_name" {}
variable "env" {}
variable "days_to_retain_backup" {}
variable "cronExpression" {}
