output "aws_backup_vault_arn" {
  value = aws_backup_vault.this.arn
}

output "aws_backup_vault_name" {
  value = aws_backup_vault.this.id
}