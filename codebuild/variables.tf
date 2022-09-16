variable "account" {
  description = "Current AWS profile"
}

variable "env" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "artifact_bucket_arn" {
  default = "arn:aws:s3:::*"
  type    = string
}

variable "environment_type" {
  type        = string
  description = "Build environment type."
}

variable "env_variables" {
  type = list(object(
    {
      name  = string
      value = string
      type  = string
    }
  ))

  default = [
    {
      name  = "NO_BUILD_VARS"
      value = "TRUE"
      type  = "PLAINTEXT"
    }
  ]

  description = "Valid types are 'PLAINTEXT', 'PARAMETER_STORE', or 'SECRETS_MANAGER'"
}

variable "compute_type" {
  type        = string
  description = "Build container type."
}

variable "image" {
  type        = string
  description = "Type of an image to build project."
}

variable "privileged_mode" {
  default = true
  type    = bool
}

variable "cb_art_type" {
  type = string
}

variable "source_type" {
  type        = string
  description = "Build source repository."
}

variable "source_location" {
  type        = string
  description = "Repository URI"
}

variable "git_clone_depth" {
  default = 1
  type    = string
}

variable "source_branch" {
  default     = ""
  type        = string
  description = "Source version/branch"
}

variable "buildspec" {
  default     = ""
  type        = string
  description = "The buildspec declaration to use for this build project's related builds."
}

variable "cache_type" {
  type        = string
  description = "The type of storage for the project's cache."
}

variable "cache_location" {
  type = string
}

variable "build_timeout" {
  default     = 60
  type        = string
  description = "Build timeout."
}

variable "fetch_submodules" {
  default = false
  type    = bool
}

variable "log_config_gname" {
  type        = string
  description = "Build logging parameters."
}

variable "log_config_sname" {
  type        = string
  description = "Build logging parameters."
}

variable "s3_logs_status" {
  default     = "ENABLED"
  type        = string
  description = "S3 logs switching on/off"
}

variable "block_public_acls" {
  default = true
  type    = bool
}

variable "block_public_policy" {
  default = true
  type    = bool
}

variable "ignore_public_acls" {
  default = true
  type    = bool
}

variable "restrict_public_buckets" {
  default = true
  type    = bool
}

variable "iam_path" {
  type        = string
  description = "Path in which to create the IAM Role and the IAM Policy."
}

variable "description" {
  default = "Managed by Terraform"
  type    = string
}

variable "tags" {
  default = {}
  type    = map(string)
}
