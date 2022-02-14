
resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_backup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
}


resource "aws_iam_role" "route53_backup_role" {
  name               = "route53_backup_role_${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "route53_backup_policy" {
  name   = "route53_backup_policy_${var.env}"
  role   = aws_iam_role.route53_backup_role.id
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:PutObject*",
            "s3:GetBucket*",
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:GetObject*"
         ],
         "Resource": [
           "arn:aws:s3:::${var.s3_backup_bucket_name}",
           "arn:aws:s3:::${var.s3_backup_bucket_name}/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "route53:GetHostedZone*",
            "route53:ListHostedZones*",
            "route53:ListResourceRecordSets"
         ],
         "Resource": "*"
      }
   ]
}
EOF
}
