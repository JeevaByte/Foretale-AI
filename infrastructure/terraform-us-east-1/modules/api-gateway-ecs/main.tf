################################################################################
# API Gateway ECS Module - REST API for ECS Task Operations
# ECS task invocation with Cognito authorization and CORS
################################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

################################################################################
# REST API for ECS Operations
################################################################################

resource "aws_api_gateway_rest_api" "ecs" {
  name        = "${local.name_prefix}-api-ecs"
  description = "REST API for ECS task operations"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-ecs"
    }
  )
}

################################################################################
# Cognito Authorizer
################################################################################

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${local.name_prefix}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.ecs.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [var.cognito_user_pool_arn]
}

################################################################################
# /ecs_invoker_resource Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "ecs_invoker" {
  rest_api_id = aws_api_gateway_rest_api.ecs.id
  parent_id   = aws_api_gateway_rest_api.ecs.root_resource_id
  path_part   = "ecs_invoker_resource"
}

resource "aws_api_gateway_method" "ecs_invoker_post" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.ecs_invoker.id
  http_method      = "POST"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "ecs_invoker_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ecs.id
  resource_id             = aws_api_gateway_resource.ecs_invoker.id
  http_method             = aws_api_gateway_method.ecs_invoker_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_ecs_invoker
}

resource "aws_api_gateway_integration_response" "ecs_invoker" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.ecs_invoker.id
  http_method       = aws_api_gateway_method.ecs_invoker_post.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.ecs_invoker_lambda]
}

resource "aws_api_gateway_method" "ecs_invoker_options" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.ecs_invoker.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "ecs_invoker_options" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.ecs_invoker.id
  http_method       = aws_api_gateway_method.ecs_invoker_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "ecs_invoker_options" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.ecs_invoker.id
  http_method       = aws_api_gateway_method.ecs_invoker_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.ecs_invoker_options]
}

resource "aws_api_gateway_method_response" "ecs_invoker_options" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.ecs_invoker.id
  http_method      = aws_api_gateway_method.ecs_invoker_options.http_method
  status_code      = "200"
  response_models  = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# /get_ecs_status Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "get_ecs_status" {
  rest_api_id = aws_api_gateway_rest_api.ecs.id
  parent_id   = aws_api_gateway_rest_api.ecs.root_resource_id
  path_part   = "get_ecs_status"
}

resource "aws_api_gateway_method" "get_ecs_status_get" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.get_ecs_status.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "get_ecs_status_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ecs.id
  resource_id             = aws_api_gateway_resource.get_ecs_status.id
  http_method             = aws_api_gateway_method.get_ecs_status_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_get_ecs_status
}

resource "aws_api_gateway_integration_response" "get_ecs_status" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.get_ecs_status.id
  http_method       = aws_api_gateway_method.get_ecs_status_get.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.get_ecs_status_lambda]
}

resource "aws_api_gateway_method" "get_ecs_status_options" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.get_ecs_status.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "get_ecs_status_options" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.get_ecs_status.id
  http_method       = aws_api_gateway_method.get_ecs_status_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "get_ecs_status_options" {
  rest_api_id       = aws_api_gateway_rest_api.ecs.id
  resource_id       = aws_api_gateway_resource.get_ecs_status.id
  http_method       = aws_api_gateway_method.get_ecs_status_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.get_ecs_status_options]
}

resource "aws_api_gateway_method_response" "get_ecs_status_options" {
  rest_api_id      = aws_api_gateway_rest_api.ecs.id
  resource_id      = aws_api_gateway_resource.get_ecs_status.id
  http_method      = aws_api_gateway_method.get_ecs_status_options.http_method
  status_code      = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# API Deployment
################################################################################

resource "aws_api_gateway_deployment" "ecs" {
  rest_api_id = aws_api_gateway_rest_api.ecs.id

  depends_on = [
    aws_api_gateway_integration.ecs_invoker_lambda,
    aws_api_gateway_integration.get_ecs_status_lambda,
    aws_api_gateway_integration_response.ecs_invoker,
    aws_api_gateway_integration_response.get_ecs_status
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "ecs" {
  deployment_id = aws_api_gateway_deployment.ecs.id
  rest_api_id   = aws_api_gateway_rest_api.ecs.id
  stage_name    = var.environment

  variables = {
    environment = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-ecs-stage"
    }
  )
}

################################################################################
# Lambda Permissions
################################################################################

resource "aws_lambda_permission" "api_gateway_ecs_invoker" {
  statement_id  = "AllowAPIGatewayECSInvokerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name_ecs_invoker
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecs.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_get_ecs_status" {
  statement_id  = "AllowAPIGatewayGetEcsStatusInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name_get_ecs_status
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecs.execution_arn}/*/*"
}

################################################################################
# CloudWatch Logging
################################################################################

resource "aws_cloudwatch_log_group" "api_gateway_ecs" {
  name              = "/aws/apigateway/${local.name_prefix}-api-ecs"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-ecs-logs"
    }
  )
}

resource "aws_api_gateway_method_settings" "ecs" {
  rest_api_id = aws_api_gateway_rest_api.ecs.id
  stage_name  = aws_api_gateway_stage.ecs.stage_name
  method_path = "*/*"

  settings {
    logging_level                           = "INFO"
    data_trace_enabled                      = true
    metrics_enabled                         = true
    require_authorization_for_cache_control = true
  }
}
