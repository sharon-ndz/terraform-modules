output "username" {
  value = aws_iam_user.iam_user.name
}

#output "key" {
#  value = "${aws_iam_access_key.iam_user.id}"
#}
#output "encrypted_secret" {
#  value = "${aws_iam_access_key.iam_user.encrypted_secret}"
#}
#output "secret" {
#  value = "${aws_iam_access_key.iam_user.secret}"
#}
