resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app_name}-${var.env}-logs"

  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_event_target" "esc_target" {
  target_id = "${var.app_name}-${var.env}-task"
  arn       = aws_ecs_cluster.aws-ecs-cluster.arn
  rule      = aws_cloudwatch_event_rule.schedule.name
  role_arn  = aws_iam_role.cloudwatch_events_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.aws-ecs-task.arn
    launch_type         = "FARGATE"

    network_configuration {
        subnets          = [for s in data.aws_subnet.subnet_ids : s.id]
        assign_public_ip = true
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-${var.env}-scheduled-event"
  description         = "Runs Fargate task ${var.app_name}-${var.env}: ${var.schedule_expression}"
  schedule_expression = var.schedule_expression
}
