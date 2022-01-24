variable "region" {}
variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(string)
}
variable "s3_bucket_name" {}
variable "env" {}
