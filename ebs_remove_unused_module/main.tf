locals {
  module_relpath = path.module
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "ebs-unused" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "ec2:DeleteVolume",
      "ec2:DescribeVolumeAttribute",
      "logs:CreateLogStream",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "kms:Decrypt"
    ]

    resources = [
      "*",
    ]
  }
}

data "archive_file" "ebs-unused" {
  type        = "zip"
  source_file = "${local.module_relpath}/ebs-unused.py"
  output_path = "${local.module_relpath}/ebs-unused.zip"
}

resource "aws_iam_role" "ebs-unused" {
  name               = "${var.env}-role_ebs-unused"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy" "ebs-unused" {
  name   = "${var.env}-policy_ebs-unused"
  role   = aws_iam_role.ebs-unused.id
  policy = data.aws_iam_policy_document.ebs-unused.json
}

resource "aws_lambda_function" "ebs-unused" {
  filename         = data.archive_file.ebs-unused.output_path
  function_name    = "${var.env}-ebs-unused-lambda"
  description      = "create lambda for unused EBS"
  role             = aws_iam_role.ebs-unused.arn
  timeout          = 900
  handler          = "ebs-unused.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.ebs-unused.output_base64sha256

}

resource "null_resource" "schedule" {
  triggers = {
    backup = "${var.schedule_expression}"
  }
}

resource "aws_cloudwatch_event_rule" "ebs-unused" {
  name                = "${var.env}-ebs-unused-rule"
  description         = "Schedule to run lambda"
  schedule_expression = null_resource.schedule.triggers.backup
  depends_on          = [null_resource.schedule]
}

resource "aws_cloudwatch_event_target" "ebs-unused" {
  rule      = aws_cloudwatch_event_rule.ebs-unused.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.ebs-unused.arn
}

resource "aws_lambda_permission" "ebs-unused" {
  statement_id  = "ebs-unused_lambda_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ebs-unused.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ebs-unused.arn
}

