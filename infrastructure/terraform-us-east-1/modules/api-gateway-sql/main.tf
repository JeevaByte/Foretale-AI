################################################################################
# API Gateway SQL Module - REST API for Database Operations
# SQL CRUD operations with Cognito authorization and CORS
################################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

################################################################################
# REST API for SQL Operations
################################################################################

resource "aws_api_gateway_rest_api" "sql" {
  name        = "${local.name_prefix}-api-sql"
  description = "REST API for SQL database operations"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-sql"
    }
  )
}

################################################################################
# Cognito Authorizer
################################################################################

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${local.name_prefix}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.sql.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [var.cognito_user_pool_arn]
}

################################################################################
# /insert_record Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "insert_record" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  parent_id   = aws_api_gateway_rest_api.sql.root_resource_id
  path_part   = "insert_record"
}

resource "aws_api_gateway_method" "insert_record_post" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.insert_record.id
  http_method      = "POST"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "insert_record_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.sql.id
  resource_id             = aws_api_gateway_resource.insert_record.id
  http_method             = aws_api_gateway_method.insert_record_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_calling_sql_procedure
}

resource "aws_api_gateway_integration_response" "insert_record" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.insert_record.id
  http_method       = aws_api_gateway_method.insert_record_post.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.insert_record_lambda]
}

resource "aws_api_gateway_method" "insert_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.insert_record.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "insert_record_options" {
  rest_api_id          = aws_api_gateway_rest_api.sql.id
  resource_id          = aws_api_gateway_resource.insert_record.id
  http_method          = aws_api_gateway_method.insert_record_options.http_method
  type                 = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "insert_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.insert_record.id
  http_method       = aws_api_gateway_method.insert_record_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.insert_record_options]
}

resource "aws_api_gateway_method_response" "insert_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.insert_record.id
  http_method      = aws_api_gateway_method.insert_record_options.http_method
  status_code      = "200"
  response_models  = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# /update_record Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "update_record" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  parent_id   = aws_api_gateway_rest_api.sql.root_resource_id
  path_part   = "update_record"
}

resource "aws_api_gateway_method" "update_record_put" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.update_record.id
  http_method      = "PUT"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "update_record_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.sql.id
  resource_id             = aws_api_gateway_resource.update_record.id
  http_method             = aws_api_gateway_method.update_record_put.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_calling_sql_procedure
}

resource "aws_api_gateway_integration_response" "update_record" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.update_record.id
  http_method       = aws_api_gateway_method.update_record_put.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.update_record_lambda]
}

resource "aws_api_gateway_method" "update_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.update_record.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "update_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.update_record.id
  http_method       = aws_api_gateway_method.update_record_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "update_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.update_record.id
  http_method       = aws_api_gateway_method.update_record_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.update_record_options]
}

resource "aws_api_gateway_method_response" "update_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.update_record.id
  http_method      = aws_api_gateway_method.update_record_options.http_method
  status_code      = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# /delete_record Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "delete_record" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  parent_id   = aws_api_gateway_rest_api.sql.root_resource_id
  path_part   = "delete_record"
}

resource "aws_api_gateway_method" "delete_record_delete" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.delete_record.id
  http_method      = "DELETE"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "delete_record_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.sql.id
  resource_id             = aws_api_gateway_resource.delete_record.id
  http_method             = aws_api_gateway_method.delete_record_delete.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_calling_sql_procedure
}

resource "aws_api_gateway_integration_response" "delete_record" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.delete_record.id
  http_method       = aws_api_gateway_method.delete_record_delete.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.delete_record_lambda]
}

resource "aws_api_gateway_method" "delete_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.delete_record.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "delete_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.delete_record.id
  http_method       = aws_api_gateway_method.delete_record_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "delete_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.delete_record.id
  http_method       = aws_api_gateway_method.delete_record_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.delete_record_options]
}

resource "aws_api_gateway_method_response" "delete_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.delete_record.id
  http_method      = aws_api_gateway_method.delete_record_options.http_method
  status_code      = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# /read_record Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "read_record" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  parent_id   = aws_api_gateway_rest_api.sql.root_resource_id
  path_part   = "read_record"
}

