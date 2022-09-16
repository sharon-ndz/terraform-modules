locals {
  iam_name            = "${var.project}-deploy"
  log_group_arn       = "arn:aws:logs:${var.region}:${var.account}:log-group:/aws/codebuild/${var.project}"
  log_build_group_arn = "arn:aws:logs:${var.region}:${var.account}:log-group:${var.project}-${var.env}-build-group"
  log_config_sname    = "${var.project}-${var.env}-log-stream"
}

resource "aws_codebuild_project" "default" {
  name          = var.project
  description   = var.description
  service_role  = aws_iam_role.default.arn
  build_timeout = var.build_timeout

  artifacts {
    type = var.cb_art_type
  }

  environment {
    type            = var.environment_type
    compute_type    = var.compute_type
    image           = var.image
    privileged_mode = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.env_variables
      content {
        name  = env_variable.value.name
        value = env_variable.value.value
        type  = env_variable.value.type
      }
    }

    #    environment_variable {
    #      name  = var.build_env_var_name
    #      value = var.build_env_var_value
    #    }
  }

  source {
    type            = var.source_type
    location        = var.source_location
    git_clone_depth = var.git_clone_depth
    buildspec       = var.buildspec

    git_submodules_config {
      fetch_submodules = var.fetch_submodules
    }
  }

  source_version = var.source_branch

  cache {
    type     = var.cache_type
    location = var.cache_location
    modes    = []
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project}-${var.env}-build-group"
      stream_name = local.log_config_sname
    }

    s3_logs {
      status   = var.s3_logs_status
      location = "${aws_s3_bucket.default.id}/build-logs"
    }
  }

  tags = merge({ "Name" = var.project }, var.tags)
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.project}-${var.env}-codebuild"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  tags                    = var.tags
}

resource "aws_iam_role" "default" {
  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = var.iam_path
  description        = var.description
  tags               = merge({ "Name" = local.iam_name }, var.tags)
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "default" {
  name        = local.iam_name
  policy      = data.aws_iam_policy_document.policy.json
  path        = var.iam_path
  description = var.description
  tags        = merge({ "Name" = local.iam_name }, var.tags)
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      local.log_group_arn,
      "${local.log_group_arn}:*",
      "${local.log_build_group_arn}:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = [
      var.artifact_bucket_arn,
      "${var.artifact_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
