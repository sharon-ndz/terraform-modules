
locals {
  tags = merge(var.tags, tomap({ "Env" = format("%s", var.env) }))
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = var.region
}
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name                = "route53_backup_rule"
  description         = "Rule to trigger lambda to backup route53 backup"
  schedule_expression = var.cronExpression
}


resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  target_id = "rbt_target"
  arn       = aws_lambda_function.route53_backup_lambda.arn
}


data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/.terraform/archive_files/route53_backup_lambda.zip"
}

resource "aws_lambda_function" "route53_backup_lambda" {
  description   = "Copy the most recent snapshot to the DR region"
  filename      = data.archive_file.lambda_code.output_path
  function_name = "route53_backup_lambda"
  role          = aws_iam_role.route53_backup_role.arn
  handler       = "route53_backup_lambda.handler"
  runtime       = "python3.6"
  timeout       = 900
  memory_size   = 128
  tags          = merge(local.tags)

  environment {
    variables = {
      s3_backup_bucket_name = var.s3_backup_bucket_name
    }
  }
}


resource "aws_s3_bucket" "route53_backup_bucket" {
  bucket = var.s3_backup_bucket_name
  acl    = "private"
  tags   = merge(local.tags, tomap({ "Name" = format("%s", var.s3_backup_bucket_name) }))

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

}

resource "aws_s3_bucket_public_access_block" "s3_backup_bucket_public_block" {
  bucket = aws_s3_bucket.route53_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



