resource "aws_iam_user" "iam_user" {
  name = var.iamuser

  tags = {
    Environment = var.environment
    Application = var.application
    Project     = var.project
  }
}

#resource "aws_iam_access_key" "iam_user" {
#  user = "${aws_iam_user.iam_user.name}"
#}

resource "aws_iam_user_policy" "iam_user" {
  count = var.policy == "" ? 0 : 1
  name  = var.policyname == "" ? format("%s-iam-%s-user-policy", var.environment, var.application) : var.policyname
  user  = aws_iam_user.iam_user.name

  policy = var.policy
}

resource "aws_iam_user_group_membership" "usergroups" {
  count = length(var.usergroups) > 0 ? 1 : 0
  user  = aws_iam_user.iam_user.name

  groups = var.usergroups
}

resource "aws_iam_user_policy_attachment" "user_attach_policy" {
  count = var.user_attach_policy == "" ? 0 : 1
  user  = aws_iam_user.iam_user.name

  policy_arn = var.user_attach_policy
}

