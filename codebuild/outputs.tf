output "codebuild_project_id" {
  value = aws_codebuild_project.default.id
}

output "codebuild_project_name" {
  value = aws_codebuild_project.default.name
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.default.arn
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}

output "iam_role_description" {
  value = aws_iam_role.default.description
}

output "iam_policy_id" {
  value = aws_iam_policy.default.id
}

output "iam_policy_arn" {
  value = aws_iam_policy.default.arn
}

output "iam_policy_description" {
  value = aws_iam_policy.default.description
}

output "iam_policy_name" {
  value = aws_iam_policy.default.name
}

output "iam_policy_path" {
  value = aws_iam_policy.default.path
}

output "iam_policy_document" {
  value = aws_iam_policy.default.policy
}
