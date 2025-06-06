data "aws_iam_role" "iam_role_check" {
  name = "${var.project}_lambda_role"
}

resource "aws_iam_role" "lambda_role" {
  count              = var.create_role && data.aws_iam_role.iam_role_check == "null" ? 1 : 0
  name               = "${var.project}_lambda_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_lambda_function" "default" {
  function_name    = var.lambda_name
  filename         = var.filename
  source_code_hash = var.source_code_hash
  role             = var.create_role ? aws_iam_role.lambda_role[*].arn : var.lambda_role
  handler          = var.lambda_handler
  runtime          = var.runtime
  memory_size      = var.memsize
  publish          = var.publish

  environment {
    variables = var.lambda_vars
  }

  tags = var.tags
}
