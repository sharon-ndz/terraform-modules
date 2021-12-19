##############Generic variables############
variable "environment" {
  type = string
}
variable "common_tags" {
  type = map
}
variable "extra_tags" {
  type = map
}
#############KMS Variables##############
variable "aws_service" {
  type = string
}
variable "description" {
  type = string
}
variable "is_enabled" {
  type = string
}
variable "key_spec" {
  type = string
}
variable "rotation_enabled" {
  type = string
}
