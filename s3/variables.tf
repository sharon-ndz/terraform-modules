##############Generic variables############
variable "common_tags" {
  type = map
}

#########S3 bucket variables###############
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
  default = "false"
}

variable "life_cycle_storage_class" {
  type = string
  default = "STANDARD_IA"
}

variable "transition_in_days" {
  type = string
  default = "30"
}

variable "expiration_in_days" {
  type = string
  default = "0"
}

variable "create_bucket_policy" {
  type = bool
}

variable "bucket_name" {
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

    condition = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))

   }))
  default = []
}
###############################