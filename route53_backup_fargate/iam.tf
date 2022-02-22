

resource "aws_iam_role" "route53_backup_role" {
  name               = "route53_backup_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "route53_backup_policy" {
  name   = "route53_backup_policy"
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

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.app_name}-iam-role"
    Environment = var.env
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}



resource "aws_iam_role" "cloudwatch_events_role" {
  name               = "${var.app_name}-${var.env}-events"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_role_assume_policy.json
}

data "aws_iam_policy_document" "cloudwatch_events_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch_events_role_run_task" {
  name   = "${aws_ecs_task_definition.aws-ecs-task.family}-events-ecs"
  role   = aws_iam_role.cloudwatch_events_role.id
  policy = data.aws_iam_policy_document.cloudwatch_events_role_run_task_policy.json
}

data "aws_iam_policy_document" "cloudwatch_events_role_run_task_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_events_role_pass_role" {
  name   = "${aws_ecs_task_definition.aws-ecs-task.family}-events-ecs-pass-role"
  role   = aws_iam_role.cloudwatch_events_role.id
  policy = data.aws_iam_policy_document.cloudwatch_events_role_pass_role_policy.json
}

data "aws_iam_policy_document" "cloudwatch_events_role_pass_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]

    resources = [
      aws_iam_role.ecsTaskExecutionRole.arn,
      aws_iam_role.route53_backup_role.arn,
    ]
  }
}
