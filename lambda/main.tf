data "aws_iam_role" "iam_role_check" {
  name = "${var.project}_lambda_role"
}

resource "aws_iam_role" "lambda_role" {
  count              = "${data.aws_iam_role.iam_role_check != "null" ? 0 : 1}"
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
  role             = aws_iam_role.lambda_role[0].arn
  handler          = var.lambda_handler
  runtime          = var.runtime
  memory_size      = var.memsize
  publish          = var.publish

  environment {
    variables = var.lambda_vars
  }

  tags = var.tags
}
