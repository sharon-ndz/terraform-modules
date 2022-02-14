variable "region" {}
variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(string)
}
variable "s3_backup_bucket_name" {}
variable "env" {}
variable "cronExpression" {}
