data "aws_iam_policy" "aws_backup_backup_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "aws_backup_restore_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role" "aws_backup_default_service_role" {
  name               = "AWSBackupDefaultServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "backup.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_backup_attach_backup_policy" {
  role       = aws_iam_role.aws_backup_default_service_role.name
  policy_arn = data.aws_iam_policy.aws_backup_backup_policy.arn
}


resource "aws_iam_role_policy_attachment" "aws_backup_attach_restore_policy" {
  role       = aws_iam_role.aws_backup_default_service_role.name
  policy_arn = data.aws_iam_policy.aws_backup_restore_policy.arn
}
