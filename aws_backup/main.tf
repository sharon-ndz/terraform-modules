resource "aws_backup_vault" "this" {
  name        = var.backup_vault_name
  kms_key_arn = var.kms_key_arn
  tags        = merge({ Name = var.backup_vault_name }, var.common_tags)
}

resource "aws_backup_plan" "this" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_plan_name
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.backup_schedule
    start_window      = var.backup_plan_start_window
    completion_window = var.backup_plan_completion_window

    lifecycle {
      delete_after = var.retention_period
    }
  }
}

resource "aws_backup_selection" "this" {
  iam_role_arn = aws_iam_role.aws_backup_default_service_role.arn
  name         = var.aws_backup_selection_name
  plan_id      = aws_backup_plan.this.id

  resources = ["*"]
  condition {
    string_equals {
      key   = "aws:ResourceTag/${var.resourses_selection_tag_key}"
      value = var.resourses_selection_tag_value
    }
  }
}
