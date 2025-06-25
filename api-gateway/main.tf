resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.environment}-rest-api"
  description = "REST API to NLB on port 4000 — ${timestamp()}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.environment}-vpc-link"
  target_arns = [var.vpc_link_arn]
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP"
  uri                     = "http://${var.nlb_dns_name}:4000/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_BINARY"

  request_templates = {
    "application/json" = ""
  }

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# ────── Method Responses ──────

resource "aws_api_gateway_method_response" "proxy_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = local.default_code

  response_parameters = {
    "method.response.header.Content-Type"                 = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "proxy_errors" {
  for_each = toset(local.error_status_codes)

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = each.key

  response_parameters = {
    "method.response.header.Content-Type"                 = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# ────── Integration Responses ──────

resource "aws_api_gateway_integration_response" "proxy_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = local.default_code

  response_parameters = {
    "method.response.header.Content-Type"                 = "integration.response.header.Content-Type"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
  }

  depends_on = [aws_api_gateway_integration.proxy]
}

resource "aws_api_gateway_integration_response" "proxy_errors" {
  for_each = toset(local.error_status_codes)

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = each.key

  selection_pattern = (
    each.key == "400" ? "400" :
    each.key == "403" ? "403" :
    each.key == "404" ? "404" :
    each.key == "500" ? "5\\d{2}" :
    null
  )

  response_parameters = {
    "method.response.header.Content-Type"                 = "integration.response.header.Content-Type"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
  }

  depends_on = [aws_api_gateway_integration.proxy]
}

# ────── Logging ──────

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/api-gateway/${var.environment}-api"
  retention_in_days = var.log_retention_days
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gw_cloudwatch.arn
  depends_on          = [aws_iam_role_policy_attachment.api_gw_logs]
}

resource "aws_api_gateway_stage" "default" {
  stage_name    = "default"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  depends_on = [
    aws_cloudwatch_log_group.api_logs,
    aws_api_gateway_account.account
  ]
}

# ────── Deployment ──────

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  description = "Deployed on ${timestamp()}"

  depends_on = [
    aws_api_gateway_integration.proxy,
    aws_api_gateway_method_response.proxy_200,
    aws_api_gateway_integration_response.proxy_200,
    aws_api_gateway_method_response.proxy_errors,
    aws_api_gateway_integration_response.proxy_errors
  ]
}

