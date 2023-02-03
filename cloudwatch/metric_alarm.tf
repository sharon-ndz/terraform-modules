### Create a cloudwatch alarm ###
#
#  alarm_name:                The alarm name
#  comparison_operator:       The arithmetic operation to use when comparing the specified Statistic and Threshold.
#                               The specified Statistic value is used as the first operand. Either of the following
#                               is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold,
#                               LessThanOrEqualToThreshold.
#  evaluation_periods:        The number of periods over which data is compared to the specified threshold.
#  metric_name:               The name for the alarm's associated metric. 
#                               See: https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CW_Support_For_AWS.html
#  namespace:                 The namespace for the alarm's associated metric.
#                               See: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-namespaces.html
#  period:                    The period in seconds over which the specified statistic is applied.
#  statistic:                 The statistic to apply to the alarm's associated metric. Either of the following is supported: 
#                               SampleCount, Average, Sum, Minimum, Maximum
#  threshold:                 The value against which the specified statistic is compared.
#  alarm_description:         The description for the alarm.
#  insufficient_data_actions: The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any 
#                               other state. Each action is specified as an Amazon Resource Number (ARN).
#################################
resource "aws_cloudwatch_metric_alarm" "metric-alarm" {
  alarm_name          = format("%s-%s-%s-cloudwatch-%s", var.brand, var.environment, var.region, var.application)
  comparison_operator = var.cloudwatch_comparison_operator
  datapoints_to_alarm = var.cloudwatch_data_points_to_alarm
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = var.cloudwatch_metric_name
  namespace           = var.cloudwatch_namespace
  period              = var.cloudwatch_period
  statistic           = var.cloudwatch_statistic
  threshold           = var.cloudwatch_threshold
  treat_missing_data  = var.cloudwatch_treat_missing_data
  alarm_description = format(
    "This metric monitors the %s %s",
    var.environment,
    replace(var.application, "-", " "),
  )
  insufficient_data_actions = var.cloudwatch_insufficient_data_actions

  dimensions = var.cloudwatch_dimensions

  alarm_actions = [aws_sns_topic.metric-alarm-sns-topic.arn]
  ok_actions    = [aws_sns_topic.metric-alarm-sns-topic.arn]
}

# Create a sns topic for the alarm to signal
resource "aws_sns_topic" "metric-alarm-sns-topic" {
  name = format("%s-sns-%s-topic", var.environment, var.application)
}

### NOTIFICATIONS VIA SNS SUBSCRIPTIONS ###

### SLACK ###

# SLACK: Subscribe the to the sns topic with slack endpoint if enabled
resource "aws_sns_topic_subscription" "subscription_slack" {
  count = var.notify_slack != "" ? 1 : 0

  topic_arn = aws_sns_topic.metric-alarm-sns-topic.arn
  protocol  = "email"
  endpoint  = var.endpoint_slack
}

### EMAIL ###
# Email: Subscribe to the sns topic with the email if enabled
resource "null_resource" "subscription_emails" {
  count = length(var.notify_emails)

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.metric-alarm-sns-topic.arn} --protocol email --notification-endpoint ${element(var.notify_emails, count.index)} --region ${var.region}"
  }
}

### PAGERDUTY ###
# PAGERDUTY: Subscribe to the sns topic with pagerduty integration endpoint if notify_pagerduty_integration_key passed
resource "aws_sns_topic_subscription" "subscription_pagerduty" {
  count = var.notify_pagerduty_integration_key != "" ? 1 : 0

  endpoint = format(
    "https://events.pagerduty.com/integration/%s/enqueue",
    var.notify_pagerduty_integration_key,
  )
  endpoint_auto_confirms = true
  protocol               = "https"
  topic_arn              = aws_sns_topic.metric-alarm-sns-topic.arn
}