output "kms_key_id" {
    value = aws_kms_key.generic_cmk.key_id
}