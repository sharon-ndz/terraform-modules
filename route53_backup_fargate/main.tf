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

data "aws_subnet_ids" "vpc_id" {
  vpc_id = var.vpc_id
  tags = {
    Name = "*-public-*"
  }
}


data "aws_subnet" "subnet_ids" {
  for_each = data.aws_subnet_ids.vpc_id.ids
  id       = each.value
}


resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-${var.env}-cluster"
  tags = {
    Name        = "${var.app_name}-ecs"
    Environment = var.env
  }
}



resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.env}-container",
      "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
      "entryPoint": [],
      "environment": [
        {
          "name": "s3_backup_bucket_name",
          "value": "${var.s3_backup_bucket_name}"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "/aws/ecs/${var.app_name}-${var.env}"
        }
      },
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.route53_backup_role.arn

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.env
  }
}



data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
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