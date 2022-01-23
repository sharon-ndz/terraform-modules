variable "common_tags" {
  type = map(string)
}

variable "backup_vault_name" { type = string }
variable "backup_plan_name" { type = string }
variable "backup_schedule" { type = string }
variable "backup_plan_start_window" { type = string }
variable "backup_plan_completion_window" { type = string }
variable "retention_period" { type = string }
variable "aws_backup_role_arn" { type = string }
variable "aws_backup_selection_name" { type = string }
variable "resourses_selection_tag_key" { type = string }
variable "resourses_selection_tag_value" { type = string }
variable "kms_key_arn" {
  description = "The ARN for the KMS encryption key."
  type        = string
  default     = null
}