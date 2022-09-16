resource "aws_api_gateway_rest_api" "default" {
  name = var.apigw_name
}

resource "aws_api_gateway_resource" "default" {
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = var.apigw_path
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "default" {
  authorization    = var.apigw_authorization
  http_method      = var.apigw_http_method
  resource_id      = aws_api_gateway_resource.default.id
  rest_api_id      = aws_api_gateway_rest_api.default.id
  api_key_required = var.apigw_key
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id         = aws_api_gateway_rest_api.default.id
  resource_id         = aws_api_gateway_resource.default.id
  http_method         = aws_api_gateway_method.default.http_method
  status_code         = var.apigw_status_code
  response_models     = var.response_models
  response_parameters = var.response_parameters

  depends_on = [aws_api_gateway_method.default]
}

resource "aws_api_gateway_integration" "default" {
  http_method             = aws_api_gateway_method.default.http_method
  integration_http_method = aws_api_gateway_method.default.http_method
  resource_id             = aws_api_gateway_resource.default.id
  rest_api_id             = aws_api_gateway_rest_api.default.id
  uri                     = aws_lambda_function.cfs-all-deploy.invoke_arn # TODO
  type                    = var.apigw_integration_type
  request_templates       = var.apigw_request_templates
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id        = aws_api_gateway_rest_api.default.id
  resource_id        = aws_api_gateway_resource.default.id
  http_method        = aws_api_gateway_method.default.http_method
  status_code        = aws_api_gateway_method_response.response_200.status_code
  response_templates = var.apigw_response_templates

  depends_on = [
    aws_api_gateway_method_response.response_200,
    aws_api_gateway_integration.default,
  ]
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.default.id,
      aws_api_gateway_method.default.id,
      aws_api_gateway_integration.default.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = var.apigw_stage_name
}
