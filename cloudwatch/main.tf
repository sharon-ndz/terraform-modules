data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "docker_api" {
  name              = var.docker_log_group_name
  retention_in_days = var.retention_in_days
  skip_destroy      = true

  tags = {
    Name = var.log_group_tag_name
  }

  lifecycle {
#    prevent_destroy = true
    ignore_changes = [
      name,
      retention_in_days,
      tags
    ]
  }
}

resource "aws_s3_bucket" "nlb_logs" {
  bucket        = var.access_logs_bucket
  force_destroy = true

  tags = {
    Name        = var.nlb_logs_bucket_tag_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.nlb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "nlb_logs_policy" {
  bucket = aws_s3_bucket.nlb_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowELBLogging",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.nlb_logs.arn}/${var.access_logs_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/*"
          }
        }
      }
    ]
  })
}

resource "aws_ssm_parameter" "docker_logs_config" {
  name      = var.ssm_param_name
  type      = "String"
  tier      = "Standard"
  overwrite = true

  value = jsonencode({
    agent = {
      metrics_collection_interval = var.metrics_collection_interval,
      logfile                     = var.cloudwatch_agent_logfile
    },
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = var.docker_log_file_path,
              log_group_name  = var.docker_log_group_name,
              log_stream_name = var.log_stream_name,
              timezone        = var.timezone
            }
          ]
        }
      }
    }
  })

  tags = {
    Name = var.ssm_tag_name
  }
}
