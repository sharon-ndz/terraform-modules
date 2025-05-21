variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment to launch in. One of: dev, stage, prod"
  default     = ""
}

variable "application" {
  description = "The application that this is terraforming"
  default     = ""
}

variable "project" {
  description = "The project that this is terraforming"
  default     = ""
}

variable "policy" {
  description = <<DESCRIPTION
The role policy to apply.

Example: colossus_role
DESCRIPTION


  default = ""
}

variable "policyname" {
  description = "user policy name"
  default     = ""
}

variable "iamuser" {
  description = "The iam user name to use"
  default     = ""
}

variable "usergroups" {
  description = "The iam user groups"
  default     = []
}

variable "user_attach_policy" {
  description = "user attached policy"
  default     = ""
}

