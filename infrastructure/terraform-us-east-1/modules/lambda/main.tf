################################################################################
# Lambda Module - Database Proxy and Task Invocation Functions
# Provides serverless database access and ECS task invocation
################################################################################

locals {
  name_prefix       = "foretale-app-lambda"
  cloudwatch_prefix = "/aws/foretale-app/lambda"
}

################################################################################
# Data Source - Current AWS Region
################################################################################

data "aws_region" "current" {}

################################################################################
# CloudWatch Log Group for Lambda Functions
################################################################################

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "${local.cloudwatch_prefix}/main"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-logs"
    }
  )
}


################################################################################
# ECS Invoker Lambda - Trigger long-running tasks
################################################################################

resource "aws_lambda_function" "ecs_invoker" {
  function_name = "foretale-app-lambda-ecs-invoker"
  role          = var.lambda_execution_role_arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  timeout       = 900
  memory_size   = 256

  environment {
    variables = {
      ECS_CLUSTER_UPLOADS         = var.ecs_cluster_uploads
      ECS_CLUSTER_EXECUTE         = var.ecs_cluster_execute
      ECS_TASK_DEFINITION_CSV     = var.ecs_task_definition_csv
      ECS_TASK_DEFINITION_EXECUTE = var.ecs_task_definition_execute
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  filename         = "${path.module}/ecs_invoker.zip"
  source_code_hash = filebase64sha256("${path.module}/ecs_invoker.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-lambda-ecs-invoker"
    }
  )
}

################################################################################
# SQL Procedure Caller Lambda - Execute stored procedures
################################################################################

resource "aws_lambda_function" "calling_sql_procedure" {
  function_name = "calling-sql-procedure"
  role          = var.lambda_execution_role_arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  architectures = ["arm64"]
  timeout       = 900
  memory_size   = 512

  environment {
    variables = {
      RDS_ENDPOINT           = var.rds_endpoint
      RDS_PORT               = var.rds_port
      RDS_DATABASE           = var.rds_database
      RDS_USER               = var.rds_username
      SECRETS_MANAGER_SECRET = var.secrets_manager_secret_name
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  layers = [
    var.lambda_layer_db_utils_arn,
    var.lambda_layer_pyodbc_arn
  ]

  filename         = "${path.module}/calling_sql_procedure.zip"
  source_code_hash = filebase64sha256("${path.module}/calling_sql_procedure.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]

  tags = merge(
    var.tags,
    {
      Name = "calling-sql-procedure"
    }
  )
}

################################################################################
# SQL Server Data Upload Lambda - CSV to database
################################################################################

resource "aws_lambda_function" "sql_server_data_upload" {
  function_name = "sql-server-data-upload"
  role          = var.lambda_execution_role_arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  architectures = ["arm64"]
  timeout       = 900
  memory_size   = 512

  environment {
    variables = {
      RDS_ENDPOINT           = var.rds_endpoint
      RDS_PORT               = var.rds_port
      RDS_DATABASE           = var.rds_database
      RDS_USER               = var.rds_username
      SECRETS_MANAGER_SECRET = var.secrets_manager_secret_name
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  layers = [
    var.lambda_layer_db_utils_arn,
    var.lambda_layer_pyodbc_arn
  ]

  filename         = "${path.module}/sql_server_data_upload.zip"
  source_code_hash = filebase64sha256("${path.module}/sql_server_data_upload.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]

  tags = merge(
    var.tags,
    {
      Name = "sql-server-data-upload"
    }
  )
}

################################################################################
# ECS Task Invoker Lambda - Standalone for orchestration
################################################################################

resource "aws_lambda_function" "ecs_task_invoker" {
  function_name = "ecs-task-invoker"
  role          = var.lambda_execution_role_arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  architectures = ["arm64"]
  timeout       = 900
  memory_size   = 512

  environment {
    variables = {
      ECS_CLUSTER_UPLOADS         = var.ecs_cluster_uploads
      ECS_CLUSTER_EXECUTE         = var.ecs_cluster_execute
      ECS_TASK_DEFINITION_CSV     = var.ecs_task_definition_csv
      ECS_TASK_DEFINITION_EXECUTE = var.ecs_task_definition_execute
      ECS_CONTAINER_NAME          = "app"
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  layers = [
    var.lambda_layer_db_utils_arn,
    var.lambda_layer_pyodbc_arn
  ]

  filename         = "${path.module}/ecs_task_invoker.zip"
  source_code_hash = filebase64sha256("${path.module}/ecs_task_invoker.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]

  tags = merge(
    var.tags,
    {
      Name = "ecs-task-invoker"
    }
  )
}

################################################################################
# Lambda Alias for get-ecs-task-status (maps to ecs_invoker for compatibility)
################################################################################

resource "aws_lambda_alias" "get_ecs_status" {
  name            = "get-ecs-task-status"
  description     = "Alias for ecs_invoker Lambda function to match us-east-1 naming"
  function_name   = aws_lambda_function.ecs_invoker.function_name
  function_version = aws_lambda_function.ecs_invoker.version

  depends_on = [
    aws_lambda_function.ecs_invoker
  ]
}

################################################################################
# Lambda Security Group Association (attachment via vars)
################################################################################

# Lambda functions configured with VPC - security group already specified in vpc_config
# RDS security group ingress rule should already allow traffic from Lambda SG (configured in security groups module)