resource "aws_api_gateway_method" "read_record_get" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_record.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "read_record_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.sql.id
  resource_id             = aws_api_gateway_resource.read_record.id
  http_method             = aws_api_gateway_method.read_record_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_calling_sql_procedure
}

resource "aws_api_gateway_integration_response" "read_record" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_record.id
  http_method       = aws_api_gateway_method.read_record_get.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.read_record_lambda]
}

resource "aws_api_gateway_method" "read_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_record.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "read_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_record.id
  http_method       = aws_api_gateway_method.read_record_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "read_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_record.id
  http_method       = aws_api_gateway_method.read_record_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.read_record_options]
}

resource "aws_api_gateway_method_response" "read_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_record.id
  http_method      = aws_api_gateway_method.read_record_options.http_method
  status_code      = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

################################################################################
# /read_json_record Resource and Methods
################################################################################

resource "aws_api_gateway_resource" "read_json_record" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  parent_id   = aws_api_gateway_rest_api.sql.root_resource_id
  path_part   = "read_json_record"
}

resource "aws_api_gateway_method" "read_json_record_get" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_json_record.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "read_json_record_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.sql.id
  resource_id             = aws_api_gateway_resource.read_json_record.id
  http_method             = aws_api_gateway_method.read_json_record_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn_calling_sql_procedure
}

resource "aws_api_gateway_integration_response" "read_json_record" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_json_record.id
  http_method       = aws_api_gateway_method.read_json_record_get.http_method
  status_code       = "200"
  selection_pattern = ""
  depends_on        = [aws_api_gateway_integration.read_json_record_lambda]
}

resource "aws_api_gateway_method" "read_json_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_json_record.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "read_json_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_json_record.id
  http_method       = aws_api_gateway_method.read_json_record_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration_response" "read_json_record_options" {
  rest_api_id       = aws_api_gateway_rest_api.sql.id
  resource_id       = aws_api_gateway_resource.read_json_record.id
  http_method       = aws_api_gateway_method.read_json_record_options.http_method
  status_code       = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.read_json_record_options]
}

resource "aws_api_gateway_method_response" "read_json_record_options" {
  rest_api_id      = aws_api_gateway_rest_api.sql.id
  resource_id      = aws_api_gateway_resource.read_json_record.id
  http_method      = aws_api_gateway_method.read_json_record_options.http_method
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

resource "aws_api_gateway_deployment" "sql" {
  rest_api_id = aws_api_gateway_rest_api.sql.id

  depends_on = [
    aws_api_gateway_integration.insert_record_lambda,
    aws_api_gateway_integration.update_record_lambda,
    aws_api_gateway_integration.delete_record_lambda,
    aws_api_gateway_integration.read_record_lambda,
    aws_api_gateway_integration.read_json_record_lambda,
    aws_api_gateway_integration_response.insert_record,
    aws_api_gateway_integration_response.update_record,
    aws_api_gateway_integration_response.delete_record,
    aws_api_gateway_integration_response.read_record,
    aws_api_gateway_integration_response.read_json_record
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "sql" {
  deployment_id = aws_api_gateway_deployment.sql.id
  rest_api_id   = aws_api_gateway_rest_api.sql.id
  stage_name    = var.environment

  variables = {
    environment = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-sql-stage"
    }
  )
}

################################################################################
# Lambda Permissions
################################################################################

resource "aws_lambda_permission" "api_gateway_sql" {
  statement_id  = "AllowAPIGatewaySQLInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name_calling_sql_procedure
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sql.execution_arn}/*/*"
}

################################################################################
# CloudWatch Logging
################################################################################

resource "aws_cloudwatch_log_group" "api_gateway_sql" {
  name              = "/aws/apigateway/${local.name_prefix}-api-sql"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-api-sql-logs"
    }
  )
}

resource "aws_api_gateway_method_settings" "sql" {
  rest_api_id = aws_api_gateway_rest_api.sql.id
  stage_name  = aws_api_gateway_stage.sql.stage_name
  method_path = "*/*"

  settings {
    logging_level                           = "INFO"
    data_trace_enabled                      = true
    metrics_enabled                         = true
    require_authorization_for_cache_control = true
  }
}
