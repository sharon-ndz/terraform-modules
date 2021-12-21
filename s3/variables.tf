##############Generic variables############
variable "environment" {
  type = string
}

variable "common_tags" {
  type = map
}

variable "aws_service" {
  type = string
}

#########S3 bucket variables###############
variable "resource_name" {
  type = string
}
variable "acl" {
  type = string
}

variable "force_destroy_option" {
  type = string
}

variable "enable_bucket_versioning" {
  type = string
}

variable "life_cycle_option" {
  type = string
}

variable "life_cycle_storage_class" {
  type = string
}

variable "transition_in_days" {
  type = string
}

variable "expiration_in_days" {
  type = string
}

variable "s3_kms_key_arn" {
  type = string
}

variable "create_bucket_policy" {
  type = bool
}

variable "buket_name" {
    type = string
    description = "The name of the bucket"
}

variable "bucket_policy" {
  type = list(object({
    sid = string

    principals = object({
      type        = string
      identifiers = list(string)
    })

    effect = string
    actions = list(string)
    resources = list(string)

    condition = object({
      test     = string
      variable = string
      values   = list(string)
    })

   }))
   default = []
}
###############################