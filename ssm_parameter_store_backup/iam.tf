
resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.param_store_backup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
}


resource "aws_iam_role" "param_store_backup_role" {
  name               = "param_store_backup_role_${var.env}"
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

resource "aws_iam_role_policy" "param_store_backup_policy" {
  name   = "param_store_backup_policy_${var.env}"
  role   = aws_iam_role.param_store_backup_role.id
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
            ],
            "Resource": "*"
        },
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
            "s3:PutObject*"
         ],
         "Resource": [
           "arn:aws:s3:::${var.s3_bucket_name}",
           "arn:aws:s3:::${var.s3_bucket_name}/*"
         ]
      }
   ]
}
EOF
}
