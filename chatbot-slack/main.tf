data "local_file" "cloudformation_template" {
  filename = "${path.module}/cloudformation.yml"
}

resource "aws_iam_role" "chatbot" {
  name               = "${var.project}_notifications"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Sid": "",
    "Effect": "Allow",
    "Principal": {
        "Service": [
        "chatbot.amazonaws.com"
        ]
    },
    "Action": "sts:AssumeRole"
    }
]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch-readonly-policy-attachment" {
  role       = aws_iam_role.chatbot.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# ----- SNS Topic -----

resource "aws_sns_topic" "chatbot" {
  name = "${var.project}-${var.env}-${var.configuration_name}"

  tags = var.tags
}

# ----- Chatbot -----

resource "aws_cloudformation_stack" "chatbot_slack_configuration" {
  name = "${var.project}-${var.env}-${var.configuration_name}"

  template_body = data.local_file.cloudformation_template.content

  parameters = {
    ConfigurationNameParameter = var.configuration_name
    GuardrailPoliciesParameter = join(",", var.guardrail_policies)
    IamRoleArnParameter        = aws_iam_role.chatbot.arn
    LoggingLevelParameter      = var.logging_level
    SlackChannelIdParameter    = var.slack_channel_id
    SlackWorkspaceIdParameter  = var.slack_workspace_id
    SnsTopicArnsParameter      = aws_sns_topic.chatbot.arn
    UserRoleRequiredParameter  = var.user_role_required
  }

  tags = var.tags
}
