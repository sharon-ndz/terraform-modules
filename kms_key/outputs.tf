output "kms_key_id" {
    value = aws_kms_key.generic_cmk.key_id
}

output "kms_key_arn" {
    value = aws_kms_key.generic_cmk.arn
}