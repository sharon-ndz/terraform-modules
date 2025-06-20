output "rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_logs.name
}

output "stage_arn" {
  description = "ARN of the API Gateway Stage"
  value       = aws_api_gateway_stage.default.arn
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_stage_name" {
  value = aws_api_gateway_stage.default.stage_name
}
