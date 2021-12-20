##############Generic variables############
variable "environment" {
  type = string
}
variable "common_tags" {
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
#############KMS IAM Policies##############
variable "extra_policies" {
  type = list(object({
    sid         = string
    effect      = string
    actions     = list(string)
    resources   = list(string)
    principals  = object({
      identifiers = list(string)
      type        = string
    })
  }))
}